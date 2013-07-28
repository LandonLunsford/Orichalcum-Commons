package orichalcum.animation 
{
	
	/**
	 * Later add pipline for ease
	 * Later add timeScale for addative integration
	 */
	internal class AnimationBase 
	{
		internal var _previousPosition:Number = -0.0001;
		
		public function AnimationBase()
		{
			
		}
		
		internal function get _totalDuration():Number
		{
			return 0;
		}
		
		internal function _render(position:Number, isGoto:Boolean = false, triggerCallbacks:Boolean = true, parent:Animation = null):void
		{
			// abstract
		}
		
	}

}
