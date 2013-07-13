package orichalcum.animation.tweener.plugin.movieclip 
{
	import flash.display.MovieClip;
	import orichalcum.animation.tweener.NumberTweener;
	
	public class CurrentFrameTweener extends NumberTweener
	{
		
		override public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			super.initialize(target, property, from, to, fromValueIfAny, toValueIfAny);
			round = true;
		}
		
		override public function tween(target:Object, property:String, progress:Number):* 
		{
			if (!(target is MovieClip)) return undefined;
			
			const frame:uint = interpolate(progress);
			target.currentFrame == frame || target.gotoAndStop(frame);
			return frame;
		}
		
	}

}