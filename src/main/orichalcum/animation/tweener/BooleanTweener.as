package orichalcum.animation.tweener
{
	import orichalcum.utility.StringUtil;

	public class BooleanTweener implements ITweener
	{
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
			return target[property] = isEnd ? _start : _end;
		}

		public function toString():String
		{
			return StringUtil.substitute('<boolean-tweener start="{0}" end="{1}">', _start, _end);
		}
	}

}
