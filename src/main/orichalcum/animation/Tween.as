package orichalcum.animation
{
	import com.orichalcum.constants.Ease;
	import com.orichalcum.core.Process;
	
	/**
	 * Tween Facade
	 * @TODO mimic API of http://www.greensock.com/as/docs/tween/com/greensock/TweenMax.html
	 * @TODO cache 'change' or 'distance' variable so its not calculated at updateTime -- minor efficiency boost
	 * @TODO support delay until tween start
	 * @TODO support boolean tweens
	 * @TODO support visible swap
	 * @TODO support mouseEnabled swap
	 * @TODO support selective 'snapToPixel' for x,y
	 * @TODO support 'paused' initial setting
	 * @TODO default to overwrite tweening -- support non-intrusive tweening, for specified properties ie(x,y)
	 * 
	 * @author Landon Lunsford
	 */
	
	public class Tween extends Process
	{
		public var target:Object;
		public var snap:Boolean;
		public var yoyo:Boolean;
		private var _to:Object;
		private var _from:Object;
		private var _previous:Object;
		private var _ease:Function = Ease.quadOut;
		private var _progressFunction:Function = getProgress;
		
		public function get duration():Number { return interval; }
		public function set duration(value:Number):void { interval = value; }
		public function get ease():Function { return _ease; }
		public function set ease(value:Function):void { _ease = value; }
		public function get vars():Object { return _to ||= {}; }
		
		public function Tween(target:Object, duration:Number, vars:Object = null)
		{
			this.target = target;
			this.duration = duration;
			_to = vars;
			_from = {};
			_previous = {};
		}
		
		override public function dispose():void 
		{
			target = null;
			_ease = null;
			_progressFunction = null;
			super.dispose();
		}
		
		override public function start():void 
		{
			initialize();
			super.start();
		}
		
		public function finish():void
		{
			time = duration;
			onUpdate();
			onComplete();
		}
		
		public function reverse():void
		{
			for (var property:String in _previous)
			{
				var temporary:Number = _from[property];
				_from[property] = _to[property];
				_to[property] = temporary;
			}
		}
		
		public function reflect():void
		{
			reverse();
			_ease = Ease.getInverse(_ease);
		}

		override protected function onUpdate():void
		{
			render();
			super.onUpdate();
		}

		override protected function onIteration():void 
		{
			/** @ALPHA */
			if (_to.alpha != undefined)
			{
				target.alpha = _to.alpha;
			}
			
			if (yoyo)
			{
				time = 0;
				reflect();
			}
			
			//dispatchEvent(REPEAT_EVENT);
		}
		
		protected function initialize():void
		{
			
			for (var property:String in _to)
			{
				if (property in this)
				{
					this[property] = _to[property];
					delete _to[property];
				}
				else if (property in target)
				{
					_from[property] = _previous[property] = target[property];
				}
				else
				{
					delete _to[property];
				}
			}

			if (isNaN(repeats))
			{
				repeats = 0;
			}
			
			if (yoyo && repeats < 1)
			{
				repeats = 1;
			}
			
			_progressFunction = snap ? getRoundedProgress : getProgress;
		}
		
		protected function render():void
		{
			
			for (var property:String in _to)
			{
				// NO OVERWRITE ALGORITHM
				var current:Number = _progressFunction(_from[property], _to[property] - _from[property]);
				target[property] += current - _previous[property];
				_previous[property] = current;
			}
		}

		protected function getProgress(start:Number, distance:Number):Number
		{
			return _ease(time, start, distance, duration);
		}
		
		protected function getRoundedProgress(start:Number, distance:Number):Number
		{
			return Math.round(getProgress(start, distance));
		}
		
	}

}
