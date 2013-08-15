package orichalcum.animation.factory 
{
	import orichalcum.animation.Animation;
	
	public function animate(...animations):Animation
	{
		return (animations.length == 1 && animations[0] is Array)
			? new Animation(animations[0])
			: new Animation(animations);
	}

}