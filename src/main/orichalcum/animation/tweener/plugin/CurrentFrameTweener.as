package orichalcum.animation.tweener.plugin 
{
	import flash.display.MovieClip;
	import orichalcum.animation.tweener.NumberTweener;
	
	public class CurrentFrameTweener extends NumberTweener
	{
		
		override public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			super.init(fromValueIfAny, toValueIfAny);
			round = true;
		}
		
		override public function tween(target:Object, property:String, progress:Number):* 
		{
			if (!(target is MovieClip)) return undefined;
			
			const frame:uint = super.tween(target, property, progress);
			target.currentFrame == frame || target.gotoAndStop(frame);
			return frame;
		}
		
	}

}