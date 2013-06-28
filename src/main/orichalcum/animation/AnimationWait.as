package orichalcum.animation 
{

	public class AnimationWait extends AnimationBase
	{
		
		private var _duration:Number;
		
		public function AnimationWait(time:Number = NaN) 
		{
			_duration = time * 1000;
		}
		
		override internal function get _totalDuration():Number 
		{
			return _duration;
		}
		
	}

}