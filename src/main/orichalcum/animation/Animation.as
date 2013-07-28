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
	 * @todo add pre/post delay
	 * @todo defect - no yoyo for each staggered tween
	 * @todo add wait().call() API, 
	 * 
	 * not sure how to do everything
	 * 
	 * 
	 * I want to be able to animate(animations)
	 * animate(targetA, targetB, targetC).yoyo(true).stagger(0.5) ... do the wave
	 * and
	 * animate(animate(targetA,targetB)).yoyo(true) ... yoyo parent only
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
		
		/**
		 * This function is trying to do too much
		 * What it should cover is
		 * 1. default installs of multiple TweenerPlugins in the form of
		 * install([plugins | ...plugins])
		 * 2. install single plugin with one or more triggers
		 * install(plugin, [triggers | ...triggers]
		 * @param	tweener
		 * @param	triggers
		 */
		static public function install(tweener:Object, triggers:* = null):void
		{
			if (tweener == null)
			{
				throw new ArgumentError('Argument "tweener" passed to method "install" of class "orichalcum.animation.Tween" must not be null.');
			}
			else if (tweener is Array || tweener is Vector.<Class>)
			{
				for each(var plugin:Class in tweener)
					plugin && install(plugin, null);
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
					trigger && install(tweener, trigger);
			}
			else if ('properties' in tweener)
			{
				install(tweener, tweener['properties']);
			}
			else
			{
				throw new ArgumentError('Argument "tweener" passed to method "install" of class "orichalcum.animation.Animation" must specify triggers if no static "properties" member is found on class."');
				//throw new ArgumentError('Argument "triggers" passed to method "install" of class "orichalcum.animation.Animation" must be one of the following types: String, Class, Array, Vector.<String>, Vector.<Class>.');
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
		internal var _initialized:Boolean;
		
		/** @private */
		internal var _position:Number = 0;
		
		/** @private */
		internal var _duration:Number = durations.normal;
		
		/** @private */
		internal var _delay:Number = 0;
		
		/** @private */
		internal var _postDelay:Number = 0;
		
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
		internal var _onIteration:Function = FunctionUtil.NULL;
		
		/** @private */
		internal var _onComplete:Function = FunctionUtil.NULL;
		
		/** @private */
		internal var _step:Number = 1;
		
		/** @private */
		internal var _to:Object;
		
		/** @private */
		internal var _from:Object;
		
		/** @private */
		internal var _stagger:Number = 0;
		
		////////////////////////////////////// overhead incurred by polymorphic API approach
		
		/** @private */
		private var _children:Vector.<AnimationBase> = new Vector.<AnimationBase>;
		
		/** @private */
		private var _childrenPositions:Vector.<Number> = new Vector.<Number>;
		
		/** @private */
		private var _insertionTime:Number = 0;
		
		
		////////////////////////////////////// overhead incurred by polymorphic API approach
		
		
		public function Animation(args:Array = null)
		{
			if (!args || args.length == 0)
				return;
				
			const arg0:* = args[0];
			
			if (arg0 is AnimationBase)
			{
				for each(var animation:AnimationBase in args)
				{
					// bad... I want more polymorph
					if (animation is AnimationWait)
					{
						var time:Number = animation._totalDuration; // not duration but total duration
						var previousEndTime:Number = _insertionTime = isNaN(time) ? _childrenPositions[_children.length-1] + _children[_children.length-1]._totalDuration : _insertionTime + time;
						if (_duration < previousEndTime)
							_duration = previousEndTime;
					}
					else if (animation is AnimationBase)
					{
						add(animation);
					}
				}
			}
			else if (arg0 is Object)
			{
				for each(var target:Object in args)
				{
					add(new AnimationChild(target));
				}
			}
			else
			{
				throw new ArgumentError;
			}
			
			/*
			 * AUTOPLAY
			 */
			_setIsPlaying(true);
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
		
		public function wait(time:Number):Animation
		{
			return add(new AnimationWait(time));
		}
		
		public function call(...args):Animation
		{
			return add(new AnimationCall(args));
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
			_isAtEnd && rewind(); // video feature
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
			return goto(-_delay);
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
		
		public function forEach(closure:Function):*
		{
			if (closure == null || closure.length < 1 || closure.length > 2)
				return this;
				
			if (closure.length == 0)
			{
				for each(var child:AnimationBase in _children)
				{
					closure.call(this);
				}
			}
			else if (closure.length == 1)
			{
				for each(child in _children)
				{
					closure.call(this, child);
				}
			}
			else if (closure.length == 2)
			{
				for (var i:int = 0; i < _children.length; i++)
				{
					closure.call(this, child, i);
				}
			}
				
			return this;
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
		 * Get or set the animation delay in frames or seconds
		 */
		public function delay(...args):*
		{
			return args.length ? _setDelay(args[0]) : _delay;
		}
		
		/**
		 * Get or set the animation delay in frames or seconds
		 */
		public function postDelay(...args):*
		{
			return args.length ? _setPostDelay(args[0]) : _postDelay;
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
		 * Set or set the number of times the animation will play from start to end
		 */
		public function iterations(...args):*
		{
			return args.length ? _setIterations(args[0]) : _iterations;
		}
		
		/**
		 * Set or set the number of times the animation will repeat after completion
		 */
		public function repeat(...args):*
		{
			return args.length ? _setRepeat(args[0]) : _iterations - 1;
		}
		
		/**
		 * Set the animation's on init callback to be called the first frame of the animation after it starts for the first time.
		 * @param	...callback Function (function(isJump:Boolean):* { }) where object "this" is the animation
		 * @return
		 */
		public function onInit(callback:Function):Animation
		{
			_onInit = FunctionUtil.nullToEmpty(callback);
			return this;
		}
		
		public function onChange(callback:Function):Animation
		{
			_onChange = FunctionUtil.nullToEmpty(callback);
			return this;
		}
		
		public function onYoyo(callback:Function):Animation
		{
			_onYoyo = FunctionUtil.nullToEmpty(callback);
			return this;
		}
		
		public function onIteration(callback:Function):Animation
		{
			_onIteration = FunctionUtil.nullToEmpty(callback);
			return this;
		}
		
		public function onComplete(callback:Function):Animation
		{
			_onComplete = FunctionUtil.nullToEmpty(callback);
			return this;
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Private Parts
		/////////////////////////////////////////////////////////////////////////////////
		
		override internal function get _totalDuration():Number
		{
			//return _iterations <= 0 || isNaN(_iterations) ? Infinity : _durationWithStagger * _iterations * (_yoyo ? 2 : 1);
			return _iterations <= 0 || isNaN(_iterations)
				? Infinity
				: _durationWithStagger * _iterations;
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
		
		protected function _setDelay(value:Number):Animation 
		{
			_delay = value * 1000;
			return this;
		}
		
		protected function _setPostDelay(value:Number):Animation 
		{
			_postDelay = value * 1000;
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
		
		protected function _setIterations(value:Number):Animation
		{
			_iterations = value;
			return this;
		}
		
		protected function _setRepeat(value:Number):Animation
		{
			return _setIterations(value + 1);
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
		
		/////////////////////////////////////////////////////////////////////////////////
		// Overrides
		/////////////////////////////////////////////////////////////////////////////////
		
		protected function _initialize():void
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
		}
		
		protected function _integrate(event:Event = null):void 
		{
			//trace('int delay', _position, _delay, _position - _delay);
			_isPlaying && _render(_position + (_useFrames ? 1 : deltaTime) * Animation.timeScale * _timeScale * _step * (_yoyo ? 2 : 1), false, true);
		}
		
		// problem is each needs to track its own yoyo stuff
		override internal function _render(position:Number, isGoto:Boolean = false, triggerCallbacks:Boolean = true,  parent:Animation = null):void
		{
			var endPosition:Number = _endPosition;
			
			_position = MathUtil.limit(position, -_delay, endPosition + _postDelay);
			
			//trace('pp', _position);
			
			const isMovingForward:Boolean = _position > _previousPosition;
			
			// hotfix
			if (!_initialized)
			{
				_initialize();
				_position -= _delay;
				_previousPosition -= _delay;
				triggerCallbacks && FunctionUtil.call(_onInit, this, isGoto);
			}
			
			const isComplete:Boolean = _position >= endPosition + _postDelay;
			
			// not sure this invalidate() should be before the initialize below
			if (_step < 0 && _position <= 0)
			{
				parent || invalidate();
				reverse().pause();
			}
			
			if (_position != _previousPosition)
			{
				var totalChildren:int = _children.length;
				if (isMovingForward) { var index:int = 0, step:int = 1; } else { index = totalChildren - 1; step = -1; }
				for (; totalChildren-- > 0; index += step)
				{
					var child:AnimationBase = _children[index];
					var childPosition:Number = _position - _childrenPositions[index] - index * _stagger;
					// polymorphic but does unnecessary calls to MathUtil.limit & _ease() when child is nested Animation
					child._render(childPosition, isGoto, triggerCallbacks, this);
				}
				
				triggerCallbacks && FunctionUtil.call(_onChange, this, isGoto);
			}
			
			if (isComplete)
			{
				//trace('compweet')
				// invalidate screws with child animations
				//invalidate().pause(); // should this be triggered when jumping ?
				//hoftix to only invalidate parent animation not nested animations that complete
				parent || invalidate();
				pause();
				triggerCallbacks && FunctionUtil.call(_onComplete, this, isGoto);
			}
			
			_previousPosition = _position;
			
		}
		
		private function get _durationWithStagger():Number
		{
			return _duration + (_children.length - 1) * _stagger;
		}
		
	}

}
