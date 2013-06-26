package orichalcum.animation 
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import orichalcum.animation.tweener.BooleanTweener;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.core.Core;
	import orichalcum.utility.FunctionUtil;
	
	/**
	 * Abstract animation class
	 * 	subclasses and differences:
	 * 	_AnimationTimeline
	 * 		.stagger(time) // this will add stagger to all its children
	 * 		//- ease ?
	 * 	_AnimationTween
	 * 		.to(values)
	 * 		.from(values)
	 * 		
	 */
	public class Animation 
	{
		
		static public var durations:Object = { slow:800, normal:400, fast:200 };
		static public var defaultDuration:Number = durations.normal;
		static public var defaultEase:Function = Ease.quadOut;
		static public var pauseAll:Boolean;
		
		/** @private */
		static private const NULL_TARGET:Object = {};
		
		/** @private */
		static private const EPSILON:Number = 0.0001;
		
		/** @private */
		static private const _tweenersByProperty:Object = {};
		
		/** @private */
		static private const _tweenersByClass:Object = {'Boolean': BooleanTweener, 'Number': NumberTweener, 'int': NumberTweener, 'uint': NumberTweener};
		
		/** @private */
		protected var _target:Object = NULL_TARGET;
		
		/** @private */
		protected var _position:Number = 0;
		
		/** @private */
		protected var _previousPosition:Number = -EPSILON;
		
		/** @private */
		protected var _initialized:Boolean;
		
		/** @private */
		protected var _iterations:Number = 1;
		
		/** @private */
		protected var _timeScale:Number = 1;
		
		/** @private */
		protected var _duration:Number = defaultDuration;
		
		/** @private */
		protected var _ease:Function = defaultEase;
		
		/** @private */
		protected var _isPlaying:Boolean;
		
		/** @private */
		protected var _yoyo:Boolean;
		
		/** @private */
		protected var _useFrames:Boolean;
		
		/** @private */
		protected var _onInit:Function = FunctionUtil.noop;
		
		/** @private */
		protected var _onChange:Function = FunctionUtil.noop;
		
		/** @private */
		protected var _onYoyo:Function = FunctionUtil.noop;
		
		/** @private */
		protected var _onComplete:Function = FunctionUtil.noop;
		
		/** @private */
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
		
		/////////////////////////////////////////////////////////////////////////////////
		// Controls
		/////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Starts animation at the current position.
		 * @return this animation
		 */
		public function play():Animation
		{
			_isAtEnd && goto(0); // video feature
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
			return _isPlaying ? pause() : play();
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
			return goto(_endPosition, triggerCallbacks);
		}
		
		/**
		 * Moves playhead to a given position.
		 * @param position The position to move the playhead (value of 0 to duration)
		 * @param triggerCallbacks If false callbacks such as onComplete will be supressed
		 * @return this animation
		 */
		public function goto(position:Number, triggerCallbacks:Boolean = true):Animation
		{
			return _setPosition(position, true, triggerCallbacks);
		}
		
		/**
		 * @todo copy docs
		 */
		public function reverse():Animation
		{
			_step = -_step;
			return this;
		}
		
		/**
		 * @todo copy docs
		 */
		public function invalidate():Animation
		{
			_initialized = false;
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
		 * Get or set the animation duration in milliseconds
		 */
		public function milliseconds(...args):*
		{
			return args.length ? _setDuration(args[0]) : _duration;
		}
		
		/**
		 * Get or set the animation duration in seconds
		 */
		public function seconds(...args):*
		{
			return args.length ? _setSeconds(args[0]) : _duration * 0.001;
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
			return milliseconds(durations.fast);
		}
		
		/**
		 * Set the animation duration to default time larger than "normal" or "fast"
		 */
		public function slowly():Animation
		{
			return milliseconds(durations.slow);
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
		
		public function get totalDuration():Number
		{
			return _iterations <= 0 || isNaN(_iterations) ? Infinity : _duration * _iterations * (_yoyo ? 2 : 1);
		}
		
		protected function get _progress():Number
		{
			return _position / totalDuration;
		}
		
		protected function get _repeat():Number
		{
			return _iterations - 1;
		}
		
		protected function get _startPosition():Number
		{
			return 0;
		}
		
		protected function get _endPosition():Number
		{
			return totalDuration;
		}
		
		protected function get _isAtStart():Boolean
		{
			return _position <= 0;
		}
		
		protected function get _isAtEnd():Boolean
		{
			return _position >= totalDuration;
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
			_setPosition(value * totalDuration, true);
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
			_onInit.length == 1 ? _onInit.call(this, jump) : _onInit.call(this);
		}
		
		protected function _changeHandler(jump:Boolean):void 
		{
			_onChange.length == 1 ? _onChange.call(this, jump) : _onChange.call(this);
		}
		
		protected function _yoyoHandler(jump:Boolean):void 
		{
			_onYoyo.length == 1 ? _onYoyo.call(this, jump) : _onYoyo.call(this);
		}
		
		protected function _completeHandler(jump:Boolean):void 
		{
			_onComplete.length == 1 ? _onComplete.call(this, jump) : _onComplete.call(this);
		}
		
		protected function _integrate(event:Event = null):void
		{
			_isPlaying && _render(_position + (_useFrames ? 1 : Core.deltaTime) * _timeScale * _step * (_yoyo ? 2 : 1), false, true, _target, _ease);
		}
		
		// target and ease allow parent animation to override these values
		protected function _render(position:Number, isJump:Boolean, triggerCallbacks:Boolean, target:Object, ease:Function):void
		{
			var endPosition:Number = _endPosition
				,yoyosCompleted:int = 0
				,initHandler:Function
				,changeHandler:Function
				,yoyoHandler:Function
				,completeHandler:Function;
			
			_previousPosition = _position;
			_position = Math.min(position, endPosition);
			
			const isMovingForward:Boolean = _position > _previousPosition;
			
			/**
			 * Awkward null object pattern usage to avoid duplicate "ifs" for efficiency
			 */
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
			else
			{
				initHandler = changeHandler = yoyoHandler = completeHandler = FunctionUtil.noop;
			}
			
			const isComplete:Boolean = _position >= endPosition;
			
			// could use strategy pattern "positionCalculator()" if (_repeat == 0) have RETURN fn, else RETURN _p % _d
			var calculatedPosition:Number = _repeat > 0 ? _position % _duration : _position;
			
			// optional failfast
			//if (isComplete && _previousPosition == endPosition) return;
			
			if (_yoyo)
			{
				const currentCompletedCycles:int = _position / _duration;
				yoyosCompleted = ((currentCompletedCycles + 1) >> 1) - (((_previousPosition / _duration) + 1) >> 1);
				
				if (currentCompletedCycles & 1 == 1)
					calculatedPosition = _duration - calculatedPosition;
			}
			
			if (_position != _previousPosition)
			{
				const isStart:Boolean = !_initialized;
				
				_initialized || _initialize(isJump, initHandler);
				
				// should not even be calculated for isComplete == true or position <= 0
				// this is calculated progress -- the following is computationally efficient
				// isComplete
				/*
				 * isComplete
				 * 		? yoyo
				 * 			? 0
				 * 			: 1
				 * 		: (_duration == 0 && _position >= 0)
				 * 			? yoyo
				 *	 			? 0
				 *	 			: 1
				 * 			: ease(calculatedPosition, 0, 1, _duration)
				 * 
				 * calculatedProgress = 
				 */
				//const progress:Number = (_duration == 0 && _position >= 0) ? 1 : ease(calculatedPosition, 0, 1, _duration);
				const progress:Number = isComplete || (_duration == 0 && _position >= 0) ? _yoyo ? 0 : 1 : ease(calculatedPosition, 0, 1, _duration);
				
				_renderTarget(target, progress, isStart, isComplete);
				
				changeHandler(isJump);
			}
			
			while (yoyosCompleted-- > 0)
			{
				yoyoHandler(isJump);
			}
			
			if (isComplete)
			{
				// STOP MOVIE
				//_previousPosition = endPosition;
				//_initialized = false;
				//_setIsPlaying(false);
				invalidate().pause();
				completeHandler(isJump);
			}
		}
		
		protected function _initialize(isJump:Boolean, callback:Function):void
		{
			// abstract
		}
		
		protected function _renderTarget(target:Object, progress:Number, isStart:Boolean, isEnd:Boolean):void
		{
			// abstract
		}
		
	}

}
