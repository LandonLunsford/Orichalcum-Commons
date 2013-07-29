package orichalcum.animation 
{
	import orichalcum.utility.FunctionUtil;
	import orichalcum.utility.MathUtil;
	
	/**
	 * Later add pipline for ease
	 * Later add timeScale for addative integration
	 */
	internal class AnimationChild extends AnimationBase
	{
		/** @private used to avoid if checking target */
		static private const NULL_TARGET:Object = {};
		
		internal var _target:Object;
		internal var _tweeners:Object;
		
		public function AnimationChild(target:Object = null)
		{
			_target = target;
		}
		
		override internal function _render(position:Number, isGoto:Boolean = false, triggerCallbacks:Boolean = true, parent:Animation = null):void
		{
			trace('rendering?')
			var yoyosCompleted:int;
			var iterationsCompleted:int;
			const _ease:Function = parent._ease;
			const _yoyo:Boolean = parent._yoyo;
			const _duration:Number = parent._duration * (_yoyo ? 0.5 : 1);
			const endPosition:Number = parent._duration * parent._iterations; // wrong needs to be parents ep;
			var renderedPosition:Number = MathUtil.limit(position, 0, endPosition);
			
			const isComplete:Boolean = position >= endPosition + 0;
			const isInMiddle:Boolean = position > 0 && position < endPosition;
			
			if (isComplete || position >= endPosition)
			{
				renderedPosition = _yoyo ? 0 : endPosition;
			}
			else if (position <= 0)
			{
				renderedPosition = 0;
			}
			else
			{
				renderedPosition = position % _duration;
			}
			
			if (_yoyo)
			{
				const currentCompletedCycles:int = position / _duration;
				
				// this happens after yoyo is coming back. thats a problem
				yoyosCompleted = ((currentCompletedCycles + 1) >> 1) - (((_previousPosition / _duration) + 1) >> 1);
				
				if ((currentCompletedCycles & 1 == 1) && isInMiddle)
				{
					renderedPosition = _duration - renderedPosition;
				}
			}
			
			if (parent._onIteration != null)
			{
				iterationsCompleted = ((position / parent._duration) >> 0) - (((_previousPosition / parent._duration)) >> 0);
			}
			
			var progress:Number = _ease(MathUtil.limit(renderedPosition / _duration, 0, 1), 0, 1, 1);
			
			// what remains of original
			for (var property:String in _tweeners)
			{
				// wont always want to set here (like for colorTransform)
				_tweeners[property].tween(_target, property, progress);
			}
			
			/*
			 * If the animation has stagger it makes sense to shoot an event for every target
			 * not sure otherwise if I should do that
			 * Also I think I should set the parent's target property then pass it to the client
			 */
			if (triggerCallbacks)
			{
				// BUG, needs to go yoyo, iter, yoyo, iter -- when integrating
				//FunctionUtil.multiCall(yoyosCompleted, parent._onYoyo, parent, isGoto);
				//FunctionUtil.multiCall(iterationsCompleted, parent._onIteration, parent, isGoto);
				while (yoyosCompleted + iterationsCompleted > 0)
				{
					if (yoyosCompleted-- > 0)
					{
						FunctionUtil.call(parent._onYoyo, parent, isGoto);
					}
					if (iterationsCompleted-- > 0)
					{
						FunctionUtil.call(parent._onIteration, parent, isGoto);
					}
				}
			}
			
			_previousPosition = position;
		}
		
	}

}
