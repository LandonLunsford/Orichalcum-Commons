package orichalcum.animation.factory 
{
	import orichalcum.animation.Tween;
	
	/**
	 * @param	time
	 * @return
	 */
	public function call(callback:Function):Tween
	{
		return tween().onComplete(callback);
	}

}