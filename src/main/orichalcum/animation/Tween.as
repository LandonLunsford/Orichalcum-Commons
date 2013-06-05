package orichalcum.animation
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import orichalcum.animation.tweener.BooleanTweener;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.utility.FunctionUtil;
	import orichalcum.utility.ObjectUtil;
	
	/**
	 * Requirements
	 * 1. auto play on adjustement of to values
	 * 2. add continue()
	 * 3. add masking ints to stack boolean values and shrink data footprint
	 * 4. [additive tweens should be default, relative tweens are specified]
	 * 
	 * GOTCHA -- cannot capture "init" event with addEventListener() when autoPlay is true because it will fire before the listener is added
	 */
	
	[Event(name = "activate", type = "flash.events.Event")]
	
	[Event(name = "deactivate", type = "flash.events.Event")]
	
	[Event(name = "change", type = "flash.events.Event")]
	
	[Event(name = "complete", type = "flash.events.Event")]
	
	[Event(name = "yoyo", type = "flash.events.Event")]
	
	public class Tween extends EventDispatcher implements ITween
	{
		/** @private */
		static private const EPSILON:Number = 0.0001;
		
		/** @private */
		static private const _tweenersByProperty:Object = {};
		
		/** @private */
		static private const _tweenersByClass:Object = {'Number': NumberTweener, 'Boolean': BooleanTweener};
		
		{
			_currentTime = getTimer();
			_enterFrameEventDispatcher.addEventListener(Event.ENTER_FRAME, _integrateTweens);
		}
		
		/** @private */
		static private function _integrateTweens(event:Event):void
		{
			const previousTime:Number = _currentTime;
			_currentTime = getTimer();
			_deltaTime = pauseAll ? 0 : (_currentTime - previousTime) * _timeScale;
		}
		
		/** @private */
		static private function _createTweener(propertyName:String, propertyValue:*):ITweener
		{
			const tweenerForProperty:ITweener = _tweenersByProperty[propertyName];
			return tweenerForProperty
				? new tweenerForProperty
				: new _tweenersByClass[getQualifiedClassName(propertyValue)];
		}
		
		static public function install(tweener:ITweener, triggers:*):void
		{
			if (tweener == null)
			{
				throw new ArgumentError('Argument "tweener" passed to method "install" of class "orichalcum.animation.Tween" must not be null.');
			}
			else if (triggers is String)
			{
				_tweenersByProperty[triggers] = tweener;
			}
			else if (triggers is Class)
			{
				_tweenersByClass[getQualifiedClassName(triggers)] = tweener;
			}
			else if (triggers is Array || triggers is Vector.<String>)
			{
				for each(var trigger:String in triggers)
					install(tweener, trigger);
			}
			else
			{
				throw new ArgumentError('Argument "tweener" passed to method "install" of class "orichalcum.animation.Tween" must be one of the following types: String, Class, Array, Vector.<String>, Vector.<Class>.');
			}
		}
		
		//
		//static public function pauseTweensOf(target:Object):void
		//{
			//
		//}
		//
		//static public function playTweensOf(target:Object):void
		//{
			//
		//}
		
		static private var _timeScale:Number = 0.001; // optimization
		
		static public function get timeScale():Number 
		{
			return _timeScale * 1000;
		}
		
		static public function set timeScale(value:Number):void 
		{
			_timeScale = value * 0.001; 
		}
		
		/** @private */
		static private const NULL_TARGET:Object = new _NullProxy;
		
		/** @private */
		static private var _currentTime:Number;
		
		/** @private */
		static private var _deltaTime:Number;
		
		/** @private */
		static private var _tweensByTarget:Dictionary = new Dictionary(true);
		
		/** @private */
		static private var _tweens:Dictionary = new Dictionary(true);
		
		static public var pauseAll:Boolean;
		static public var defaultEase:Function = Ease.quadOut;
		
		/* @private */
		private var _target:Object;
		
		/**
		 * The duration of one iteration
		 * If yoyo is set to true this duration includes the forward and backward portion of the iteration
		 * 
		 * @private
		 */
		private var _duration:Number = 0;
		
		/** @private */
		private var _delay:Number = 0;
		
		/** @private */
		private var _repeats:Number = 0;
		
		/** @private */
		private var _onInit:Function = FunctionUtil.noop;
		
		/** @private */
		private var _onChange:Function = FunctionUtil.noop;
		
		/** @private */
		private var _onYoyo:Function = FunctionUtil.noop;
		
		/** @private */
		private var _onComplete:Function = FunctionUtil.noop;
		
		/** @private */
		private var _ease:Function = defaultEase;
		
		/** @private */
		private var _isPlaying:Boolean;
		
		/** @private */
		private var _yoyo:Boolean;
		
		/** @private */
		private var _next:ITween;
		
		/** @private */
		private var _autoPlay:Boolean = true;
		
		/** @private */
		private var _timeScale:Number = 1;
		
		/** @private */
		private var _useFrames:Boolean;
		
		/** @private */
		private var _to:Object = {};
		
		/** @private */
		private var _position:Number = 0;
		
		/** @private */
		private var _previousPosition:Number = -EPSILON;
		
		/**
		 * Animation class
		 */
		
		static public function to(...args):ITween
		{
			const tween:Tween = new Tween;
			tween._construct(args);
			return _add(tween as ITween);
		}
		
		static public function from(...args):ITween
		{
			const tween:Tween = new Tween;
			tween._construct(args, true);
			return _add(tween as ITween);
		}
		
		static private function _add(tween:ITween):ITween
		{
			const tweensOfTarget:Array = _tweensByTarget[tween.target] ||= [];
			tweensOfTarget.indexOf(tween) < 0 && (tweensOfTarget[tweensOfTarget.length] = tween);
			return tween;
		}
		
		static private function _remove(tween:ITween):ITween
		{
			const tweensOfTarget:Array = _tweensByTarget[tween.target];
			var index:int;
			tweensOfTarget && (index = tweensOfTarget.indexOf(tween)) >= 0 && tweensOfTarget.splice(index, 1);
			return tween;
		}
		
		//static public function delay(
		
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
			_construct(args);
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		// INTERFACE orichalcum.animation.ITween
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
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
			_setPosition(value, true);
		}
		
		public function get progress():Number 
		{
			const endPosition:Number = _endPosition;
			return endPosition == 0 ? 1 : _position / _endPosition;
		}
		
		public function set progress(value:Number):void 
		{
			_setPosition(_endPosition * value, false);
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
		
		public function get timeScale():Number 
		{
			return _timeScale;
		}
		
		public function set timeScale(value:Number):void 
		{
			_timeScale = value;
		}
		
		public function get autoPlay():Boolean 
		{
			return _autoPlay;
		}
		
		public function set autoPlay(value:Boolean):void 
		{
			_autoPlay = value;
		}
		
		public function get useFrames():Boolean 
		{
			return _useFrames;
		}
		
		public function set useFrames(value:Boolean):void 
		{
			_useFrames = value;
		}
		
		public function get iterations():Number 
		{
			return _repeats + 1;
		}
		
		public function next(...args):ITween 
		{
			throw new Error();
			return this;
		}
		
		public function to(...args):ITween 
		{
			_construct(args);
			return this;
		}
		//
		//public function delay(duration:Number):ITween 
		//{
			//thow new Error();
		//}
		//
		public function goto(position:Number, supressCallbacks:Boolean = false):void 
		{
			_setPosition(position, true, supressCallbacks);
		}
		
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
		
		public function set isPaused(value:Boolean):void
		{
			isPlaying = !value;
		}
		
		//public function get isPlayingForward():Boolean
		//{
			//return _step > 0;
		//}
		//
		//public function get isPlayingBackwards():Boolean
		//{
			//return _step < 0;
		//}
		
		public function toggle():void
		{
			isPlaying = !isPlaying;
		}
		
		public function play():void
		{
			_setIsPlaying(true);
		}
		
		public function stop():void
		{
			_setIsPlaying(false);
		}
		
		public function end(supressCallbacks:Boolean = false):void
		{
			gotoAndStop(_endPosition, supressCallbacks);
		}
		
		public function reset(supressCallbacks:Boolean = false):void
		{
			gotoAndStop(-_delay, supressCallbacks);
		}
		
		public function replay(supressCallbacks:Boolean = false):void
		{
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
		
		public function playBackwards(supressCallbacks:Boolean = false):void 
		{
			// this will make on complete fire first
			end(supressCallbacks);
			reverse();
			play();
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		// INTERNAL
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function _construct(args:Array, swap:Boolean = false):void
		{
			switch (args.length)
			{
				case 1: _initialize(null, 0, args[0], swap); break;
				case 2: _initialize(args[0], 0, args[1], swap); break;
				case 3: _initialize(args[0], args[1], args[2], swap); break;
			}
		}
		
		
		private function _initialize(target:Object = null, duration:Number = 0, to:Object = null, swap:Boolean = false):void
		{
			target = this.target = target;
			
			swap && ObjectUtil.swap(to, target);
			
			for (var property:String in to)
			{
				if (property in this)
				{
					this[property] = to[property];
				}
				else
				{
					const tweener:ITweener = _to[property] ||= _createTweener(property, target[property]);
					if (tweener)
					{
						tweener.init(this.target[property], to[property]);
					}
					else
					{
						delete _to[property];
					}
				}
			}
			
			if (this.duration <= 0) this.duration = duration;
			
			_to = to;
			_position = -delay;
			_previousPosition = _position - EPSILON;
			
			autoPlay && replay();
		}
		
		private function _setPosition(value:Number, jump:Boolean = false, supressCallbacks:Boolean = false):void
		{
			_previousPosition = _position;
			// something changed in here and now mhy numbers are incorrect
			var calculatedPosition:Number;
			
			jump && (_previousPosition = _position - EPSILON);
			
			const endPosition:Number = _endPosition;
			const isComplete:Boolean = value >= endPosition; //const isComplete:Boolean = value >= maximumPosition && _iterations > 0;
			
			if (isComplete)
			{
				if (_previousPosition == endPosition) return; // purpose?
				_position = endPosition;
				calculatedPosition = (yoyo && (iterations & 1)) ? 0 : _duration;
			}
			else
			{
				_position = Math.max(-delay, value);
				calculatedPosition = _position < 0 ? 0 : _position % _duration; // eficiency would be to only do modulo if repeats > 0
				if (yoyo)
				{
					const cycle:int = (_position / _duration) & 1;
					const previousCycle:int = (_previousPosition / _duration) & 1;
					const direction:Number = _position - _previousPosition;
					const isReflecting:Boolean = (cycle == (direction > 0) ? 1 : 0) && cycle != previousCycle;
					
					if (cycle) calculatedPosition = duration - calculatedPosition;
				}
			}
			
			const isChanged:Boolean = (_position >= 0 || _previousPosition >= 0) && _position != _previousPosition;
			
			if (isChanged)
			{
				const passedZero:Boolean = (_position >= 0 && _previousPosition < 0) || (_position <= 0 && _previousPosition > 0);
				
				passedZero && _onInitHandler(jump, supressCallbacks);
				
				const progress:Number = (_duration == 0 && _position >= 0) ? 1 : ease(calculatedPosition / _duration, 0, 1, 1);
				
				for (var property:String in _to)
					_to[property].tween(target, property, progress, passedZero, isComplete);
					
				_onChangeHandler(jump, supressCallbacks);
			}
			
			isReflecting && _onYoyoHandler(jump, supressCallbacks);
			isComplete && _onCompleteHandler(jump, supressCallbacks);
		}
		
		private function _onInitHandler(jump:Boolean, supressCallbacks:Boolean):void 
		{
			if (supressCallbacks) return;
			_onInit.length == 1 ? _onInit(jump) : _onInit();
			hasEventListener(Event.INIT) && dispatchEvent(new Event(Event.INIT));
		}
		
		private function _onChangeHandler(jump:Boolean, supressCallbacks:Boolean):void 
		{
			if (supressCallbacks) return;
			_onChange.length == 1 ? _onChange(jump) : _onChange();
			hasEventListener(Event.CHANGE) && dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function _onYoyoHandler(jump:Boolean, supressCallbacks:Boolean):void 
		{
			if (supressCallbacks) return;
			_onYoyo.length == 1 ? _onYoyo(jump) : _onYoyo();
			hasEventListener(TweenEvent.YOYO) && dispatchEvent(new Event(TweenEvent.YOYO));
		}
		
		private function _onCompleteHandler(jump:Boolean, supressCallbacks:Boolean):void 
		{
			stop();
			if (supressCallbacks) return;
			_onComplete.length == 1 ? _onComplete(jump) : _onComplete();
			hasEventListener(Event.COMPLETE) && dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function get _endPosition():Number
		{
			return _duration * iterations * (yoyo ? 2 : 1);
		}
		
		private function _setIsPlaying(value:Boolean):void
		{
			if (_isPlaying == value) return;
			_isPlaying = value;
			if (value)
			{
				_enterFrameEventDispatcher.addEventListener(Event.ENTER_FRAME, _integrate);
			}
			else
			{
				_enterFrameEventDispatcher.removeEventListener(Event.ENTER_FRAME, _integrate);
			}
		}
		
		private function _integrate(event:Event):void 
		{
			// cool yoyo feature
			//trace(_position + (useFrames ? Tween.timeScale : _deltaTime) * timeScale * _step * (yoyo && _position >= 0 ? 2:1));
			pauseAll || _setPosition(_position + (useFrames ? Tween.timeScale : _deltaTime) * timeScale * _step * (yoyo && _position >= 0 ? 2:1));
		}
		
		
	}

}
