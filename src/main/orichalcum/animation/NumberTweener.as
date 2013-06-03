package orichalcum.animation 
{
	import adobe.utils.CustomActions;
	import orichalcum.utility.StringUtil;

	internal class NumberTweener implements ITweener
	{
		private const RETURN:Function = function(next:Number):Number { return next; }
		private const ROUND:Function = function(next:Number):Number { return Math.round(next); }
		private var _start:Number;
		public var end:Number;
		private var _previousValue:Number;
		private var _roundFilter:Function = RETURN;
		
		
		public function tween(target:Object, property:String, progress:Number):void
		{
			const nextValue:Number = _roundFilter(start + progress * (end - start));
			const delta:Number = nextValue - _previousValue;
			_previousValue = nextValue;
			target[property] = target[property] + delta;
		}
		
		public function toString():String
		{
			return StringUtil.substitute('<number-tweener name="{0}" start="{1}" end="{2}" round="{3}" relative="{4}">', '?', start, end, _roundFilter == ROUND, '?');
		}
		
		public function get round():Boolean 
		{
			return _roundFilter == ROUND;
		}
		
		public function set round(value:Boolean):void 
		{
			_roundFilter = value ? ROUND : RETURN;
		}
		
		public function get start():Number 
		{
			return _start;
		}
		
		public function set start(value:Number):void 
		{
			_start = value;
			_previousValue = value;
		}
	}

}