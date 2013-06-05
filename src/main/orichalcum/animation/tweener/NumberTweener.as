package orichalcum.animation.tweener
{
	import orichalcum.utility.StringUtil;
	

	public class NumberTweener implements ITweener
	{
		//static private const isRounded:RegExp = /\[.*\]/;
		//static private const isRelative:RegExp = /\+|\-/;
		//static private const numberExtractor:RegExp = /[-+]?[0-9]*\.?[0-9]+/;
		//tweener.init(start, parseFloat(numberExtractor.exec(end)), isRounded.test(end), isRelative.test(end));
		
		// may want to refactor into decorator class or other class for efficiency
		static private const RETURN:Function = function(value:Number):Number { return value; }
		protected var _round:Function = RETURN;
		protected var _start:Number;
		protected var _distance:Number;
		
		/* INTERFACE orichalcum.animation.tweener.ITweener */
		
		//public function init(target:Object, property:String, parameters:Object):ITweener 
		//{
			//_start = target[property];
			//var end:Number = 
		//}
		
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
			return StringUtil.substitute('<number-tweener start="{0}" end="{1}" round="{2}">', _start, _start + _distance, _round == Math.round);
		}
		
	}

}
