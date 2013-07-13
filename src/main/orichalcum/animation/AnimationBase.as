package orichalcum.animation 
{
	
	/**
	 * Later add pipline for ease
	 * Later add timeScale for addative integration
	 */
	internal class AnimationBase 
	{
		
		public function AnimationBase()
		{
			
		}
		
		internal function get _totalDuration():Number
		{
			return 0;
		}
		
		internal function _render(position:Number, isGoto:Boolean = false, triggerCallbacks:Boolean = true, progress:Number = NaN):void
		{
			// abstract
		}
		
	}

}
