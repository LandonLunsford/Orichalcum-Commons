package orichalcum.animation 
{
	import adobe.utils.CustomActions;
	import orichalcum.utility.StringUtil;

	internal class NumberTweener implements ITweener
	{
		public var name:String
		public var start:Number;
		public var end:Number;
		private var _previousValue:Number;
		private var _roundFilter:Function = RETURN;
		private const RETURN:Function = function(next:Number):Number { return next; }
		private const ROUND:Function = function(next:Number):Number { return Math.round(next); }
		
		public function NumberTweener(name:String, start:Number, end:Number, relative:Boolean, round:Boolean) 
		{
			this.name = name;
			this.start = start;
			this.end = relative ? start + end : end;
			this._roundFilter = round ? ROUND : RETURN;
			this._previousValue = start;
			
			trace(this);
		}
		
		public function tween(progress:Number, target:Object):void
		{
			const nextValue:Number = _roundFilter(start + progress * (end - start));
			const delta:Number = nextValue - _previousValue;
			_previousValue = nextValue;
			target[name] = target[name] + delta;
		}
		
		public function toString():String
		{
			return StringUtil.substitute('<property name="{0}" start="{1}" end="{2}" round="{3}" relative="{4}">', name, start, end, _roundFilter == ROUND, '?');
		}
	}

}