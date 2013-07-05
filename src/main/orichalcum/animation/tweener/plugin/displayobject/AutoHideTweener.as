package orichalcum.animation.tweener.plugin.displayobject
{
	import flash.display.DisplayObject;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;

	public class AutoHideTweener extends NumberTweener implements ITweener
	{
		
		static public const properties:Array = ['alpha'];
		
		static public var invisibleAlphaThreshold:Number = 0.01;
		
		override public function tween(target:Object, property:String, progress:Number):*
		{
			const value:Number = interpolate(target, property, progress);
			
			target is DisplayObject && (target.visible = target.alpha > invisibleAlphaThreshold);
			
			return target[property] = value;
		}
	}
}
