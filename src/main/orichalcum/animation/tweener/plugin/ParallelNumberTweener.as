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
		
		override public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			super.init(fromValueIfAny, toValueIfAny);
			_previousValue = fromValueIfAny;
		}
		
		override public function tween(target:Object, property:String, progress:Number):*
		{
			const nextValue:Number = _round(_start + progress * _distance);
			const delta:Number = nextValue - _previousValue;
			_previousValue = nextValue;
			target[property] += delta;
		}
		
	}

}
