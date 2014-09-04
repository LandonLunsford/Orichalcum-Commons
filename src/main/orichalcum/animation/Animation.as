package orichalcum.animation
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import orichalcum.animation.tweener.BooleanTweener;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.utility.Functions;
	import orichalcum.utility.Mathematics;
	
	/**
	 * @todo make animations copy(deep:Boolean = true) method
	 * @todo streamline plugin strategy (init, tween) methods and tweener creation and initialization to be safe for properties that arent on target
	 * @todo add record() allowing playback of all animations played
	 * @todo add pre/post delay
	 * @todo add wait().call() API, 
	 */
	public class Animation
	{
		
		static public const eventDispatcher:IEventDispatcher = new Shape;
		static public var durations:Object = { slow:800, normal:400, fast:200 };
		static public var defaultEase:Function = Ease.quadOut;
		static private const EPSILON:Number = 0.0001;
		static private var _tweenersByClass:Object = {
			'Boolean':	BooleanTweener,
			'Number':	NumberTweener,
			'int':		NumberTweener,
			'uint':		NumberTweener
		};
		static private var _tweenersByProperty:Object = {};
		static private var _currentTime:Number;
		static private var _deltaTime:Number;
		static private var _timeScale:Number = 1;
		static private var _currentFrame:uint;
		
		static public function get currentFrame():uint
		{
			return _currentFrame;
		}
		
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
				_currentFrame++;
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
		static public function install(plugins:Object, triggers:* = null):void
		{
			if (!plugins)
				throw new ArgumentError('Argument "tweener" passed to method "install" of class "orichalcum.animation.Tween" must not be null.');
			
			if (!(plugins is Array))
				plugins = [plugins];
				
			for each(var plugin:Class in plugins)
			{
				if (triggers)
				{
					triggers = [triggers];
				}
				else if ('properties' in plugin)
				{
					triggers = plugin['properties'];
				}
				else
				{
					throw new ArgumentError('Argument "tweener" passed to method "install" of class "orichalcum.animation.Animation" must specify triggers if no static "properties" member is found on class."');
				}
				
				for each(var trigger:String in triggers)
				{
					if (trigger is String)
					{
						_tweenersByProperty[trigger] = plugin;
					}
					else if (trigger is Class)
					{
						_tweenersByClass[getQualifiedClassName(trigger)] = plugin;
					}
					else
					{
						throw new ArgumentError();
					}
				}
			}
			
		}
		
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
		
		internal var _initialized:Boolean;
		internal var _position:Number = 0;
		internal var _previousPosition:Number = -EPSILON;
		internal var _previousCompletedCycles:int;
		internal var _completedCycles:int;
		internal var _duration:Number = 0;
		internal var _delay:Number = 0;
		internal var _postDelay:Number = 0;
		internal var _iterations:Number = 1;
		internal var _timeScale:Number = 1;
		internal var _ease:Function = defaultEase;
		internal var _isPlaying:Boolean;
		internal var _render:Function = _renderWithoutYoyo;
		internal var _useFrames:Boolean;
		internal var _started:Function = Functions.NULL;
		internal var _changing:Function = Functions.NULL;
		internal var _changed:Function = Functions.NULL;
		internal var _yoyoed:Function = Functions.NULL;
		internal var _completed:Function = Functions.NULL;
		internal var _step:Number = 1;
		internal var _to:Object;
		internal var _from:Object;
		internal var _targets:Array = [];
		internal var _tweenersByTarget:Dictionary = new Dictionary;
		
		
		public function Animation(...targets)
		{
			_setIsPlaying(true);
			
			if (targets.length)
			{
				_setTarget(targets.length == 1 && targets[0] is Array ? targets[0] : targets)
			}
			
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Controls
		/////////////////////////////////////////////////////////////////////////////////
		
		public function play():Animation
		{
			_isAtEnd && rewind(); // video feature
			return _setIsPlaying(true);
		}
		
		public function pause():Animation
		{
			return _setIsPlaying(false);
		}
		
		public function toggle():Animation
		{
			return _isPlaying ? pause() : play();
		}
		
		public function stop():Animation
		{
			return rewind().pause();
		}
		
		public function replay():Animation
		{
			return rewind().play();
		}
		
		public function rewind():Animation
		{
			return goto(-_delay);
		}
		
		public function end():Animation
		{
			return goto(_endPosition);
		}
		
		public function next():Animation
		{
			return goto(_position + (_useFrames ? 1 : _deltaTime));
		}
		
		public function previous():Animation
		{
			return goto(_position - (_useFrames ? 1 : _deltaTime));
		}
		
		public function goto(position:Number):Animation
		{
			return _setPosition(position);
		}
		
		public function reverse():Animation
		{
			_step = -_step;
			return this;
		}
		
		public function invalidate():Animation
		{
			_initialized = false;
			return this;
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Accessors and Modifiers
		/////////////////////////////////////////////////////////////////////////////////
		
		public function target(...args):*
		{
			return args.length ? _setTarget(args.length == 1 && args[0] is Array ? args[0] : args) : _getTarget();
		}
		
		public function isPaused():Boolean
		{
			return !_isPlaying;
		}
		
		public function isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function isPlayingForward():Boolean
		{
			return _isPlaying && _previousPosition < _position;
		}
		
		public function isPlayingBackward():Boolean
		{
			return _isPlaying && _previousPosition > _position;
		}
		
		public function to(...args):*
		{
			return args.length ? _setTo(args[0]) : (_to ||= {});
		}
		
		public function from(...args):*
		{
			return args.length ? _setFrom(args[0]) : (_from ||= {});
		}
		
		private function previousPosition():Number
		{
			return _previousPosition;
		}
		
		public function lastPositionChange():Number
		{
			return _position - _previousPosition;
		}
		
		public function position(...args):*
		{
			return args.length ? _setPosition(args[0]) : _position;
		}
		
		public function progress(...args):*
		{
			return args.length ? _setProgress(args[0]) : _progress;
		}
		
		public function delay(...args):*
		{
			return args.length ? _setDelay(args[0]) : _delay;
		}
		
		public function duration(...args):*
		{
			return args.length ? _setDuration(args[0]) : _duration;
		}
		
		public function postDelay(...args):*
		{
			return args.length ? _setPostDelay(args[0]) : _postDelay;
		}
		
		public function timeScale(...args):*
		{
			return args.length ? _setTimeScale(args[0]) : _timeScale;
		}
		
		public function frames():*
		{
			_useFrames = true;
			return this;
		}
		
		public function seconds():*
		{
			_useFrames = false;
			return this;
		}
		
		public function ease(...args):*
		{
			return args.length ? _setEase(args[0]) : _ease;
		}
		
		public function yoyo(...args):*
		{
			return args.length ? _setYoyo(args[0]) : _yoyo;
		}
		
		public function repeat(...args):*
		{
			return args.length ? _setRepeat(args[0]) : _repeat;
		}
		
		public function started(callback:Function):Animation
		{
			_started = callback == null ? Functions.NULL : callback;
			return this;
		}
		
		public function changing(callback:Function):Animation
		{
			_changing = callback == null ? Functions.NULL : callback;
			return this;
		}
		
		public function changed(callback:Function):Animation
		{
			_changed = callback == null ? Functions.NULL : callback;
			return this;
		}
		
		public function yoyoed(callback:Function):Animation
		{
			_yoyoed = callback == null ? Functions.NULL : callback;
			return this;
		}
		
		public function completed(callback:Function):Animation
		{
			_completed = callback == null ? Functions.NULL : callback;
			return this;
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Private Parts
		/////////////////////////////////////////////////////////////////////////////////
		
		protected function get _progress():Number
		{
			return _position / getTotalDuration();
		}
		
		protected function get _repeat():Number
		{
			return _iterations - 1;
		}
		
		protected function get _yoyo():Boolean
		{
			return _render == _renderYoyo;
		}
		
		protected function get _endPosition():Number
		{
			return getTotalDuration();
		}
		
		protected function get _isAtEnd():Boolean
		{
			return _position >= getTotalDuration();
		}
		
		protected function _getTarget():*
		{
			return _targets;
		}
		
		protected function _setTarget(arg:*):Animation
		{
			_targets = arg;
			return this;
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
		
		protected function _setPosition(value:Number):Animation
		{
			_render(value);
			return this;
		}
		
		protected function _setProgress(value:Number):Animation
		{
			_setPosition(value * getTotalDuration());
			return this;
		}
		
		protected function _setDelay(value:Number):Animation 
		{
			_delay = value;
			return this;
		}
		
		protected function _setPostDelay(value:Number):Animation 
		{
			_postDelay = value;
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
				_duration = value in durations ? durations[value] : durations.normal;
			}
			else if (value is Number)
			{
				_duration = Mathematics.limit(value, 0, Number.MAX_VALUE);
			}
			else
			{
				_duration = durations.normal;
			}
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
				_ease = value in Ease ? Ease[value] : Animation.defaultEase;
			}
			else
			{
				_ease = Animation.defaultEase;
			}
			return this;
		}
		
		protected function _setYoyo(value:Boolean):Animation
		{
			_render = value ? _renderYoyo : _renderWithoutYoyo;
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
				_isPlaying = value;
				
				if (value)
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
		
		protected function _initHandler():void 
		{
			_started.call(this)
		}
		
		protected function _changingHandler():void 
		{
			_changing.call(this)
		}
		
		protected function _changedHandler():void 
		{
			_changed.call(this)
		}
		
		protected function _yoyoedHandler():void 
		{
			_yoyoed.call(this)
		}
		
		protected function _completedHandler():void 
		{
			_completed.call(this)
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Overrides
		/////////////////////////////////////////////////////////////////////////////////
		
		protected function _initialize():void
		{
			_initialized = true;
			
			for each(var target:* in _targets)
			{
				var from:Object = _from ? _from : target;
				var to:Object = _to ? _to : target;
				
				if (to === from) return;
				
				var values:Object = _to ? _to : _from;
				var tweeners:Dictionary = _tweenersByTarget[target] ||= new Dictionary;
				
				for (var property:String in values)
				{
					
					var tweener:ITweener = tweeners[property] ||= _createTweener(target, property);
					
					if (!tweener)
						throw new ArgumentError();
						
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
		
		protected function _integrate(event:Event = null):void 
		{
			_isPlaying && _render(
				_position
				+ (_useFrames ? 1 : deltaTime)
				* Animation.timeScale
				* _timeScale
				* _step
			);
		}
		
		private function getIterationDuration():Number
		{
			return (_delay + _duration + _postDelay)
				* (_useFrames ? 1 : 1000)
		}
		
		private function getTotalDuration():Number
		{
			return _iterations <= 0 || isNaN(_iterations)
				? Infinity
				: getIterationDuration()
					* _iterations
					* (_yoyo ? 2 : 1);
		}
		
		private function _renderYoyo(position:Number):void
		{
			
			/**
			 * Recompute these everytime one of its dependencies change but not now
			 */ 
			const scale:Number = _useFrames ? 1 : 1000;
			const delay:Number = _delay * scale;
			const duration:Number = _duration * scale;
			const postDelay:Number = _postDelay * scale;
			const iterationDuration:Number = delay + duration + postDelay;
			const totalDuration:Number = _iterations <= 0 || isNaN(_iterations) ? Infinity : iterationDuration * _iterations * 2; // x2 for yoyo
			
			if (_initialized)
			{
				_previousPosition = _position;
				_position = Mathematics.limit(position, 0, totalDuration);
				_previousCompletedCycles = _completedCycles;
			}
			else
			{
				_initialize();
				_initHandler();
				
				_previousPosition = -EPSILON;
				_position = 0;
				_previousCompletedCycles = 0;
				_completedCycles = 0;
			}
			
			const changed:Boolean = _position != _previousPosition;
			if (!changed) return;
			
			_completedCycles = _position / iterationDuration;
			const isInReverseCycle:Boolean = (_completedCycles & 1) == 1;
			
			const completed:Boolean = _position >= totalDuration;
			const renderPosition:Number = (_position % iterationDuration) - (isInReverseCycle ? postDelay : delay);
			
			var renderProgress:Number = 0;
			if (completed)
			{
				renderProgress = 1;
			}
			if (renderPosition <= 0)
			{
				renderProgress = 0;
			}
			else if (renderPosition >= duration
			|| duration == 0) // must come after renderPosition <= 0 check so when in delay it renders as 0
			{
				renderProgress =  1;
			}
			else
			{
				renderProgress = _ease(renderPosition / duration, 0, 1, 1);
			}
			/**/
			if (isInReverseCycle)
			{
				// inacurate.. i need to reverse the ease function too...
				renderProgress = 1 - renderProgress;
			}
			
			_changingHandler();
			for each(var target:Object in _targets)
			{
				var tweeners:Dictionary = _tweenersByTarget[target];
				for (var property:String in tweeners)
				{
					tweeners[property].tween(target, property, renderProgress);
				}
			}
			_changedHandler();
			
			const realPosition:Number = _position;
			const yoyosCompleted:int = ((_completedCycles + 1) >> 1) - ((_previousCompletedCycles + 1) >> 1);
			while (yoyosCompleted-- > 0)
			{
				_position = (_previousCompletedCycles + yoyosCompleted) * iterationDuration;
				_yoyoedHandler();
			}
			_position = realPosition;
			
			if (completed)
			{
				if (isPlaying())
				{
					invalidate();
					pause();
				}
				_completedHandler();
			}
		}
		
		private function _renderWithoutYoyo(position:Number):void
		{
			/**
			 * Recompute these everytime one of its dependencies change but not now
			 */ 
			const scale:Number = _useFrames ? 1 : 1000;
			const delay:Number = _delay * scale;
			const duration:Number = _duration * scale;
			const postDelay:Number = _postDelay * scale;
			const iterationDuration:Number = delay + duration + postDelay;
			const totalDuration:Number = _iterations <= 0 || isNaN(_iterations) ? Infinity : iterationDuration * _iterations;
			
			if (_initialized)
			{
				_previousPosition = _position;
				_position = Mathematics.limit(position, 0, totalDuration);
			}
			else
			{
				_initialize();
				_initHandler();
				
				_previousPosition = -EPSILON;
				_position = 0;
			}
			
			const changed:Boolean = _position != _previousPosition;
			if (!changed) return;
			
			const completed:Boolean = _position >= totalDuration;
			const renderPosition:Number = (_position % iterationDuration) - delay;
			
			var renderProgress:Number = 0;
			if (completed) // cancells modulo error of turning 100% to 0
			{
				renderProgress = 1;
			}
			else if (renderPosition <= 0)
			{
				renderProgress = 0;
			}
			else if (renderPosition >= duration
			|| duration == 0) // must come after renderPosition <= 0 check so when in delay it renders as 0
			{
				renderProgress = 1;
			}
			else
			{
				renderProgress = _ease(renderPosition / duration, 0, 1, 1);
			}
			
			_changingHandler();
			for each(var target:Object in _targets)
			{
				var tweeners:Dictionary = _tweenersByTarget[target];
				for (var property:String in tweeners)
				{
					tweeners[property].tween(target, property, renderProgress);
				}
			}
			_changedHandler();
			
			if (completed)
			{
				if (isPlaying())
				{
					invalidate();
					pause();
				}
				_completedHandler();
			}
			
		}
		
	}

}
