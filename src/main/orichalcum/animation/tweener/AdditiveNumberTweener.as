package orichalcum.animation.tweener
{
	
	/**
	 * Only works well in conjunction with round
	 */
	public class AdditiveNumberTweener extends NumberTweener
	{
		
		protected var _previousValue:Number;
		//protected var _distanceRemaining:Number;
		
		
		override public function init(start:Number, end:Number, rounded:Boolean, relative:Boolean):void
		{
			super.init(start, end, rounded, relative);
			_previousValue = start;
			//_distanceRemaining = _distance;
		}
		
		override public function tween(target:Object, property:String, progress:Number):void
		{
			var delta:Number, nextValue:Number;
			//if (progress > 0.999)
			//{
				//delta = _distanceRemaining;
				//_distanceRemaining = 0;
				//trace('adding last bit', target[property], delta, target[property] + delta);
			//}
			//else
			//{
				nextValue = _round(_start + progress * _distance);
				delta = nextValue - _previousValue;
				_previousValue = nextValue;
				//_distanceRemaining -= delta;
			//}
			
			// fill the gap in between the final position and current position on final step
			// this fill should only be necessary for the addative tweening algorithm this uses
			// because the addititve tweening adds complexity and data storage overhead I think
			// I will make the default tweening mechanism overwrite other parallel tweens on the
			// same property
			// this algorithm will be as follows
			// target[property] = _roundFilter(start + progress * _distance);
			// which leaves the question of how to make the API facilitate the distinction
			// y:{value:90, rounded:true, relative:true, additive:true} or y:'||[+=90]' (this is becoming a dsl)
			// rounded: []
			// relative: +=/-=
			// parallel: ||
			// note the fill is only necessary for non-rounded additive Number tweens
			// therefore the only truly necessary tween tipes are
			// 1 number overwirte
			// 2 number additive rounded
			// 3 number additive gap-closing
			// 4 boolean
			// ... plugins (colorTransform, dropShadow, etc.)
			target[property] = target[property] + delta;
		}
		
	}

}
