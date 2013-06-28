package orichalcum.animation 
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import orichalcum.animation.tweener.BooleanTweener;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.core.Core;
	import orichalcum.utility.FunctionUtil;
	
	public class Animation extends AnimationBase
	{
		
		static public const eventDispatcher:IEventDispatcher = new Shape;
		
		/** The duration in milliseconds for all animations if the animation's duration is not explicitly set **/
		static public var durations:Object = { slow:800, normal:400, fast:200 };
		
		/** The easing function used for all animations if the animation's ease is not explicitly set **/
		static public var defaultEase:Function = Ease.quadOut;
		
		/** @private used to avoid if checking target */
		static internal const NULL_TARGET:Object = {};
		
		/** @private */
		static private const EPSILON:Number = 0.0001;
		
		/** @private */
		static private const _tweenersByProperty:Object = {};
		
		/** @private */
		static private const _tweenersByClass:Object = { 'Boolean': BooleanTweener, 'Number': NumberTweener, 'int': NumberTweener, 'uint': NumberTweener };
		
		/** @private */
		static private var _currentTime:Number;
		
		/** @private */
		static private var _deltaTime:Number;
		
		/** @private */
		static private var _timeScale:Number = 1;
		
		
		static public function get currentTime():Number
		{
			return _currentTime;
		}

		static public function get deltaTime():Number
		{
			return _deltaTime;
		}

		static public function get timeScale():Number
		{
			return _timeScale;
		}

		static public function set timeScale(value:Number):void
		{
			_timeScale = value;
		}
		
		//////////////////////////////////////////////////////////////////////////////////////////////
		// STATIC INIT
		//////////////////////////////////////////////////////////////////////////////////////////////
		
		{
			_currentTime = getTimer();
			eventDispatcher.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
				const previousTime:Number = _currentTime;
				_currentTime = getTimer();
				_deltaTime = (_currentTime - previousTime) * _timeScale;
			});
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
		
		/** @private */
		static internal function _createTweener(propertyName:String, propertyValue:*):ITweener
		{
			const tweenerForProperty:Class = _tweenersByProperty[propertyName];
			if (tweenerForProperty) return new tweenerForProperty;
			
			const tweenerForClass:Class = _tweenersByClass[getQualifiedClassName(propertyValue)];
			if (tweenerForClass) return new tweenerForClass;
			
			return null;
		}
		
		/** @private */
		internal var _position:Number = 0;
		
		/** @private */
		internal var _previousPosition:Number = -EPSILON;
		
		/** @private */
		internal var _initialized:Boolean;
		
		/** @private */
		internal var _duration:Number = durations.normal;
		
		/** @private */
		internal var _iterations:Number = 1;
		
		/** @private */
		internal var _timeScale:Number = 1;
		
		/** @private */
		internal var _ease:Function = defaultEase;
		
		/** @private */
		internal var _isPlaying:Boolean;
		
		/** @private */
		internal var _yoyo:Boolean;
		
		/** @private */
		internal var _useFrames:Boolean;
		
		/** @private */
		internal var _onInit:Function = FunctionUtil.noop;
		
		/** @private */
		internal var _onChange:Function = FunctionUtil.noop;
		
		/** @private */
		internal var _onYoyo:Function = FunctionUtil.noop;
		
		/** @private */
		internal var _onComplete:Function = FunctionUtil.noop;
		
		/** @private */
		internal var _step:Number = 1;
		
		/** @private */
		private var _to:Object;
		
		/** @private */
		private var _from:Object;
		
		/** @private */
		private var _stagger:Number = 0;
		
		////////////////////////////////////// overhead incurred by polymorphism
		
		/** @private */
		private var _children:Vector.<AnimationBase> = new Vector.<AnimationBase>;
		
		/** @private */
		private var _insertionTime:Number = 0;
		
		/** @private */
		private var _previousEndTime:Number = 0;
		
		////////////////////////////////////// overhead incurred by polymorphism
		
		
		public function Animation(animations:Array = null)
		{
			
			for each(var input:* in animations)
			{
				if (input is AnimationWait)
				{
					var time:Number = input._totalDuration; // not duration but total duration
					_insertionTime = isNaN(time) ? _previousEndTime : _insertionTime + time;
				}
				else if (input is AnimationBase)
				{
					add(input);
				}
				else
				{
					add(new AnimationChild(input));
				}
			}
		}
		
		public function add(animation:AnimationBase, time:Number = NaN):Animation 
		{
			const insertionTime:Number = isNaN(time) ? _insertionTime : time;
			const endTime:Number = insertionTime + animation._totalDuration;
			
			animation._timelinePosition = insertionTime;
			_children.push(animation);
			
			_previousEndTime = endTime; // @TODO consider stagger
			if (_duration < endTime)
				_duration = endTime;
			
			trace('adding', animation, 'at time', insertionTime, 'ending', endTime);
			
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
		
		public function to(...args):*
		{
			return args.length ? _setTo(args[0]) : _to;
		}
		
		public function from(...args):*
		{
			return args.length ? _setFrom(args[0]) : _to;
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
		 * Get or set the animation stagger in frames or seconds
		 */
		public function stagger(...args):* 
		{
			return args.length ? _setStagger(args[0]) : _stagger;
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
		public function quickly():Animation
		{
			return milliseconds(Animation.durations.fast);
		}
		
		/**
		 * Set the animation duration to default time larger than "normal" or "fast"
		 */
		public function slowly():Animation
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
		
		override internal function get _totalDuration():Number
		{
			return _iterations <= 0 || isNaN(_iterations) ? Infinity : _duration * _iterations * (_yoyo ? 2 : 1);
		}
		
		protected function get _progress():Number
		{
			return _position / _totalDuration;
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
			return _totalDuration;
		}
		
		protected function get _isAtStart():Boolean
		{
			return _position <= 0;
		}
		
		protected function get _isAtEnd():Boolean
		{
			return _position >= _totalDuration;
		}
		
		protected function _setTo(value:Object):Animation 
		{
			_to = value;
			return this;
		}
		
		protected function _setFrom(value:Object):Animation 
		{
			_from = value;
			return this;
		}
		
		protected function _setStagger(value:Number):Animation 
		{
			_stagger = value;
			return this;
		}
		
		protected function _setPosition(value:Number, isJump:Boolean = false, triggerCallbacks:Boolean = true):Animation
		{
			_render(value, isJump, triggerCallbacks);
			return this;
		}
		
		protected function _setProgress(value:Number):Animation
		{
			_setPosition(value * _totalDuration, true);
			return this;
		}
		
		protected function _setDuration(value:*):Animation
		{
			if (value is Function)
			{
				_duration = value;
			}
			else if (value is String)
			{
				_duration = durations[value] ? durations[value] : durations.normal;
				_useFrames = false;
			}
			else
			{
				_duration = durations.normal;
			}
			return this;
		}
		
		protected function _setMilliseconds(value:Number):Animation
		{
			_duration = value;
			_useFrames = false;
			return this;
		}
		
		protected function _setSeconds(value:Number):Animation
		{
			return _setMilliseconds(value * 1000);
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
				_ease = Ease[value] ? Ease[value] : Animation.defaultEase;
			}
			else
			{
				_ease = Animation.defaultEase;
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
					eventDispatcher.addEventListener(Event.ENTER_FRAME, _integrate);
				}
				else
				{
					eventDispatcher.removeEventListener(Event.ENTER_FRAME, _integrate);
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
		
		/////////////////////////////////////////////////////////////////////////////////
		// Private Parts
		/////////////////////////////////////////////////////////////////////////////////
		
		/////////////////////////////////////////////////////////////////////////////////
		// Overrides
		/////////////////////////////////////////////////////////////////////////////////
		
		protected function _integrate(event:Event = null):void 
		{
			_isPlaying && _render(_position + (_useFrames ? 1 : deltaTime) * Animation.timeScale * _timeScale * _step * (_yoyo ? 2 : 1), false, true);
		}
		
		protected function _initialize(isJump:Boolean, callback:Function):void
		{
			_initialized = true;
			
			for each(var kid:* in _children)
			{
				var child:AnimationChild = kid as AnimationChild;
				if (!child) continue;
				
				var target:Object = child._target;
				var from:Object = _from ? _from : target;
				var to:Object = _to ? _to : target;
				
				if (to === from) return;
				
				var values:Object = _to ? _to : _from;
				
				for (var property:String in values)
				{
					// for each child
					child._tweeners ||= {};
					
					const tweener:ITweener = child._tweeners[property] ||= _createTweener(property, target[property]);
					
					// boolean tween bug where start isnt set dynamically when in to
					if (tweener)
					{
						/** the property in? fork fills in the blank for assumed things left out of the other param list **/
						tweener.init(
							property in from ? from[property] : target[property]
							,to[property]
						);
					}
				}
			}
			callback(isJump);
		}
		
		internal function _render(position:Number, isGoto:Boolean = false, triggerCallbacks:Boolean = true):void
		{
			
			/**
			 * I can have render take position and progress, if it has progress, it can skip progress calculation
			 */
			
			// hotfix for animation inclusing and pre-delay
			// fixes animations but not call(), more evidence or reason to split up the class
			//if (position < 0 && _previousPosition < 0) return;
				 
			
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
				
				_initialized || _initialize(isGoto, initHandler);
				
				var index:int, count:int = _children.length, step:int;
				//if (_position > _previousPosition)
				if (isMovingForward)
				{
					index = 0;
					step = 1;
				}
				else
				{
					index = count - 1;
					step = -1;
				}
				
				for (; count-- > 0; index += step)
				{
					var child:AnimationBase = _children[index];
					var childPosition:Number = renderedPosition - child._timelinePosition - index * _stagger;
					// not sure how to add stagger yet considering duration probably jsut have to consider it
					// when calculating end times on add(animation) additions
					
					// should not have to fork here
					if (child is Animation)
					{
						(child as Animation)._render(childPosition, isGoto, triggerCallbacks);
					}
					else
					{
						child._tween(childPosition < 0 ? 0 : _ease(childPosition, 0, 1, _duration));
					}
				}
				
				changeHandler(isGoto);
			}
			
			while (yoyosCompleted-- > 0)
			{
				yoyoHandler(isGoto);
			}
			
			//this is Tween && trace(isComplete);
			
			if (isComplete)
			{
				invalidate().pause(); // should this be triggered when jumping ?
				completeHandler(isGoto);
			}
		}
		
	}

}
