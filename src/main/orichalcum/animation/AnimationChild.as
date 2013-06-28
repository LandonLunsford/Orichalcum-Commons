package orichalcum.animation 
{
	
	/**
	 * Later add pipline for ease
	 * Later add timeScale for addative integration
	 */
	internal class AnimationChild extends AnimationBase
	{
		internal var _target:Object;
		internal var _tweeners:Object;
		
		public function AnimationChild(target:Object = null)
		{
			_target = target ? target : Animation.NULL_TARGET;
		}
		
		override internal function _tween(progress:Number):void
		{
			
			
			for (var property:String in _tweeners)
			{
				//trace('property----------', property);
				//trace('tweeners', _tweeners);
				//trace('target', _target);
				//trace('isStart', isStart);
				//trace('isEnd', isEnd);
				
				// wont always want to set here (like for colorTransform)
				_target[property] = _tweeners[property].tween(_target, property, progress);
			}
		}
		
		
		
	}

}
