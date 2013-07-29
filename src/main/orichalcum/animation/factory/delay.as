package orichalcum.animation.factory 
{
	import orichalcum.animation.Animation;

	public function delay(time:Number = NaN):Animation
	{
		return wait(time);
	}

}