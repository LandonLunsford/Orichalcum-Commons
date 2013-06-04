package orichalcum.animation.tweener.plugin
{
	import orichalcum.animation.tweener.ITweener;

	public class AutoAlphaPlugin extends NumberTweener implements ITweenerPlugin
	{
		
		/* INTERFACE orichalcum.animation.tweener.ITweenerPlugin */

		public function get property():String
		{
			return 'alpha';
		}
		
		public function init(target:Object, value:*):void
		{
			super(target, value);
		}
		
		/* INTERFACE orichalcum.animation.tweener.ITweener */
		
		public function tween(target:Object, property:String, progress:Number):void
		{
			super(target, property, progress);
			
			target is DisplayObject && (target.visibile = target.alpha < 0.01);
		}
	}
}
