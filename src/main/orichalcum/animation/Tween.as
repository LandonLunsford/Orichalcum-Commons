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
		
		override protected function _render(value:Number, jump:Boolean, triggerCallbacks:Boolean, target:Object, ease:Function):void 
		{
			//trace('v', value, 'p',_position,'pp', _previousPosition);
			_previousPosition = _position;
			
			// something changed in here and now mhy numbers are incorrect
			var endPosition:Number = _endPosition
				,isComplete:Boolean = value >= endPosition //value >= maximumPosition && _iterations > 0;
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
				
				if (_yoyo)
				{
					const cycle:int = (_position / _duration) & 1;
					const previousCycle:int = (_previousPosition / _duration) & 1;
					const isReflecting:Boolean = (cycle == isMovingForward ? 1 : 0) && cycle != previousCycle;
					
					if (cycle) calculatedPosition = _duration - calculatedPosition;
				}
			}
			
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
				//trace('mov');
				
				_initialized || _initialize();
				
				const passedZero:Boolean = (_position > 0 && _previousPosition <= 0) || (_position < 0 && _previousPosition >= 0);
				
				//trace(_previousPosition, _position, passedZero);
				
				passedZero && initHandler(jump);
				
				// should not even be calculated for isComplete == true or position <= 0
				const progress:Number = (_duration == 0 && _position >= 0) ? 1 : ease(calculatedPosition / _duration, 0, 1, 1);
				
				//trace( (_duration == 0 && _position >= 0))
				//trace( calculatedPosition)
				
				for (var property:String in _tweeners)
				{
					target[property] = _tweeners[property].tween(target, property, progress, passedZero, isComplete);
				}
					
				changeHandler(jump);
			}
			
			isReflecting && yoyoHandler(jump);
			
			if (isComplete)
			{
				// STOP MOVIE
				_initialized = false;
				_setIsPlaying(false);
				completeHandler(jump);
			}
		}
		
		override protected function _initialize():void
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
				if (tweener) tweener.init(property in from ? from[property] : _target[property], to[property]);
			}
		}
		
	}

}