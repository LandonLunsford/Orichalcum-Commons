package orichalcum.animation.tweener
{
	import orichalcum.utility.StringUtil;

	public class BooleanTweener implements ITweener
	{
		
		/** @private */
		static private const THRESHOLD:Number = 1 - 0.0001;
		
		/** @private */
		private var _start:Boolean;
		
		/** @private */
		private var _end:Boolean;
		
		public function init(start:*, end:*):void
		{
			_start = start;
			_end = end;
		}
		
		public function tween(target:Object, property:String, progress:Number, isStart:Boolean, isEnd:Boolean):*
		{
			//return isEnd ? _end : _start; // not true for yoyo, complete can be progress 0
			return progress > THRESHOLD ? _end : _start;
		}

		public function toString():String
		{
			return StringUtil.substitute('<boolean-tweener start="{0}" end="{1}">', _start, _end);
		}
	}

}
