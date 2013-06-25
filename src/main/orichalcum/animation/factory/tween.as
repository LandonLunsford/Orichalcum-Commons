package orichalcum.animation.factory 
{
	import orichalcum.animation.Tween;

	/*
	 * the API
		animate(
			tween(target).to(x).take(2).seconds()
			,wait(2)
			,call(f)
			,animate(target)
		).play()
	 */
	
	
	/**
	 * 
	 * @param	target
	 * @return
	 */
	public function tween(target:Object = null):Tween
	{
		return new Tween(target);
	}

}