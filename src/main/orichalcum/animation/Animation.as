package orichalcum.animation 
{
	import flash.errors.IllegalOperationError;

	/**
	 * @author Landon Lunsford
	 */

	public class Animation implements IAnimation 
	{
		
		static public function create(...args):IAnimation
		{
			// similar to tween take target, and options like on complete!
			return new Animation;
		}
		
		static public function animate(target:Object):IAnimation
		{
			return create().animate(target);
		}
		
		static public function to(...args):IAnimation
		{
			return create().to.apply(null, args);
		}
		
		static public function from(...args):IAnimation
		{
			return create().from.apply(null, args);
		}
		
		static public function delay(duration:Number, useFrames:Boolean = false):IAnimation 
		{
			return create().delay(duration, useFrames);
		}
		
		static public function call(callback:Function, ...args):IAnimation 
		{
			return this;
		}
		
		static public function complete(callback:Function, ...args):IAnimation 
		{
			return this;
		}
		
		/**
		 * DisplayObjectContainer of Animations
		 */
		private var _parent:IAnimation;
		private var _children:Vector.<Object>;
		private var _currentChildIndex:int;
		
		
		private var _target:Object;
		private var _useFrames:Boolean = null;
		private var _timeScale:Number = 1;
		
		private var _completeCallback:Function;
		private var _completeCallbackArguments:Array;
		
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
		
		public function get duration():Number 
		{
			throw new IllegalOperationError;
		}
		
		public function set duration(value:Number):void 
		{
			throw new IllegalOperationError;
		}
		
		public function get position():Number 
		{
			throw new IllegalOperationError;
		}
		
		public function set position(value:Number):void 
		{
			throw new IllegalOperationError;
		}
		
		public function get progress():Number 
		{
			throw new IllegalOperationError;
		}
		
		public function set progress(value:Number):void 
		{
			throw new IllegalOperationError;
		}
		
		public function get timeScale():Number
		{
			return _parent ? _parent.timeScale * _timeScale : _timeScale;
		}
		
		public function set timeScale(value:Number):void 
		{
			_timeScale = value;
		}
		
		public function get useFrames():Boolean
		{
			return _parent ? _parent.useFrames : _useFrames;
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
			return _isPaused;
		}
		
		public function add(animation:IAnimation):IAnimation 
		{
			animation.parent = this;
			_children.push(animation);
			return this;
		}
		
		public function animate(target:Object):IAnimation 
		{
			_target = target; // must set overide in all child tweens
			return this;
		}
		
		public function to(...args):IAnimation 
		{
			return this;
		}
		
		public function from(...args):IAnimation 
		{
			return this;
		}
		
		public function delay(duration:Number, useFrames:Boolean = false):IAnimation 
		{
			return this;
		}
		
		public function call(callback:Function, ...args):IAnimation 
		{
			return this;
		}
		
		public function complete(callback:Function, ...args):IAnimation 
		{
			return this;
		}
		
		public function play():IAnimation 
		{
			return this;
		}
		
		public function pause():IAnimation 
		{
			return this;
		}
		
		public function toggle(flag:Boolean):IAnimation 
		{
			return this;
		}
		
		public function stop():IAnimation 
		{
			return this;
		}
		
		public function replay():IAnimation 
		{
			return this;
		}
		
		public function goto(position:Number):IAnimation 
		{
			return this;
		}
		
		public function rewind():IAnimation 
		{
			return this;
		}
		
		public function end(triggerCallbacks:Boolean = true):IAnimation 
		{
			return this;
		}
		
		
		//////////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE
		//////////////////////////////////////////////////////////////////////////////////////////////
		
		
		public function get children():Vector.<Object> 
		{
			return _children ||= new Vector.<Object>;
		}
		
		
		
	}

}