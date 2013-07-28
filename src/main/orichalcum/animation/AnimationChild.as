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
			var yoyosCompleted:int;
			var _ease:Function = parent._ease;
			var _yoyo:Boolean = parent._yoyo;
			var _duration:Number = parent._duration * (_yoyo ? 0.5 : 1);
			//var _duration:Number = parent._duration;
			var endPosition:Number = parent._totalDuration; // wrong needs to be parents ep;
			var renderedPosition:Number = MathUtil.limit(position, 0, endPosition);
			
			trace('p/d', position, endPosition);
			
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
			
			if (_yoyo && isInMiddle)
			{
				const currentCompletedCycles:int = position / _duration;
				
				// this happens after yoyo is coming back. thats a problem
				yoyosCompleted = ((currentCompletedCycles + 1) >> 1) - (((_previousPosition / _duration) + 1) >> 1);
				
				if (currentCompletedCycles & 1 == 1)
				{
					renderedPosition = _duration - renderedPosition;
				}
			}
			
			var progress:Number = _ease(MathUtil.limit(renderedPosition / _duration, 0, 1), 0, 1, 1);
			
			// what remains of original
			for (var property:String in _tweeners)
			{
				// wont always want to set here (like for colorTransform)
				_tweeners[property].tween(_target, property, progress);
			}
			
			if (triggerCallbacks)
			{
				while (yoyosCompleted-- > 0)
				{
					FunctionUtil.call(parent._onChange, parent, isGoto);
				}
			}
			
			_previousPosition = position;
		}
		
		
		
	}

}
