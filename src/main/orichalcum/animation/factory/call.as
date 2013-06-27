package orichalcum.animation.factory 
{
	import orichalcum.animation.AnimationBase;
	import orichalcum.animation.Tween;
	
	/**
	 * @param	time
	 * @return
	 */
	public function call(callback:Function):AnimationBase
	{
		return tween().onInit(callback).seconds(0);
	}

}
