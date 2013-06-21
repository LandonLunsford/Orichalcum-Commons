package orichalcum.animation 
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import orichalcum.core.Core;
	import orichalcum.utility.FunctionUtil;

	public class Animation extends AnimationBase implements IAnimationBuilder
	{
		
		static public function create(...args):IAnimation
		{
			// similar to tween take target, and options like on complete!
			/**
			 * accept and convert [
			 * [
			 * 	0, Animation.to({...})
			 * 	,1, Animation.from({...})
			 * 	,5, Animation.from
			 */
			return new Animation;
		}
		
		static public function animate(target:Object):IAnimationBuilder
		{
			return create().animate(target);
		}
		
		static public function to(...args):IAnimationBuilder
		{
			return create().to.apply(null, args);
		}
		
		static public function from(...args):IAnimationBuilder
		{
			return create().from.apply(null, args);
		}
		
		static public function delay(duration:Number):IAnimationBuilder 
		{
			return create().delay(duration);
		}
		
		static public function call(callback:Function, ...args):IAnimationBuilder 
		{
			return this;
		}
		
		private var _childrenStartPositions:Vector.<Number> = new Vector.<Number>;
		private var _children:Vector.<AnimationBase> = new Vector.<AnimationBase>;
		private var _currentChildIndex:int;
		private var _target:Object;
		private var _useFrames:Boolean;
		private var _timeScale:Number = 1;
		private var _isPlaying:Boolean;
		private var _completeCallback:Function;
		private var _completeCallbackArguments:Array;
		
		private var _position:Number = 0;
		
		private var _duration:Number = 0;
		
		//private var _delay:Number = 0;
		
		public function Animation() 
		{
			
		}
		
		/* INTERFACE orichalcum.animation.IAnimation */
		
		public function get target():Object 
		{
			return _target;
		}
		
		public function set target(value:Object):void 
		{
			_target = value;
		}
		
		/**
		 * O(n)
		 */
		public function get duration():Number 
		{
			//var duration:Number = 0;
			//for each(var child:AnimationBase in _children)
			//{
				//var endTime:Number = _childrenStartPositions[child] + child.duration;
				//if (endTime > duration)
				//{
					//duration = endTime;
				//}
			//}
			//return duration;
			
			return _duration;
		}
		
		public function set duration(value:Number):void 
		{
			throw new IllegalOperationError;
		}
		
		public function get position():Number 
		{
			return _position;
		}
		
		public function set position(value:Number):void 
		{
			_setPosition(value < 0 ? 0 : value, true);
		}
		
		/**
		 * O(2n)
		 */
		public function get progress():Number 
		{
			duration <= 0 ? 0 : _position / duration;
		}
		
		public function set progress(value:Number):void 
		{
			_setPosition(value < 0 ? 0 : value * duration, true);
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
		
		public function get isPlaying():Boolean 
		{
			return _isPlaying;
		}
		
		public function get isPaused():Boolean 
		{
			return !_isPlaying;
		}
		
		public function add(animation:IAnimation, time:Number = NaN):IAnimationBuilder 
		{
			var startPosition:Number;
			
			if (isNaN(time))
			{
				startPosition = _duration;
				_duration += animation.duration;
			}
			else
			{
				startPosition = time;
				if (time + animation.duration > _duration)
					_duration = time + animation.duration;
			}
			
			_childrenStartPositions.push(startPosition);
			_children.push(animation);
			return this;
		}
		
		public function animate(target:Object):IAnimationBuilder 
		{
			_target = target; // must set overide in all child tweens
			return this;
		}
		
		public function to(...args):IAnimationBuilder 
		{
			throw new IllegalOperationError;
			return this;
		}
		
		public function from(...args):IAnimationBuilder 
		{
			throw new IllegalOperationError;
			return this;
		}
		
		public function delay(duration:Number):IAnimationBuilder 
		{
			delay += duration;
			return this;
		}
		
		public function call(callback:Function, ...args):IAnimationBuilder 
		{
			_callbacks.push(new _AnimationCallback(_duration, callback, args));
			return this;
		}
		
		public function play():IAnimation 
		{
			return _setIsPlaying(true);
		}
		
		public function pause():IAnimation 
		{
			return _setIsPlaying(false);
		}
		
		public function toggle(flag:* = null):IAnimation 
		{
			return _setIsPlaying(flag == null ? !_isPlaying : flag);
		}
		
		public function stop():IAnimation 
		{
			return rewind().pause();
		}
		
		public function replay():IAnimation 
		{
			return rewind().play();
		}
		
		public function goto(position:Number):IAnimation 
		{
			return _setPosition(position, true);
		}
		
		public function rewind():IAnimation 
		{
			return goto(0);
		}
		
		public function end(triggerCallbacks:Boolean = true):IAnimation 
		{
			return goto(duration, true, triggerCallbacks);
		}
		
		
		//////////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE
		//////////////////////////////////////////////////////////////////////////////////////////////
		
		//private function get delay():Number
		//{
			//return _delay > duration ? _delay : (_delay = duration);
		//}
		
		private function _setIsPlaying(value:Boolean):IAnimation
		{
			if (_isPlaying == value) return;
			
			if (_isPlaying = value)
			{
				Core.eventDispatcher.addEventListener(Event.ENTER_FRAME, _integrate);
			}
			else
			{
				Core.eventDispatcher.removeEventListener(Event.ENTER_FRAME, _integrate);
			}
			return this;
		}
		
		private function _setPosition(value:Number, isJump:Boolean = false, triggerCallbacks:Boolean = true):void
		{
			// not sure how to handle with children timescale * parent.timescale and absolute value setting
			// I would like the timescale to be additive - as that makes sense - but I dont think I can
			// best alternative is just overriding timescale here
			
			_position = value;
			
			for (var i:int = 0; i < _children.length; i++)
			{	
				var child:AnimationBase = _children[i];
				child._render(_target || child.target, value - _childrenStartPositions[i], isJump, triggerCallbacks);
			}
		}
		
		private function _integrate(event:Event):void 
		{
			//_setPosition(_position + (useFrames ? Tween.timeScale : _deltaTime) * timeScale * _step * (yoyo && _position >= 0 ? 2:1));
			//_setPosition(_position + (useFrames ? 1 : Core.deltaTime) * timeScale);
			
			//const deltaPosition:Number = _useFrames ? _timeScale : Core.deltaTime * _timeScale;
			
			//_position += deltaPosition;
			
			//for (var i:int = 0; i < _children.length; i++)
			//{	
				//var child:AnimationBase = _children[i];
				//child._render(_target || child.target, child.position - _childrenStartPositions[i] + deltaPosition * child.timeScale, isJump, triggerCallbacks);
			//}
			
			_setPosition(_position + (_useFrames ? _timeScale : Core.deltaTime * _timeScale));
		}
		
	}

}
