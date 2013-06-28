package orichalcum.animation 
{
	import org.hamcrest.NullDescription;
	
	/**
	 * Later add pipline for ease
	 * Later add timeScale for addative integration
	 */
	internal class AnimationBase 
	{
		
		internal var _timelinePosition:Number = 0;
		
		public function AnimationBase()
		{
			
		}
		
		internal function get _totalDuration():Number
		{
			return 0;
		}
		
		internal function _tween(progress:Number):void
		{
			// abstract
		}
		
	}

}
