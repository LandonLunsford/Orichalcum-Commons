package orichalcum.animation.tweener.plugin
{
	import flash.display.DisplayObject;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;

	public class AutoHideTweener extends NumberTweener implements ITweener
	{
		static public var invisibleAlphaThreshhold:Number = 0.01;
		
		override public function tween(target:Object, property:String, progress:Number, isStart:Boolean, isEnd:Boolean):*
		{
			const value:Number = super.tween(target, property, progress, isStart, isEnd);
			
			target is DisplayObject && (target.visible = target.alpha > invisibleAlphaThreshhold);
			
			return value;
		}
	}
}
