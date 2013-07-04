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
	import orichalcum.utility.FunctionUtil;
	import orichalcum.utility.MathUtil;
	
	/**
	 * @todo make animations copy(deep:Boolean = true) method
	 * @todo streamline plugin strategy (init, tween) methods and tweener creation and initialization to be safe for properties that arent on target
	 * @todo add record() allowing playback of all animations played
	 */
	public class Animation extends AnimationBase
	{
		
		static public const eventDispatcher:IEventDispatcher = new Shape;
		
		/** The duration in milliseconds for all animations if the animation's duration is not explicitly set **/
		static public var durations:Object = { slow:800, normal:400, fast:200 };
		
		/** The easing function used for all animations if the animation's ease is not explicitly set **/
		static public var defaultEase:Function = Ease.quadOut;
		
		/** @private */
		static private const EPSILON:Number = 0.0001;
		
		/** @private */
		static private var _tweenersByClass:Object = { 'Boolean': BooleanTweener, 'Number': NumberTweener, 'int': NumberTweener, 'uint': NumberTweener };
		
		/** @private */
		static private var _tweenersByProperty:Object = {};
		
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
		static internal function _createTweener(target:Object, propertyName:String):ITweener
		{
			const tweenerForProperty:Class = _tweenersByProperty[propertyName];
			
			if (tweenerForProperty)
				return new tweenerForProperty;
			
			if (!(propertyName in target))
				return null;
				
			const tweenerForClass:Class = _tweenersByClass[getQualifiedClassName(target[propertyName])];
			
			if (tweenerForClass)
				return new tweenerForClass;
			
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
		internal var _onInit:Function = FunctionUtil.NULL;
		
		/** @private */
		internal var _onChange:Function = FunctionUtil.NULL;
		
		/** @private */
		internal var _onYoyo:Function = FunctionUtil.NULL;
		
		/** @private */
		internal var _onComplete:Function = FunctionUtil.NULL;
		
		/** @private */
		internal var _step:Number = 1;
		
		/** @private */
		private var _to:Object;
		
		/** @private */
		private var _from:Object;
		
		/** @private */
		private var _stagger:Number = 0;
		
		////////////////////////////////////// overhead incurred by polymorphic API approach
		
		/** @private */
		private var _children:Vector.<AnimationBase> = new Vector.<AnimationBase>;
		
		/** @private */
		private var _childrenPositions:Vector.<Number> = new Vector.<Number>;
		
		/** @private */
		private var _insertionTime:Number = 0;
		
		////////////////////////////////////// overhead incurred by polymorphic API approach
		
		
		public function Animation(animations:Array = null)
		{
			
			for each(var input:* in animations)
			{
				if (input is AnimationWait)
				{
					var time:Number = input._totalDuration; // not duration but total duration
					var previousEndTime:Number = _insertionTime = isNaN(time) ? _childrenPositions[_children.length-1] + _children[_children.length-1]._totalDuration : _insertionTime + time;
					if (_duration < previousEndTime)
						_duration = previousEndTime;
						
					//trace('added wait, new duration is:', _duration, _insertionTime, _previousEndTime);
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
			
			_childrenPositions.push(insertionTime);
			_children.push(animation);
			
			if (_duration < endTime)
				_duration = endTime;
			
			//trace('adding', animation, 'at time', insertionTime, 'ending', endTime, 'child duration', animation._totalDuration, 'parent duration', _totalDuration);
			
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
			return args.length ? _setDuration(args[0]) : _durationWithStagger;
		}
		
		/**
		 * Get or set the animation duration in milliseconds
		 */
		public function milliseconds(...args):*
		{
			return args.length ? _setMilliseconds(args[0]) : _durationWithStagger;
		}
		
		/**
		 * Get or set the animation duration in seconds
		 */
		public function seconds(...args):*
		{
			return args.length ? _setSeconds(args[0]) : _durationWithStagger * 0.001;
		}
		
		/**
		 * Set the animation duration in frames
		 */
		public function frames(...args):*
		{
			return args.length ? _setFrames(args[0]) : _durationWithStagger;
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
			_onInit = callback == null ? FunctionUtil.NULL : callback;
			return this;
		}
		
		public function onChange(callback:Function):Animation
		{
			_onChange = callback == null ? FunctionUtil.NULL : callback;
			return this;
		}
		
		public function onYoyo(callback:Function):Animation
		{
			_onYoyo = callback == null ? FunctionUtil.NULL : callback;
			return this;
		}
		
		public function onComplete(callback:Function):Animation
		{
			_onComplete = callback == null ? FunctionUtil.NULL : callback;
			return this;
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Private Parts
		/////////////////////////////////////////////////////////////////////////////////
		
		override internal function get _totalDuration():Number
		{
			return _iterations <= 0 || isNaN(_iterations) ? Infinity : _durationWithStagger * _iterations * (_yoyo ? 2 : 1);
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
			_stagger = value * 1000;
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
					
					var tweener:ITweener = child._tweeners[property] ||= _createTweener(target, property);
					
					// boolean tween bug where start isnt set dynamically when in to
					if (tweener)
					{
						/** the property in? fork fills in the blank for assumed things left out of the other param list **/
						//tweener.init(
						
							// this will not work for custom named properties
							// I need to delegate more to tweener in this regard
							// tweener.init(target, property, from, to)
							
							//property in from ? from[property] : target[property]
							//,to[property]
						//);
						
						tweener.initialize(
							target
							,property
							,from
							,to
							,property in from
								? from[property]
								: property in target
									? target[property]
									: null
							,property in to
								? to[property]
								: null
							);
					}
				}
			}
			callback(isJump);
		}
		
		override internal function _render(position:Number, isGoto:Boolean = false, triggerCallbacks:Boolean = true, progress:Number = NaN):void
		{
			var initHandler:Function = FunctionUtil.NULL
				,changeHandler:Function = FunctionUtil.NULL
				,yoyoHandler:Function = FunctionUtil.NULL
				,completeHandler:Function = FunctionUtil.NULL
				,yoyosCompleted:int = 0
				,endPosition:Number = _endPosition;
			
			_previousPosition = _position;
			_position = Math.min(position, endPosition);
			
			const isComplete:Boolean = _position >= endPosition;
			const isMovingForward:Boolean = _position > _previousPosition;
			var renderedPosition:Number = isComplete
				? _yoyo ? 0 : endPosition
				: _position < 0 ? 0 : _position % _durationWithStagger;
			
			// optional failfast
			//if (isComplete && _previousPosition == endPosition) return;
			
			if (_yoyo)
			{
				const currentCompletedCycles:int = _position / _durationWithStagger;
				
				// this happens after yoyo is coming back. thats a problem
				yoyosCompleted = ((currentCompletedCycles + 1) >> 1) - (((_previousPosition / _durationWithStagger) + 1) >> 1);
				
				if (currentCompletedCycles & 1 == 1)
					renderedPosition = _durationWithStagger - renderedPosition;
			}
			
			/**
			 * Akward null object pattern usage to avoid duplicate "if" statements for efficiency
			 */
			if (triggerCallbacks)
			{
				changeHandler = _changeHandler;
				if (isMovingForward){ initHandler = _initHandler; yoyoHandler = _yoyoHandler; completeHandler = _completeHandler; }
			}
			
			if (_position != _previousPosition)
			{
				_initialized || _initialize(isGoto, initHandler);
				
				var totalChildren:int = _children.length;
				if (isMovingForward){ var index:int = 0, step:int = 1; } else { index = totalChildren - 1; step = -1; }
				for (; totalChildren-- > 0; index += step)
				{
					var child:AnimationBase = _children[index];
					var childPosition:Number = renderedPosition - _childrenPositions[index] - index * _stagger;
					
					// polymorphic but does unnecessary calls to MathUtil.limit & _ease() when child is nested Animation
					child._render(childPosition, isGoto, triggerCallbacks, _ease(MathUtil.limit(childPosition/_duration, 0, 1), 0, 1, 1) );
				}
				
				changeHandler(isGoto);
			}
			
			while (yoyosCompleted-- > 0)
			{
				yoyoHandler(isGoto);
			}
			
			if (isComplete)
			{
				// invalidate screws with child animations
				//invalidate().pause(); // should this be triggered when jumping ?
				//hoftix to only invalidate parent animation not nested animations that complete
				isNaN(progress) && invalidate();
				pause();
				completeHandler(isGoto);
			}
			
			//trace(renderedPosition);
		}
		
		private function get _durationWithStagger():Number
		{
			return _duration + (_children.length - 1) * _stagger;
		}
		
	}

}
