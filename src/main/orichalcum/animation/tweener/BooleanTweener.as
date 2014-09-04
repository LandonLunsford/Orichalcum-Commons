package orichalcum.animation.tweener
{
	import orichalcum.utility.Strings;

	public class BooleanTweener implements ITweener
	{
		
		/** @private */
		static private const THRESHOLD:Number = 1 - 0.0001;
		
		/** @private */
		private var _start:Boolean;
		
		/** @private */
		private var _end:Boolean;
		
		/* INTERFACE orichalcum.animation.tweener.ITweener */
		
		public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			_start = fromValueIfAny;
			_end = toValueIfAny;
		}
		
		public function tween(target:Object, property:String, progress:Number):*
		{
			//return isEnd ? _end : _start; // not true for yoyo, complete can be progress 0
			target[property] = interpolate(progress);
		}
		
		public function interpolate(progress:Number):*
		{
			return progress > THRESHOLD ? _end : _start;
		}

		public function toString():String
		{
			return Strings.substitute('<boolean-tweener start="{0}" end="{1}">', _start, _end);
		}
	}

}
