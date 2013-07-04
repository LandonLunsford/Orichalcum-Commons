package orichalcum.animation.tweener.plugin.displayobject 
{
	import flash.display.DisplayObject;
	import orichalcum.animation.tweener.NumberTweener;

	public class ScaleTweener extends NumberTweener
	{
		
		static public const properties:Array = ['scale'];
		
		override public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			if (!(target is DisplayObject))
				throw new ArgumentError('Argument "target" passed to ScaleTweener must be of type "flash.display.DisplayObject".');
				
			_start = fromValueIfAny ? fromValueIfAny : target.scaleX * target.scaleY;
			_distance = (toValueIfAny ? toValueIfAny : target.scaleX * target.scaleY) - _start;
		}
		
		override public function tween(target:Object, property:String, progress:Number):* 
		{
			target.scaleX = target.scaleY = interpolate(progress);
		}
		
		
	}

}