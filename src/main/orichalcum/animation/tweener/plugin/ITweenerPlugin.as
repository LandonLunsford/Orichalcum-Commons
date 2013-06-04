package orichalcum.animation.tweener.plugin
{
	import orichalcum.animation.ITweener;
	
	public interface ITweenerPlugin extends ITweener
	{
		public function get property():String;
	}
}
