package orichalcum.animation 
{
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.utility.FunctionUtil;
	import orichalcum.utility.ObjectUtil;

	public class Tween extends Animation 
	{
		
		protected var _to:Object;
		protected var _from:Object;
		protected var _tweeners:Object = {};
		
		public function Tween(target:Object = null) 
		{
			this.target(target);
		}
		
		public function to(...args):*
		{
			return args.length ? _setTo(args[0]) : _to;
		}
		
		public function from(...args):*
		{
			return args.length ? _setFrom(args[0]) : _to;
		}
		
		private function _setTo(value:Object):Tween 
		{
			_to = value;
			return this;
		}
		
		private function _setFrom(value:Object):Tween 
		{
			_from = value;
			return this;
		}
		
		/**
		 * should be _setPosition
		 * @param	value
		 * @param	jump
		 * @param	triggerCallbacks
		 * @param	target
		 * @param	ease
		 */
		//override protected function _render(value:Number, jump:Boolean, triggerCallbacks:Boolean, target:Object, ease:Function):void 
		//{
			//
		//}
		
		// AnimationTimeline should override this and target each child
		override protected function _renderTarget(target:Object, progress:Number, isStart:Boolean, isEnd:Boolean):void
		{
			for (var property:String in _tweeners)
			{
				target[property] = _tweeners[property].tween(target, property, progress, isStart, isEnd);
			}
			
		}
		
		override protected function _initialize(isJump:Boolean, callback:Function):void
		{
			_initialized = true;
			
			const from:Object = _from ? _from : _target;
			const to:Object = _to ? _to : _target;
			
			if (to === from) return;
			
			const values:Object = _to ? _to : _from;
			
			for (var property:String in values)
			{
				const tweener:ITweener = _tweeners[property] ||= Animation._createTweener(property, _target[property]);
				
				// boolean tween bug where start isnt set dynamically when in to
				if (tweener)
				{
					/** the property in? fork fills in the blank for assumed things left out of the other param list **/
					tweener.init(
						property in from ? from[property] : _target[property]
						//,property in to ? to[property] :  _target[property]
						,to[property]
					);
				}
			}
			
			callback(isJump);
		}
		
		protected function _render_stable(value:Number, jump:Boolean, triggerCallbacks:Boolean, target:Object, ease:Function):void 
		{
			_previousPosition = _position;
			
			var endPosition:Number = _endPosition
				,isComplete:Boolean = value >= endPosition
				,calculatedPosition:Number
				,isMovingForward:Boolean
				,initHandler:Function = FunctionUtil.noop
				,changeHandler:Function = FunctionUtil.noop
				,yoyoHandler:Function = FunctionUtil.noop
				,completeHandler:Function = FunctionUtil.noop;
				
			if (isComplete)
			{
				if (_previousPosition == endPosition) return;
				_position = endPosition;
				calculatedPosition = _yoyo ? 0 : _duration;
				isMovingForward = _position > _previousPosition;
			}
			else
			{
				//_position = Math.max(_delay, value);
				_position = value;
				calculatedPosition = _position < 0 ? 0 : _position % _duration; // eficiency would be to only do modulo if repeats > 0
				isMovingForward = _position > _previousPosition;
				
				//if (_yoyo)
				//{
					const cycle:int = (_position / _duration) & 1;
					//const previousCycle:int = (_previousPosition / _duration) & 1;
					//const isReflecting:Boolean = cycle != previousCycle && (cycle == isMovingForward ? 1 : 0);
					//
					//if (cycle) calculatedPosition = _duration - calculatedPosition;
				//}
				
				// this can be done below based on completed cycle calculation I believe
				if (_yoyo && ((_position / _duration) & 1 == 1))
					calculatedPosition = _duration - calculatedPosition;
			}
			
			const previousCompletedCycles:Number = _previousPosition / _duration;
			const currentCompletedCycles:Number = _position / _duration;
			var yoyosCompleted:int = ((currentCompletedCycles + 1) >> 1) - ((previousCompletedCycles + 1) >> 1);
			
			//trace(yoyosCompleted);
			
			if (triggerCallbacks)
			{
				changeHandler = _changeHandler;
				if (isMovingForward)
				{
					initHandler = _initHandler;
					yoyoHandler = _yoyoHandler;
					completeHandler = _completeHandler;
				}
			}
			
			// if not in delay interval and position changed
			if ((_position >= 0 || _previousPosition >= 0) && _position != _previousPosition)
			{
				
				_initialized || _initialize(jump, initHandler);
				
				const passedZero:Boolean = (_position > 0 && _previousPosition <= 0) || (_position < 0 && _previousPosition >= 0);
				
				//trace(_previousPosition, _position, passedZero);
				
				//passedZero && initHandler(jump);
				
				// should not even be calculated for isComplete == true or position <= 0
				const progress:Number = (_duration == 0 && _position >= 0) ? 1 : ease(calculatedPosition / _duration, 0, 1, 1);
				
				//trace( (_duration == 0 && _position >= 0))
				//trace( calculatedPosition)
				
				for (var property:String in _tweeners)
				{
					// AnimationTimelines will delegate to children here 
					target[property] = _tweeners[property].tween(target, property, progress, passedZero, isComplete);
				}
					
				changeHandler(jump);
			}
			
			//isReflecting && yoyoHandler(jump);
			while (yoyosCompleted--)
			{
				yoyoHandler(jump);
			}
			
			if (isComplete)
			{
				// STOP MOVIE
				_initialized = false;
				_setIsPlaying(false);
				completeHandler(jump);
			}
		}
		
	}

}
