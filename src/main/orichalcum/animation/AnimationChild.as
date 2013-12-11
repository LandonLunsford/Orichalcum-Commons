package orichalcum.animation 
{
	
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
			_target = target ? target : NULL_TARGET;
		}
		
		override internal function _render(position:Number, isGoto:Boolean = false, triggerCallbacks:Boolean = true, progress:Number = NaN):void
		{
			for (var property:String in _tweeners)
			{
				// wont always want to set here (like for colorTransform)
				_tweeners[property].tween(_target, property, progress);
			}
		}
		
	}

}
