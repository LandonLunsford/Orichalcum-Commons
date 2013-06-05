package orichalcum.animation.tweener
{
	import orichalcum.utility.StringUtil;
	
	public class NumberTweener implements ITweener
	{
		static private const isRounded:RegExp = /\[.*\]/;
		static private const isRelative:RegExp = /\+=|-=/;
		static private const float:RegExp = /[-+]?[0-9]*\.?[0-9]+/;
		
		// may want to refactor into decorator class or other class for efficiency
		private const RETURN:Function = function(value:Number):Number { return value; }
		protected var _round:Function = RETURN;
		protected var _start:Number;
		protected var _distance:Number;
		
		/* INTERFACE orichalcum.animation.tweener.ITweener */
		
		public function init(start:*, end:*):void
		{
			_start = start;
			
			if (end is Number)
			{
				_distance = end - start;
			}
			else if (end is String)
			{
				const endNumber:Number = parseFloat(float.exec(end));
				_distance = isRelative.test(end) ? endNumber : endNumber - start;
				_round = isRounded.test(end) ? Math.round : RETURN;
			}
			else
			{
				throw new ArgumentError('Argument "end" passed to method NumberTweener.init() must be a Number or String number representation');
			}
		}
		
		public function tween(target:Object, property:String, progress:Number):void
		{
			target[property] = _round(_start + progress * _distance);
		}
		
		public function toString():String
		{
			return StringUtil.substitute('<number-tweener start="{0}" end="{1}" round="{2}">', _start, _start + _distance, _round == Math.round);
		}
		
	}

}
