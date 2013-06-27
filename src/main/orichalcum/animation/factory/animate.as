package orichalcum.animation.factory 
{
	import orichalcum.animation.Animation;
	
	/**
	 * @param	animations
	 * @return
	 */
	public function animate(...animations):Animation
	{
		return new Animation(animations);
	}

}
