package orichalcum.animation 
{
	import adobe.utils.CustomActions;
	import orichalcum.utility.StringUtil;

	internal class TweenProperty 
	{
		public var name:String
		public var start:*;
		public var end:*;
		public var ease:Function;
		public var previousValue:*;
		//private var _addFilter:Function = _updatePreviousAndReturn;
		private var _addFilter:Function = _return;
		private var _roundFilter:Function = _return;
		
		private const _return:Function = function(current:Number, next:Number):*
		{
			return next;
		}
		
		private const _updatePreviousAndReturn:Function = function(current:Number, next:Number):*
		{
			const delta:Number = next - previousValue;
			previousValue = next;
			return current + delta;
		}
		
		private const _roundAndReturn:Function = function(current:Number, next:Number):*
		{
			return Math.round(next);
		}
		
		public function TweenProperty(name:String, start:*, end:*, ease:Function, add:Boolean, round:Boolean) 
		{
			this.name = name;
			this.start = start;
			this.end = end;
			this.ease = ease;
			this.add = add;
			this.round = round;
			this.previousValue = start;
			
			trace(toString());
		}
		
		public function get add():Boolean
		{
			return _addFilter == _updatePreviousAndReturn;
		}
		
		public function set add(value:Boolean):void
		{
			_addFilter = value ? _updatePreviousAndReturn : _return;
		}
		
		public function get round():Boolean
		{
			return _roundFilter == _roundAndReturn;
		}
		
		public function set round(value:Boolean):void
		{
			_roundFilter = value ? _roundAndReturn : _return;
		}
		
		/**
		 * For a boolean tween this is easy just return the setter value when 
		 */
		public function tween(ease:Function, value:*, position:Number, duration:*):*
		{
			//var current:Number = _roundFilter(0, (this.ease == null ? ease : this.ease)(position, start, end - start, duration));
			//var delta:Number = current - previousValue;
			//var newValue:Number = value + delta;
			
			//trace('position:', position.toFixed(1), 'current', value, 'previous', previousValue, 'delta', delta.toFixed(1), 'new', newValue);
			
			//previousValue = current;
			//return newValue;
			
			return _addFilter(value, _roundFilter(0, (this.ease == null ? ease : this.ease)(position, start, end - start, duration)));
		}
		
		public function toString()
		{
			return StringUtil.substitute('<property name="{0}" start="{1}" end="{2}" add="{3}" round="{4}">', name, start, end, add, round);
		}
	}

}