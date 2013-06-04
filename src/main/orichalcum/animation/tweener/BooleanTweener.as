package orichalcum.animation.tweener
{
	import orichalcum.utility.StringUtil;

	public class BooleanTweener implements ITweener
	{
		private var _start:Boolean;
		private var _end:Boolean;

		public function init(start:Boolean, end:Boolean):ITween
		{
			_start = start;
			_end = end;
			return this;
		}

		/**
		 * For a boolean tween this is easy just return the setter value when
		 */
		public function tween(target:Object, property:String, progress:Number):void
		{
			target[property] = progress < 1 ? _start : _end;
		}

		public function toString():String
		{
			return StringUtil.substitute('<boolean-tweener end="{2}">', _end);
		}
	}

}
