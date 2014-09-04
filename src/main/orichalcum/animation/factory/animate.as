package orichalcum.animation.factory 
{
	import orichalcum.animation.Animation;

	public function animate(...targets):Animation
	{
		return new Animation(targets);
	}

}