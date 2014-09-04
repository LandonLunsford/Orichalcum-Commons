package orichalcum.animation.tweener
{
	import orichalcum.utility.Strings;
	
	public class NumberTweener implements ITweener
	{
		
		/** @private */
		static private const ROUNDED_DETECTOR:RegExp = /\[.*\]/;
		
		/** @private */
		static private const RELATIVE_DETECTOR:RegExp = /\+=|-=/;
		
		/** @private */
		static private const FLOAT_DETECTOR:RegExp = /[-+]?[0-9]*\.?[0-9]+/;
		
		/** @private */
		static private const EXTRA_SYMBOLS:RegExp = /=|\[|\]/g;
		
		/** @private */
		private const RETURN:Function = function(value:Number):Number { return value; }
		
		/** @private */
		protected var _round:Function = RETURN;
		
		/** @private */
		protected var _start:Number;
		
		/** @private */
		protected var _delta:Number;
		
		/** @private */
		protected function get round():Boolean
		{
			return _round == Math.round;
		}
		
		/** @private */
		protected function set round(value:Boolean):void
		{
			_round = value ? Math.round : RETURN;
		}
		
		/* INTERFACE orichalcum.animation.tweener.ITweener */
		
		public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			if (fromValueIfAny is Number)
			{
				_start = fromValueIfAny;
			}
			else if (fromValueIfAny is String)
			{
				const startAsString:String = fromValueIfAny as String;
				_start = parseFloat(FLOAT_DETECTOR.exec(startAsString.replace(EXTRA_SYMBOLS, '')));
				_round = ROUNDED_DETECTOR.test(startAsString) ? Math.round : RETURN;
			}
			else
			{
				throw new ArgumentError('Argument "start" passed to method NumberTweener.init() must be a Number or String number representation');
			}
			if (toValueIfAny is Number)
			{
				_delta = toValueIfAny - _start;
			}
			else if (toValueIfAny is String)
			{
				const endAsString:String = toValueIfAny as String;
				const endAsNumber:Number = parseFloat(FLOAT_DETECTOR.exec(endAsString.replace(EXTRA_SYMBOLS, '')));
				_delta = RELATIVE_DETECTOR.test(endAsString) ? endAsNumber : endAsNumber - fromValueIfAny;
				_round = ROUNDED_DETECTOR.test(endAsString) ? Math.round : RETURN;
			}
			else
			{
				throw new ArgumentError('Argument "end" passed to method NumberTweener.init() must be a Number or String number representation');
			}
		}
		
		public function tween(target:Object, property:String, progress:Number):*
		{
			return target[property] = interpolate(progress);
		}
		
		public function interpolate(progress:Number):*
		{
			return _round(_start + progress * _delta);
		}
		
		public function toString():String
		{
			return Strings.substitute('<number-tweener start="{0}" end="{1}" round="{2}">', _start, _start + _delta, _round == Math.round);
		}
		
		
	}

}
