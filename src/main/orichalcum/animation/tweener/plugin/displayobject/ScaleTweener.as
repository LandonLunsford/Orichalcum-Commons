package orichalcum.animation.tweener.plugin.displayobject 
{
	import flash.display.DisplayObject;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.utility.Functions;

	public class ScaleTweener extends NumberTweener
	{
		
		static public const properties:Array = ['scale'];
		private var _tweenFunction:Function = Functions.NULL;
		
		override public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			if (!(target is DisplayObject)) return;
			
			_start = fromValueIfAny ? fromValueIfAny : target.scaleX;
			_delta = (toValueIfAny ? toValueIfAny : target.scaleX) - _start;
			_tweenFunction = tweenScale;
		}
		
		override public function tween(target:Object, property:String, progress:Number):* 
		{
			return _tweenFunction(target, property, progress);
		}
		
		private function tweenScale(target:Object, property:String, progress:Number):*
		{
			return target.scaleX = target.scaleY = interpolate(progress);
		}
		
		
	}

}
