package orichalcum.animation.factory 
{
	import orichalcum.animation.AnimationCall;
	
	public function call(...args):AnimationCall
	{
		return new AnimationCall(args);
	}

}