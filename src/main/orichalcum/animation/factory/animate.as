package orichalcum.animation.factory 
{
	import orichalcum.animation.Animation;
	
	public function animate(...animations):Animation
	{
		return new Animation(animations);
	}

}