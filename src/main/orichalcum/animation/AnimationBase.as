package orichalcum.animation 
{

	/**
	 * @author Landon Lunsford
	 */

	public class AnimationBase 
	{
		
		public function AnimationBase() 
		{
			
		}
		//
		//protected function _play(callback:):void
		//{
			//
		//}
		//
		protected function _update(deltaTime:Number):void
		{
			// parent animation needs to proxy target, timeScale, useFrames
			// to proxy this add parent and recursive lookups for each value
		}
		
	}

}