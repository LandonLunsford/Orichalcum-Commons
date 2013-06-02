package orichalcum.animation
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;
	import orichalcum.utility.FunctionUtil;
	
	/**
	 * Requirements
	 * 1. auto play on adjustement of to values
	 * 2. add continue()
	 * 3. add masking ints to stack boolean values and shrink data footprint
	 * 4. add onActivate, onDeactivate
	 */
	
	[Event(name = "activate", type = "flash.events.Event")]
	
	[Event(name = "deactivate", type = "flash.events.Event")]
	
	[Event(name = "change", type = "flash.events.Event")]
	
	[Event(name = "complete", type = "flash.events.Event")]
	
	[Event(name = "yoyo", type = "flash.events.Event")]
	
	public class Tween extends EventDispatcher
	{
		
		{
			_currentTime = getTimer();
			_enterFrameEventDispatcher.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		/* @private */
		static private function _onEnterFrame(event:Event):void
		{
			const previousTime:Number = _currentTime;
			_currentTime = getTimer();
			
			if (pauseAll) return;
			
			_deltaTime = (_currentTime - previousTime) * timeScale * 0.001;
		}
		
		/* @private */
		static private const NULL_TARGET:Object = new _NullProxy; // should be a proxy to nothing that sets no state
		
		/* @private */
		static private var _currentTime:Number;
		
		/* @private */
		static private var _deltaTime:Number;
		
		/* @private */
		static private var _tweens:Array = [];
		
		static public var timeScale:Number = 1;
		static public var pauseAll:Boolean;
		static public var defaultEase:Function = Ease.quadOut;
		static public var defaultDispatchEvents:Boolean;
		private var _target:Object;
		private var _properties:Array = [];
		private var _position:Number = 0; /* time */
		private var _progress:Number = 0; /* percent */
		private var _previousPosition:Number = 0;
		private var _duration:Number = 0; /* duration of 1 iteration */
		private var _delay:Number = 0;
		private var _repeats:Number = 0;
		private var _onActivate:Function = FunctionUtil.noop;
		private var _onDeactivate:Function = FunctionUtil.noop;
		private var _onInit:Function = FunctionUtil.noop;
		private var _onChange:Function = FunctionUtil.noop;
		private var _onYoyo:Function = FunctionUtil.noop;
		private var _onComplete:Function = FunctionUtil.noop;
		private var _ease:Function = defaultEase;
		private var _isPlaying:Boolean; 
		private var _yoyo:Boolean;
		public var autoPlay:Boolean = true;
		public var dispatchEvents:Boolean = defaultDispatchEvents;
		public var timeScale:Number = 1;
		public var useFrames:Boolean;
		
		
		/**
		 * holds yoyo value
		 * positive for forward
		 * negative for backward
		 * scale 1 by default
		 * scale 2 for yoyo
		 * @private
		 */
		private var _step:Number = 1;
		
		public function Tween(...args)
		{
			switch (args.length)
			{
				case 1: _init(null, 0, args[0]); break;
				case 2: _init(args[0], 0, args[1]); break;
				case 3: _init(args[0], args[1], args[2]); break;
			}
		}
		
		/* INTERFACE orichalcum.animation.ITween */
		
		public function get target():Object 
		{
			return _target;
		}
		
		public function set target(value:Object):void 
		{
			_target = value == null ? NULL_TARGET : value;
		}
		
		public function get position():Number
		{
			return _position;
		}
		
		public function set position(value:Number):void
		{
			_setPosition(value, false);
		}
		
		public function get progress():Number 
		{
			return _position / _duration;
		}
		
		public function set progress(value:Number):void 
		{
			_setPosition(_duration * value, false);
		}
		
		public function get duration():Number 
		{
			return _duration;
		}
		
		public function set duration(value:Number):void 
		{
			_duration = value;
		}
		
		public function get delay():Number 
		{
			return _delay;
		}
		
		public function set delay(value:Number):void 
		{
			if (_position <= 0) {
				_position = -value;
			}
			_delay = value;
		}
		
		public function get yoyo():Boolean 
		{
			return _yoyo;
		}
		
		public function set yoyo(value:Boolean):void 
		{
			_yoyo = value;
		}
		
		public function get repeats():Number 
		{
			return _repeats;
		}
		
		public function set repeats(value:Number):void 
		{
			_repeats = value;
		}
		
		public function get onActivate():Function 
		{
			return _onActivate;
		}
		
		public function set onActivate(value:Function):void 
		{
			_onActivate = value == null ? FunctionUtil.noop : value;
		}
		
		public function get onDeactivate():Function 
		{
			return _onDeactivate;
		}
		
		public function set onDeactivate(value:Function):void 
		{
			_onDeactivate = value == null ? FunctionUtil.noop : value;
		}
		
		public function get onInit():Function 
		{
			return _onInit;
		}
		
		public function set onInit(value:Function):void 
		{
			_onInit = value == null ? FunctionUtil.noop : value;
		}
		
		public function get onChange():Function 
		{
			return _onChange;
		}
		
		public function set onChange(value:Function):void 
		{
			_onChange = value == null ? FunctionUtil.noop : value;
		}
		
		public function get onYoyo():Function 
		{
			return _onYoyo;
		}
		
		public function set onYoyo(value:Function):void 
		{
			_onYoyo = value == null ? FunctionUtil.noop : value;
		}
		
		public function get onComplete():Function 
		{
			return _onComplete;
		}
		
		public function set onComplete(value:Function):void 
		{
			_onComplete = value == null ? FunctionUtil.noop : value;
		}
		
		public function get ease():Function 
		{
			return _ease;
		}
		
		public function set ease(value:Function):void 
		{
			_ease = value == null ? defaultEase : value;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		// INTERNAL
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function get _iterations():Number
		{
			return _repeats + 1;
		}
		
		private function _init(target:Object = null, duration:Number = 0, to:Object = null):void
		{
			this.target = target;
			this.duration = duration;
			
			for (var property:String in to)
			{
				if (property in this)
				{
					this[property] = to[property];
					delete to[property];
				}
				else if (property in target)
				{
					var toValue:* = to[property];
					var add:Boolean;
					var round:Boolean;
					var ease:Function;
					var start:* = target[property];
					var end:* = toValue;
					
					if (!(toValue is Number) && !(toValue is Boolean) && !(toValue is String) && toValue is Object)
					{
						/*
						 * API
						 * property: value
						 * property: String
						 * property: Object
						 * 		{to:Number|String,round:Boolean,add:Boolean,ease:Function}
						 */
						end = toValue.to;
						add = toValue.add;
						round = toValue.round;
						ease = toValue.ease;
					}
					
					var tweener:TweenProperty;
					
					if (end is Boolean)
					{
						// differenet strategy (no easing, no adding, no rounding
					}
					else if (end is Number)
					{
						tweener = new TweenProperty(property, start, end, ease, add, round);
					}
					else if (end is String)
					{
						// relative measures
					}
					 
					_properties[_properties.length] = tweener;
				}
				else
				{
					delete to[property];
				}
			}
			
			autoPlay && replay();
		}
		
		private function _setPosition(value:Number, jump:Boolean = false, supressCallbacks:Boolean = false):void
		{
			trace('prev', _position, 'curr', value);
			yoyo
				? _setPositionYoyo(value, jump, supressCallbacks)
				: _setPositionNormal(value, jump, supressCallbacks);
			_previousPosition = _position;
		}
		
		private function _setPositionNormal(value:Number, jump:Boolean = false, supressCallbacks:Boolean = false):void
		{
			var maxPosition:Number = _duration;
			_position = value > maxPosition ? maxPosition : value;
			
			var passedStart:Boolean =  (_previousPosition <= 0 && _position >= 0) || (_previousPosition >= 0 && _position <= 0);
			var isMiddle:Boolean = _position > 0 && _position != _previousPosition;
			
			if (passedStart)
			{
				_onInitHandler(jump, supressCallbacks);
			}
			if (isMiddle)
			{
				for each(var property:TweenProperty in _properties)
				{
					target[property.name] = property.tween(ease, target[property.name], _position, _duration);
				}
				_onChangeHandler(jump, supressCallbacks);
			}
			
			if (_position == maxPosition && --repeats == -1)
			{
				_onCompleteHandler(jump, supressCallbacks);
			}
		}
		
		private function _setPositionYoyo(value:Number, jump:Boolean = false, supressCallbacks:Boolean = false):void
		{
			var maxPosition:Number = _duration;
			_position = value > maxPosition ? maxPosition : value;
			
			if (_step < 0 && _position < 0)
				_position = 0;
			
			//var isMoving:Boolean = true;
			var passedStart:Boolean = (_previousPosition < 0 && _position >= 0) || (_previousPosition > 0 && _position <= 0);
			var isMiddle:Boolean = _position >= 0 && _position != _previousPosition;
			
			if (_step > 0 && passedStart)
			{
				_onInitHandler(jump, supressCallbacks);
			}
			else if (isMiddle)
			{
				for each(var property:TweenProperty in _properties)
				{
					target[property.name] = property.tween(ease, target[property.name], _position, _duration);
				}
				
				_onChangeHandler(jump, supressCallbacks);
			}
			
			if (_position == maxPosition)
			{
				_onYoyoHandler(jump, supressCallbacks);
			}
			
			if (_step < 0 && _position == 0)
			{
				reverse();
				
				repeats--;
				
				if (repeats >= 0) 
				{
					gotoAndPlay(0);
				}
				else if (repeats == -1)
				{
					_onCompleteHandler(jump, supressCallbacks);
				}
				
			}
		}
		
		private function _onInitHandler(jump:Boolean, supressCallbacks:Boolean):void 
		{
			//trace('onInit');
			
			if (supressCallbacks) return;
			_onInit.length == 1 ? _onInit(jump) : _onInit();
			dispatchEvents && dispatchEvent(new Event(Event.INIT));
		}
		
		private function _onChangeHandler(jump:Boolean, supressCallbacks:Boolean):void 
		{
			//trace('onChange');
			
			if (supressCallbacks) return;
			_onChange.length == 1 ? _onChange(jump) : _onChange();
			dispatchEvents && dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function _onYoyoHandler(jump:Boolean, supressCallbacks:Boolean):void 
		{
			//trace('onYoyo');
			reverse();
			if (supressCallbacks) return;
			_onYoyo.length == 1 ? _onYoyo(jump) : _onYoyo();
			dispatchEvents && dispatchEvent(new Event('yoyo'));
		}
		
		private function _onCompleteHandler(jump:Boolean, supressCallbacks:Boolean):void 
		{
			//trace('onComplete');
			
			stop();
			if (supressCallbacks) return;
			_onComplete.length == 1 ? _onComplete(jump) : _onComplete();
			dispatchEvents && dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function _tick(event:Event):void 
		{
			//_setPosition(_position + (useFrames ? Tween.timeScale : _deltaTime) * timeScale * _step); // standard
			_setPosition(_position + (useFrames ? Tween.timeScale : _deltaTime) * timeScale * _step * (yoyo && _position >= 0 ? 2:1)); // cool duration feature
		}
		
		private function _setIsPlaying(value:Boolean, supressCallbacks:Boolean = false):void
		{
			if (_isPlaying == value) return;
			_isPlaying = value;
			if (value)
			{
				_enterFrameEventDispatcher.addEventListener(Event.ENTER_FRAME, _tick);
				
				if (supressCallbacks) return;
				_onActivate.length == 1 ? _onActivate(this) : _onActivate();
				dispatchEvents && dispatchEvent(new Event(Event.ACTIVATE));
			}
			else
			{
				_enterFrameEventDispatcher.removeEventListener(Event.ENTER_FRAME, _tick);
				
				if (supressCallbacks) return;
				_onDeactivate.length == 1 ? _onDeactivate(this) : _onDeactivate();
				dispatchEvents && dispatchEvent(new Event(Event.DEACTIVATE));
			}
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC INTERFACE
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function set isPlaying(value:Boolean):void
		{
			_setIsPlaying(value);
		}
		
		public function get isPaused():Boolean
		{
			return !_isPlaying;
		}
		
		public function get isPlayingForward():Boolean
		{
			return _step > 0;
		}
		
		public function get isPlayingBackwards():Boolean
		{
			return _step < 0;
		}
		
		public function toggle(supressCallbacks:Boolean = false):void
		{
			_setIsPlaying(!_isPlaying, supressCallbacks);
		}
		
		public function play(supressCallbacks:Boolean = false):void
		{
			_setIsPlaying(true, supressCallbacks);
		}
		
		public function stop(supressCallbacks:Boolean = false):void
		{
			_setIsPlaying(false, supressCallbacks);
		}
		
		public function end(supressCallbacks:Boolean = false):void
		{
			gotoAndStop(1, supressCallbacks);
		}
		
		public function reset(supressCallbacks:Boolean = false):void
		{
			_previousPosition = -_delay - 1; // for onInit() to fire
			gotoAndStop(-_delay, supressCallbacks);
		}
		
		public function replay(supressCallbacks:Boolean = false):void
		{
			_previousPosition = -_delay - 1; // for onInit() to fire
			gotoAndPlay(-_delay, supressCallbacks);
		}
		
		public function gotoAndPlay(position:Number, supressCallbacks:Boolean = false):void
		{
			_setPosition(position, true, supressCallbacks);
			play();
		}
		
		public function gotoAndStop(position:Number, supressCallbacks:Boolean = false):void
		{
			_setPosition(position, true, supressCallbacks);
			stop();
		}
		
		public function reverse():void
		{
			_step = -_step;
		}
		
	}

}