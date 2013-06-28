package orichalcum.animation.factory 
{
	import orichalcum.animation.AnimationWait;

	public function wait(time:Number = NaN):AnimationWait
	{
		return new AnimationWait(time);
	}

}