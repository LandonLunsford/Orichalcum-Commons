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
	internal class AnimationBase 
	{
		
		
		/** @private used to avoid if checking target */
		static private const NULL_TARGET:Object = {};
		
		/** @private */
		static private const EPSILON:Number = 0.0001;
		
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
		protected var _duration:Number = Animation.defaultDuration;
		
		/** @private */
		protected var _ease:Function = Animation.defaultEase;
		
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
		
		
		public function AnimationBase()
		{
			// I really dont want the client calling this, lets move this to AnimationBase
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Controls
		/////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Starts animation at the current position.
		 * @return this animation
		 */
		public function play():AnimationBase
		{
			_isAtEnd && goto(0); // video feature
			return _setIsPlaying(true);
		}
		
		/**
		 * Stops animation at the current position.
		 * @return this animation
		 */
		public function pause():AnimationBase
		{
			return _setIsPlaying(false);
		}
		
		/**
		 * Plays the animation if paused or pauses the aniamtion if playing.
		 * @return this animation
		 */
		public function toggle():AnimationBase
		{
			return _isPlaying ? pause() : play();
		}
		
		/**
		 * Stops animation and resets playhead to the start position.
		 * @return this animation
		 */
		public function stop():AnimationBase
		{
			return rewind().pause();
		}
		
		/**
		 * Resets playhead to the start position and restarts the animation.
		 * @return this animation
		 */
		public function replay():AnimationBase
		{
			return rewind().play();
		}
		
		/**
		 * Resets playhead to the start position.
		 * @return this animation
		 */
		public function rewind():AnimationBase
		{
			return goto(0);
		}
		
		/**
		 * Forces animation to end position.
		 * @param triggerCallbacks If false callbacks such as onComplete will be supressed
		 * @return this animation
		 */
		public function end(triggerCallbacks:Boolean = true):AnimationBase
		{
			return goto(_endPosition, triggerCallbacks);
		}
		
		/**
		 * Moves playhead to a given position.
		 * @param position The position to move the playhead (value of 0 to duration)
		 * @param triggerCallbacks If false callbacks such as onComplete will be supressed
		 * @return this animation
		 */
		public function goto(position:Number, triggerCallbacks:Boolean = true):AnimationBase
		{
			return _setPosition(position, true, triggerCallbacks);
		}
		
		/**
		 * @todo copy docs
		 */
		public function reverse():AnimationBase
		{
			_step = -_step;
			return this;
		}
		
		/**
		 * @todo copy docs
		 */
		public function invalidate():AnimationBase
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
		public function duration(...args):*
		{
			return args.length ? _setDuration(args[0]) : _duration;
		}
		
		/**
		 * Get or set the animation duration in milliseconds
		 */
		public function milliseconds(...args):*
		{
			return args.length ? _setMilliseconds(args[0]) : _duration;
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
		public function quickly():AnimationBase
		{
			return milliseconds(Animation.durations.fast);
		}
		
		/**
		 * Set the animation duration to default time larger than "normal" or "fast"
		 */
		public function slowly():AnimationBase
		{
			return milliseconds(Animation.durations.slow);
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
		public function onInit(callback:Function):AnimationBase
		{
			_onInit = callback == null ? FunctionUtil.noop : callback;
			return this;
		}
		
		public function onChange(callback:Function):AnimationBase
		{
			_onChange = callback == null ? FunctionUtil.noop : callback;
			return this;
		}
		
		public function onYoyo(callback:Function):AnimationBase
		{
			_onYoyo = callback == null ? FunctionUtil.noop : callback;
			return this;
		}
		
		public function onComplete(callback:Function):AnimationBase
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
		
		protected function _setTarget(value:Object):AnimationBase
		{
			_target = value ? value : NULL_TARGET;
			return this;
		}
		
		protected function _setPosition(value:Number, isJump:Boolean = false, triggerCallbacks:Boolean = true):AnimationBase
		{
			_render(value, isJump, triggerCallbacks, _target, _ease);
			return this;
		}
		
		protected function _setProgress(value:Number):AnimationBase
		{
			_setPosition(value * totalDuration, true);
			return this;
		}
		
		protected function _setDuration(value:*):AnimationBase
		{
			if (value is Function)
			{
				_duration = value;
			}
			else if (value is String)
			{
				_duration = Animation.durations[value] ? Animation.durations[value] : Animation.defaultDuration;
				_useFrames = false;
			}
			else
			{
				_duration = Animation.defaultDuration;
			}
			return this;
		}
		
		protected function _setMilliseconds(value:Number):AnimationBase
		{
			_duration = value;
			_useFrames = false;
			return this;
		}
		
		protected function _setSeconds(value:Number):AnimationBase
		{
			return _setMilliseconds(value * 1000);
		}
		
		protected function _setFrames(value:Number):AnimationBase
		{
			_duration = value;
			_useFrames = true;
			return this;
		}
		
		protected function _setTimeScale(value:Number):AnimationBase
		{
			_timeScale = value;
			return this;
		}
		
		protected function _setEase(value:*):AnimationBase
		{
			if (value is Function)
			{
				_ease = value;
			}
			else if (value is String)
			{
				_ease = Ease[value] ? Ease[value] : Animation.defaultEase;
			}
			else
			{
				_ease = Animation.defaultEase;
			}
			return this;
		}
		
		protected function _setYoyo(value:Boolean):AnimationBase
		{
			_yoyo = value;
			return this;
		}
		
		protected function _setRepeat(value:Number):AnimationBase
		{
			_iterations = value + 1;
			return this;
		}
		
		protected function _setIsPlaying(value:Boolean):AnimationBase
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
			// need to use null object pattern to avoid these two if checks
			Animation.pauseAll || _isPlaying && _render(_position + (_useFrames ? 1 : Core.deltaTime) * _timeScale * _step * (_yoyo ? 2 : 1), false, true, _target, _ease);
		}
		
		// target and ease allow parent animation to override these values
		protected function _render(position:Number, isJump:Boolean, triggerCallbacks:Boolean, target:Object, ease:Function):void
		{
			var initHandler:Function = FunctionUtil.noop
				,changeHandler:Function = FunctionUtil.noop
				,yoyoHandler:Function = FunctionUtil.noop
				,completeHandler:Function = FunctionUtil.noop
				,yoyosCompleted:int = 0
				,endPosition:Number = _endPosition;
			
			_previousPosition = _position;
			_position = Math.min(position, endPosition);
			
			const isComplete:Boolean = _position >= endPosition;
			
			// optional failfast
			//if (isComplete && _previousPosition == endPosition) return;
			
			const isMovingForward:Boolean = _position > _previousPosition;
			
			var renderedPosition:Number = _repeat > 0 ? _position % _duration : _position;
			
			if (_yoyo)
			{
				const currentCompletedCycles:int = _position / _duration;
				
				yoyosCompleted = ((currentCompletedCycles + 1) >> 1) - (((_previousPosition / _duration) + 1) >> 1);
				
				if (currentCompletedCycles & 1 == 1)
					renderedPosition = _duration - renderedPosition;
			}
			
			/**
			 * Awkward null object pattern usage to avoid duplicate "if" statements for efficiency
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
			
			if (_position != _previousPosition)
			{
				const isStart:Boolean = !_initialized;
				
				_initialized || _initialize(isJump, initHandler);
				
				const renderedProgress:Number = isComplete || (_duration == 0 && _position >= 0)
					? _yoyo ? 0 : 1
					: ease(renderedPosition, 0, 1, _duration);
				
				_renderTarget(target, renderedProgress, isStart, isComplete);
				
				changeHandler(isJump);
			}
			
			while (yoyosCompleted-- > 0)
			{
				yoyoHandler(isJump);
			}
			
			if (isComplete)
			{
				invalidate().pause(); // should this be triggered when jumping ?
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
