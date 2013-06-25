package orichalcum.animation 
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import orichalcum.animation.tweener.BooleanTweener;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.core.Core;
	import orichalcum.utility.FunctionUtil;
	
	/**
	 * Animation base class
	 * 		extended by _AnimationTimeline, _Tween
	 * 		
	 */
	public class Animation 
	{
		
		static public const DURATIONS:Object = { slow:800, normal:400, fast:200 };
		static public var pauseAll:Boolean;
		static public var defaultEase:Function = Ease.quadOut;
		static public var defaultDuration:Number = DURATIONS.normal;
		static public const NULL_TARGET:Object = {};
		
		/** @private */
		static private const EPSILON:Number = 0.0001;
		
		/** @private */
		static private const _tweenersByProperty:Object = {};
		
		/** @private */
		static private const _tweenersByClass:Object = {'Boolean': BooleanTweener, 'Number': NumberTweener, 'int': NumberTweener, 'uint': NumberTweener};
		
		protected var _target:Object = NULL_TARGET;
		protected var _position:Number = 0;
		protected var _previousPosition:Number = -EPSILON;
		protected var _initialized:Boolean;
		protected var _iterations:Number = 1;
		protected var _timeScale:Number = 1;
		protected var _duration:Number = defaultDuration;
		protected var _ease:Function = defaultEase;
		protected var _isPlaying:Boolean;
		protected var _yoyo:Boolean;
		protected var _useFrames:Boolean;
		protected var _onInit:Function = FunctionUtil.noop;
		protected var _onChange:Function = FunctionUtil.noop;
		protected var _onYoyo:Function = FunctionUtil.noop;
		protected var _onComplete:Function = FunctionUtil.noop;
		protected var _step:Number = 1;
		
		/** @private */
		static internal function _createTweener(propertyName:String, propertyValue:*):ITweener
		{
			const tweenerForProperty:Class = _tweenersByProperty[propertyName];
			
			if (tweenerForProperty) return new tweenerForProperty;
			
			const tweenerForClass:Class = _tweenersByClass[getQualifiedClassName(propertyValue)];
			
			if (tweenerForClass) return new tweenerForClass;
			
			return null;
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
		
		public function Animation()
		{
			
		}
		
		public function invalidate():Animation
		{
			_initialized = false;
			return this;
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Controls
		/////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Starts animation at the current position.
		 * @return this animation
		 */
		public function play():Animation
		{
			return _setIsPlaying(true);
		}
		
		/**
		 * Stops animation at the current position.
		 * @return this animation
		 */
		public function pause():Animation
		{
			return _setIsPlaying(false);
		}
		
		/**
		 * Plays the animation if paused or pauses the aniamtion if playing.
		 * @return this animation
		 */
		public function toggle():Animation
		{
			return _setIsPlaying(!_isPlaying);
		}
		
		/**
		 * Stops animation and resets playhead to the start position.
		 * @return this animation
		 */
		public function stop():Animation
		{
			return rewind().pause();
		}
		
		/**
		 * Resets playhead to the start position and restarts the animation.
		 * @return this animation
		 */
		public function replay():Animation
		{
			return rewind().play();
		}
		
		/**
		 * Resets playhead to the start position.
		 * @return this animation
		 */
		public function rewind():Animation
		{
			return goto(0);
		}
		
		/**
		 * Forces animation to end position.
		 * @param triggerCallbacks If false callbacks such as onComplete will be supressed
		 * @return this animation
		 */
		public function end(triggerCallbacks:Boolean = true):Animation
		{
			return goto(_totalDuration, triggerCallbacks);
		}
		
		/**
		 * Moves playhead to a given position.
		 * @param position The position to move the playhead (value of 0 to duration)
		 * @param triggerCallbacks If false callbacks such as onComplete will be supressed
		 * @return this animation
		 */
		public function goto(position:Number, triggerCallbacks:Boolean = true):Animation
		{
			return _setPosition(0, true, triggerCallbacks);
		}
		
		public function reverse():Animation
		{
			_step = -_step;
			return this;
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Accessors and Modifiers
		/////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * True if the animation is stopped.
		 */
		public function get isPaused():Boolean
		{
			return !_isPlaying;
		}
		
		/**
		 * True if the animation is playing.
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		/**
		 * True if the animation is playing and moving forward.
		 */
		public function get isPlayingForward():Boolean
		{
			return _isPlaying && _previousPosition < _position;
		}
		
		/**
		 * True if the animation is playing and moving in reverse.
		 */
		public function get isPlayingBackward():Boolean
		{
			return _isPlaying && _previousPosition > _position;
		}
		
		/**
		 * Get or set the subject of animation.
		 */
		public function target(...args):*
		{
			return args.length ? _setTarget(args[0]) : _target === NULL_TARGET ? null : _target;
		}
		
		/**
		 * Get or set the current position of the animation in time or frames
		 */
		public function position(...args):*
		{
			return args.length ? _setPosition(args[0]) : _position;
		}
		
		/**
		 * Get or set the current progress of the animation (position/duration)
		 */
		public function progress(...args):*
		{
			return args.length ? _setProgress(args[0]) : _progress;
		}
		
		/**
		 * Get or set the total duration of the animation
		 */
		public function duration(...args):*
		{
			return args.length ? _setDuration(args[0]) : _duration;
		}
		
		/**
		 * Set the animation duration in seconds
		 */
		public function seconds(...args):*
		{
			return args.length ? _setSeconds(args[0]) : _duration;
		}
		
		/**
		 * Set the animation duration in frames
		 */
		public function frames(...args):*
		{
			return args.length ? _setFrames(args[0]) : _duration;
		}
		
		/**
		 * Set the animation duration to default small time in seconds
		 */
		public function quickly():Animation
		{
			_duration = DURATIONS.fast;
			_useFrames = false;
			return this;
		}
		
		/**
		 * Set the animation duration to default time larger than "normal" or "fast"
		 */
		public function slowly():Animation
		{
			_duration = DURATIONS.slow;
			_useFrames = false;
			return this;
		}
		
		/**
		 * Get or set the animation's timeScale
		 */
		public function timeScale(...args):*
		{
			return args.length ? _setTimeScale(args[0]) : _timeScale;
		}
		
		/**
		 * Set or set the animation's easing function
		 */
		public function ease(...args):*
		{
			return args.length ? _setEase(args[0]) : _ease;
		}
		
		/**
		 * Set or set the animation's yoyo property
		 */
		public function yoyo(...args):*
		{
			return args.length ? _setYoyo(args[0]) : _yoyo;
		}
		
		/**
		 * Set or set the number of times the animation will repeat
		 */
		public function repeat(...args):*
		{
			return args.length ? _setRepeat(args[0]) : _repeat;
		}
		
		/**
		 * Set the animation's on init callback to be called the first frame of the animation after it starts for the first time.
		 * @param	...callback Function (function(isJump:Boolean):* { }) where object "this" is the animation
		 * @return
		 */
		public function onInit(callback:Function):Animation
		{
			_onInit = callback == null ? FunctionUtil.noop : callback;
			return this;
		}
		
		public function onChange(callback:Function):Animation
		{
			_onChange = callback == null ? FunctionUtil.noop : callback;
			return this;
		}
		
		public function onYoyo(callback:Function):Animation
		{
			_onYoyo = callback == null ? FunctionUtil.noop : callback;
			return this;
		}
		
		public function onComplete(callback:Function):Animation
		{
			_onComplete = callback == null ? FunctionUtil.noop : callback;
			return this;
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Private Parts
		/////////////////////////////////////////////////////////////////////////////////
		
		protected function _integrate(event:Event = null):void
		{
			_isPlaying && _render(_position + (_useFrames ? 1 : Core.deltaTime) * _timeScale * _step * (_yoyo ? 2 : 1), false, true, _target, _ease);
		}
		
		// target and ease allow parent animation to override these values
		protected function _render(position:Number, isJump:Boolean, triggerCallbacks:Boolean, target:Object, ease:Function):void
		{
			throw new IllegalOperationError(); // this method must be overriden
		}
		
		protected function get _startPosition():Number
		{
			return 0;
		}
		
		protected function get _endPosition():Number
		{
			return _totalDuration;
		}
		
		protected function get _isAtStart():Boolean
		{
			return _position <= 0;
			//return _position <= _delay;
		}
		
		protected function get _isAtEnd():Boolean
		{
			//return _position >= _endPosition;
			return _position >= _totalDuration;
		}
		
		protected function get _progress():Number
		{
			return _position / _totalDuration;
		}
		
		protected function get _totalDuration():Number
		{
			return _iterations <= 0 || isNaN(_iterations) ? Infinity : _duration * _iterations * (_yoyo ? 2 : 1);
		}
		
		protected function get _repeat():Number
		{
			return _iterations - 1;
		}
		
		protected function _setTarget(value:Object):Animation
		{
			_target = value ? value : NULL_TARGET;
			return this;
		}
		
		protected function _setPosition(value:Number, isJump:Boolean = false, triggerCallbacks:Boolean = true):Animation
		{
			_render(value, isJump, triggerCallbacks, _target, _ease);
			return this;
		}
		
		protected function _setProgress(value:Number):Animation
		{
			_position = value * _totalDuration;
			return this;
		}
		
		protected function _setDuration(value:Number):Animation
		{
			_duration = value;
			return this;
		}
		
		protected function _setSeconds(value:Number):Animation
		{
			_duration = value * 1000;
			_useFrames = false;
			return this;
		}
		
		protected function _setFrames(value:Number):Animation
		{
			_duration = value;
			_useFrames = true;
			return this;
		}
		
		protected function _setTimeScale(value:Number):Animation
		{
			_timeScale = value;
			return this;
		}
		
		protected function _setEase(value:*):Animation
		{
			if (value is Function)
			{
				_ease = value;
			}
			else if (value is String)
			{
				_ease = Ease[value] ? Ease[value] : defaultEase;
			}
			else
			{
				_ease = defaultEase;
			}
			return this;
		}
		
		protected function _setYoyo(value:Boolean):Animation
		{
			_yoyo = value;
			return this;
		}
		
		protected function _setRepeat(value:Number):Animation
		{
			_iterations = value + 1;
			return this;
		}
		
		protected function _setIsPlaying(value:Boolean):Animation
		{
			if (_isPlaying != value)
			{
				if (_isPlaying = value)
				{
					Core.eventDispatcher.addEventListener(Event.ENTER_FRAME, _integrate);
				}
				else
				{
					Core.eventDispatcher.removeEventListener(Event.ENTER_FRAME, _integrate);
				}
			}
			return this;
		}
		
		protected function _initHandler(jump:Boolean):void 
		{
			_onInit.length == 1 ? _onInit(jump) : _onInit();
		}
		
		protected function _changeHandler(jump:Boolean):void 
		{
			_onChange.length == 1 ? _onChange(jump) : _onChange();
		}
		
		protected function _yoyoHandler(jump:Boolean):void 
		{
			_onYoyo.length == 1 ? _onYoyo(jump) : _onYoyo();
		}
		
		protected function _completeHandler(jump:Boolean):void 
		{
			_onComplete.length == 1 ? _onComplete(jump) : _onComplete();
		}
		
		protected function _initialize():void
		{
			
		}
		
		
	}

}