package orichalcum.animation.tweener.plugin
{
	import orichalcum.animation.tweener.NumberTweener;
	
	/**
	 * Only works well in conjuction with Math.round()
	 */
	public class ParallelNumberTweener extends NumberTweener
	{
		/** @private */
		protected var _previousValue:Number;
		
		override public function init(start:*, end:*):void
		{
			super.init(start, end);
			_previousValue = start;
		}
		
		override public function tween(target:Object, property:String, progress:Number, isStart:Boolean, isEnd:Boolean):*
		{
			const nextValue:Number = _round(_start + progress * _distance);
			const delta:Number = nextValue - _previousValue;
			_previousValue = nextValue;
			return target[property] + delta;
		}
		
	}

}
