package orichalcum.animation.tweener.plugin 
{
	import flash.display.MovieClip;
	import orichalcum.animation.tweener.NumberTweener;
	
	public class CurrentFrameTweener extends NumberTweener
	{
		
		override public function init(start:*, end:*):void 
		{
			super.init(start, end);
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