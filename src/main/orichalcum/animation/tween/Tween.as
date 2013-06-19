package orichalcum.animation.tween
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import orichalcum.animation.AnimationBase;
	import orichalcum.animation.tweener.BooleanTweener;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.core.Core;
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
	
	public class Tween extends AnimationBase implements ITween, IEventDispatcher
	{
	
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// CLASS
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public var pauseAll:Boolean;
		static public var defaultEase:Function = Ease.quadOut;
		
		/** @private */
		static private const EPSILON:Number = 0.0001;
		
		/** @private */
		static private const _tweenersByProperty:Object = {};
		
		/** @private */
		static private const _tweenersByClass:Object = {'int': NumberTweener, 'Number': NumberTweener, 'Boolean': BooleanTweener};
		
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
			const tweenerForProperty:Class = _tweenersByProperty[propertyName];
			
			trace(getQualifiedClassName(propertyValue));
			
			return tweenerForProperty
				? new tweenerForProperty
				: new _tweenersByClass[getQualifiedClassName(propertyValue)];
		}
		
		static public function install(tweener:Class, triggers:*):void
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
		
		/**
		 * MOVED TO CORE
		 */
		
		/** @private */
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
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		// STATIC FACTORIES
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function to(...args):ITween
		{
			return _create(args, false);
		}
		
		static public function from(...args):ITween
		{
			return _create(args, true);
		}
		
		/**
		 * API ideas
		 * Tween.getTweensOf(this).pause();
		 * Tween.commandTweensOf(target:Object, functionName:String, ...args)
		 */
		//static public function getTweensOf(target:Object):IPlayable // tween group that you can pause all of at once
		//{
			//
		//}
		//
		//static public function playTweensOf(target:Object):void
		//{
			//
		//}
		//
		//static public function removeTweensOf(target:Object):void
		//{
			//
		//}
		
		static private function _create(args:Array, from:Boolean = false):ITween
		{
			const tween:Tween = new Tween;
			tween._construct(args, from);
			
			// from or to needs to be dynamically generated at tween "init" time
			// need to look for tweens auto play param
			
			tween.play();
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
		
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// INSTANCE
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/** @private */
		private var _target:Object;
		
		/**
		 * The original tween parameters minus tween variables
		 * (target, duration, delay, useFrames, repeats, yoyo, timeScale, position, isPlaying, onInit, onChange, onYoyo, onComplete)
		 * @private
		 */
		private var _to:Object;
		
		/** 
		 * The property tweening delegates who perform the class or peroperty specific tweening
		 * @private
		 */
		private var _tweeners:Object = {};
		
		/**
		 * The duration of one iteration
		 * If yoyo is set to true this duration includes the forward and backward portion of the iteration
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
		private var _isPlaying:Boolean = false;
		
		/** @private */
		private var _yoyo:Boolean = false;

		/** @private */
		private var _timeScale:Number = 1;
		
		/** @private */
		private var _useFrames:Boolean = false;
		
		/** @private */
		private var _position:Number = 0;
		
		/** @private */
		private var _previousPosition:Number = -EPSILON;
		
		/**
		 * holds yoyo value
		 * positive for forward
		 * negative for backward
		 * scale 1 by default
		 * scale 2 for yoyo
		 * @private
		 */
		private var _step:Number = 1;
		
		/**
		 * Used during tween initialization to determine whether it is a "to" or "from" tween
		 * @private
		 */
		private var _from:*;
		
		/** @private */
		private var _isInitialized:Boolean = false;
		
		/** @private */
		private var _eventDispatcher:IEventDispatcher;
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		// Constructor
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
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
			_duration = value < 0 ? 0 : value;
		}
		
		public function get delay():Number 
		{
			return _delay;
		}
		
		public function set delay(value:Number):void 
		{
			_delay = value < 0 ? 0 : -value;
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
		
		public function get useFrames():Boolean 
		{
			return _useFrames;
		}
		
		public function set useFrames(value:Boolean):void 
		{
			_useFrames = value;
		}
		
		public function get from():*
		{
			return _from;
		}
		
		public function set from(value:*):void
		{
			const type:String = typeof(value);
			if (type != 'boolean' || type != 'object')
				throw new ArgumentError;
			_from = value;
		}
		
		public function get iterations():Number 
		{
			return _repeats + 1;
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		// public function set isPlaying(value:Boolean):void
		// {
			// will not trigger onInit as is -- position must be set
			//_setIsPlaying(value, false);
			// return value ? play() : pause();
		// }
		
		public function get isPaused():Boolean
		{
			return !_isPlaying;
		}
		
		// public function set isPaused(value:Boolean):void
		// {
			// isPlaying = !value;
		// }
		
		// public function get isPlayingForward():Boolean
		// {
			// return _isPlaying && _position > _previousPosition;
		// }
		
		// public function get isPlayingBackwards():Boolean
		// {
			// return _isPlaying && _position < _previousPosition;
		// }
		
		public function play(triggerCallbacks:Boolean = true):ITween
		{
			_setIsPlaying(true);
		
			// this is movie feature but is it a tween feature?
			// if (_isAtEnd)
			// {
				// _setPosition(-_delay, true, triggerCallbacks); // to trigger onInit
			// }
			// else
			// {
				_setPosition(_position, true, triggerCallbacks); // to trigger onInit
			// }
			
			return this;
		}
		
		public function replay(triggerCallbacks:Boolean = true):ITween
		{
			_setIsPlaying(true);
			return beginning(triggerCallbacks);
		}
		
		public function pause():ITween
		{
			_setIsPlaying(false);
			return this;
		}
		
		public function toggle(triggerCallbacks:Boolean = true):ITween
		{
			return _isPlaying ? stop() : play(triggerCallbacks);
		}
		
		public function stop():ITween
		{
			_setIsPlaying(false);
			_setPosition(_startPosition, true, false);
			return this;
		}
		
		public function goto(position:Number, triggerCallbacks:Boolean = true):ITween 
		{
			_setPosition(position, true, triggerCallbacks);
			return this;
		}
		
		public function gotoAndPlay(position:Number, triggerCallbacks:Boolean = true):ITween
		{
			_setIsPlaying(true);
			_setPosition(position, true, triggerCallbacks);
			return this;
		}
		
		public function gotoAndStop(position:Number, triggerCallbacks:Boolean = true):ITween
		{
			_setIsPlaying(false);
			_setPosition(position, true, triggerCallbacks);
			return this;
		}
		
		public function beginning(triggerCallbacks:Boolean = true):ITween
		{
			if (_isAtBeginning) return this;
		
			_setPosition(_startPosition, true, triggerCallbacks);
			return this;
		}
		
		public function end(triggerCallbacks:Boolean = true):ITween
		{
			if (_isAtEnd) return this;
		
			//_setIsPlaying(false); triggered on position set
			_setPosition(_endPosition, true, triggerCallbacks);
			
			return this;
		}
		
		public function reverse():ITween
		{
			_step = -_step;
			return this;
		}
		
		public function playBackwards(triggerCallbacks:Boolean = true):ITween 
		{
			// this will make on complete fire first
			_step = -Math.abs(_step);
			return gotoAndPlay(_endPosition, true, triggerCallbacks); // may be stopped by position set
		}
		
		public function to(...args):ITween 
		{
			_construct(args);
			return this;
		}
		
		/* INTERFACE flash.events.IEventDispatcher */
		
		private function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher ||= new EventDispatcher;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean 
		{
			return eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean 
		{
			return eventDispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean 
		{
			return eventDispatcher.willTrigger(type);
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// INTERNAL
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function _construct(args:Array, from:Boolean = false):void
		{
			switch (args.length)
			{
				case 1: _initializeSettings(null, 0, args[0], from); break;
				case 2: _initializeSettings(args[0], 0, args[1], from); break;
				case 3: _initializeSettings(args[0], args[1], args[2], from); break;
			}
		}
		
		/*
		
		:: ObjectUtil
		
		static public function drain(...objects):Object
		{
			if (objects.length == 0)
				return {};
				
			if (objects.length == 1)
				return objects[0];
			
			var target:Object = objects[0];
			
			for (var i:int = 1; i < objects.length; i++)
			{
				var object:Object = objects[i];
			
				if (object == null) continue;
				
				for (var key:String in object)
				{
					if (key in target)
					{
						target[key] = object[key];
						delete object[key];
					}
				}
			}
		}
		 */
		
		private function _initializeSettings(target:Object = null, duration:Number = 0, to:Object = null, from:Boolean = false):void
		{
			this.target = target;
			this.duration = duration;
			
			ObjectUtil.drain(this, to);
			
			_from ||= from;
			_position = _delay;
			_previousPosition = _position - EPSILON;
		}
			
		private function _initialize():void
		{
			/**
			 needs to be invalidated when pause set false ?
			 needs to consider now from:[true|{}]
			 */
			_isInitialized = true;
			
			/*
			
			if (_from && typeof(_from) == 'boolean')
				return _initializeAsDynamicFromTween();
			
			if (_from && typeof(_from) == 'object')
				return _initializeStaticFromTween();
			
			return _initializeToTween();
			
			if (_from)
			{
				if (typeof(_from) == 'boolean')
				{
					set tweeners end to target[p] right now to _to[p] ? or set runBackwards = true?
					
					return _initializeDynamicFromTween();
				}
				else if (typeof(_from) == 'object')
				{
					set all target[p] to _from[p] and begin
					
					return _initializeStaticFromTween();
				}
				else
				{
					_from = false;
					
					// normal procedure
				}
			}
			else
			{
				// normal procedure
				
				
				return _initializeToTween();
			}
			*/
			
			
			_from && ObjectUtil.swap(target, _to);
			
			for (var propertyName:String in _to)
			{
				const tweener:ITweener = _tweeners[property] ||= _createTweener(property, target[property]);
				
				if (tweener)
				{
					tweener.init(target[property], _to[property]);
				}
				else
				{
					delete _to[property];
				}
			}
		}
		
		private function _setPosition(value:Number, jump:Boolean = false, triggerCallbacks:Boolean = true):void
		{
			return _setPosition(_target, value, jump, triggerCallbacks);
		}
		
		override protected function _render(target:Object, value:Number, jump:Boolean = false, triggerCallbacks:Boolean = true):void
		{
			// bad landon
			//jump && (_previousPosition = _position - EPSILON);

			// something changed in here and now mhy numbers are incorrect
			var endPosition:Number = _endPosition
				,isComplete:Boolean = value >= endPosition //value >= maximumPosition && _iterations > 0;
				,calculatedPosition:Number
				,isMovingForward:Boolean
				,initHandler:Function = FunctionUtil.noop
				,changeHandler:Function = FunctionUtil.noop
				,yoyoHandler:Function = FunctionUtil.noop
				,completeHandler:Function = FunctionUtil.noop;
			
			if (isComplete)
			{
			
				// STOP MOVIE
				_setIsPlaying(false);
			
				if (_previousPosition == endPosition) return;
				_position = endPosition;
				calculatedPosition = (yoyo && (iterations & 1)) ? 0 : _duration;
				isMovingForward = _position > _previousPosition;
			}
			else
			{
				_position = Math.max(_delay, value);
				calculatedPosition = _position < 0 ? 0 : _position % _duration; // eficiency would be to only do modulo if repeats > 0
				isMovingForward = _position > _previousPosition;
				
				if (yoyo)
				{
					const cycle:int = (_position / _duration) & 1;
					const previousCycle:int = (_previousPosition / _duration) & 1;
					const isReflecting:Boolean = (cycle == isMovingForward ? 1 : 0) && cycle != previousCycle;
					
					if (cycle) calculatedPosition = duration - calculatedPosition;
				}
			}
			
			if (triggerCallbacks)
			{
				changeHandler = _changeHandler;
				if (isMovingForward)
				{
					initHandler = _initHandler;
					yoyoHandler = _yoyoHandler;
					completeHandler = _completeHandler;
				}
			}
			
			// if not in delay interval and position changed
			if ((_position >= 0 || _previousPosition >= 0) && _position != _previousPosition)
			{
				const passedZero:Boolean = (_position >= 0 && _previousPosition < 0) || (_position <= 0 && _previousPosition > 0);
				
				passedZero && initHandler(jump);
				
				// should not even be calculated for isComplete == true or position <= 0
				const progress:Number = (_duration == 0 && _position >= 0) ? 1 : ease(calculatedPosition / _duration, 0, 1, 1);
				
				for (var property:String in _to)
					_to[property].tween(target, property, progress, passedZero, isComplete);
					
				changeHandler(jump);
			}
			
			isReflecting && yoyoHandler(jump);
			isComplete && completeHandler(jump);
			
			_previousPosition = _position;
		}
		
		private function _initHandler(jump:Boolean):void 
		{
		
			_isInitialized || _initialize();
		
			_onInit.length == 1 ? _onInit(jump) : _onInit();
			hasEventListener(Event.INIT) && dispatchEvent(new Event(Event.INIT));
		}
		
		private function _changeHandler(jump:Boolean):void 
		{
			_onChange.length == 1 ? _onChange(jump) : _onChange();
			hasEventListener(Event.CHANGE) && dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function _yoyoHandler(jump:Boolean):void 
		{
			_onYoyo.length == 1 ? _onYoyo(jump) : _onYoyo();
			hasEventListener(TweenEvent.YOYO) && dispatchEvent(new Event(TweenEvent.YOYO));
		}
		
		private function _completeHandler(jump:Boolean):void 
		{
			_onComplete.length == 1 ? _onComplete(jump) : _onComplete();
			hasEventListener(Event.COMPLETE) && dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function get _startPosition():Number
		{
			return _delay;
		}
		
		private function get _endPosition():Number
		{
			return _duration * iterations * (yoyo ? 2 : 1);
		}
		
		private function get _isAtStart():Boolean
		{
			return _position <= _delay;
		}
		
		private function get _isAtEnd():Boolean
		{
			return _position >= _endPosition;
		}
		
		private function _setIsPlaying(value:Boolean):void
		{
			if (_isPlaying == value) return;
			
			_isPlaying = value;
			
			if (value)
			{
				Core.eventDispatcher.addEventListener(Event.ENTER_FRAME, _integrate);
			}
			else
			{
				Core.eventDispatcher.removeEventListener(Event.ENTER_FRAME, _integrate);
			}
		}
		
		private function _integrate(event:Event):void 
		{
			// cool yoyo feature
			//trace(_position + (useFrames ? Tween.timeScale : _deltaTime) * timeScale * _step * (yoyo && _position >= 0 ? 2:1));
			pauseAll || _setPosition(_position + (useFrames ? Tween.timeScale : _deltaTime) * timeScale * _step * (yoyo && _position >= 0 ? 2 : 1));
		}
		
		
	}

}
