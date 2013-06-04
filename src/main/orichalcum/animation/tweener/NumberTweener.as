package orichalcum.animation.tweener
{
	import orichalcum.utility.StringUtil;
	

	public class NumberTweener implements ITweener
	{
		// may want to refactor into decorator class or other class for efficiency
		static private const RETURN:Function = function(value:Number):Number { return value; }
		private var _round:Function = RETURN;
		private var _start:Number;
		private var _distance:Number;
		
		/** flyweight */
		public function init(start:Number, end:Number, rounded:Boolean, relative:Boolean):void
		{
			_start = start;
			_distance = relative ? end : end - start;
			_round = rounded ? Math.round : RETURN;
		}
		
		public function tween(target:Object, property:String, progress:Number):void
		{
			target[property] = _round(_start + progress * _distance);
		}
		
		public function toString():String
		{
			return StringUtil.substitute('<number-tweener start="{0}" end="{1}" round="{2}">', _start, _start + _distance, _round == ROUND);
		}
		
	}

}
