package orichalcum.animation 
{
	import adobe.utils.CustomActions;
	import orichalcum.utility.StringUtil;

	internal class NumberTweener implements ITweener
	{
		static private const RETURN:Function = function(next:Number):Number { return next; }
		private var _start:Number;
		private var _previousValue:Number;
		private var _distance:Number;
		private var _position:Number;
		private var _round:Function = RETURN;
		
		/** flyweight */
		public function init(start:Number, end:Number, rounded:Boolean, relative:Boolean):void
		{
			_start = start;
			_previousValue = start;
			_distance = relative ? end : end - start;
			_distanceRemaining = _distance;
			_round = rounded ? Math.round : RETURN;
		}
		
		public function tween(target:Object, property:String, progress:Number):void
		{
			var delta:Number, nextValue:Number;
			if (progress == 1)
			{
				delta = _distanceRemaining;
			}
			else
			{
				nextValue = _round(_start + progress * _distance);
				delta = nextValue - _previousValue;
				_previousValue = nextValue;
				_distanceRemaining -= delta;
			}
			
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
		
		public function toString():String
		{
			return StringUtil.substitute('<number-tweener name="{0}" start="{1}" end="{2}" round="{3}" relative="{4}">', '?', _start, _start + _distance, _roundFilter == ROUND, '?');
		}
		
	}

}
