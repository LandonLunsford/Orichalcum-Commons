package orichalcum.animation 
{
	
	/**
	 * Later add pipline for ease
	 * Later add timeScale for addative integration
	 */
	public class AnimationBase 
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
		
		internal function _equals(animation:AnimationBase):Boolean
		{
			return this === animation;
		}
		
	}

}
