package orichalcum.animation20130620 
{
	import flash.errors.IllegalOperationError;

	public class AnimationBase implements IAnimation
	{
		
		public function AnimationBase() 
		{
			
		}
		
		
		protected function _render(target:Object, value:Number, isJump:Boolean = false, triggerCallbacks:Boolean = true):void
		{
			// parent animation needs to proxy target, timeScale, useFrames
			// to proxy this add parent and recursive lookups for each value
		}
		
		/* INTERFACE orichalcum.animation.IAnimation */
		
		public function get target():Object 
		{
			throw new IllegalOperationError;
		}
		
		public function set target(value:Object):void 
		{
			throw new IllegalOperationError;
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
		
		public function get useFrames():Boolean 
		{
			throw new IllegalOperationError;
		}
		
		public function set useFrames(value:Boolean):void 
		{
			throw new IllegalOperationError;
		}
		
		public function get timeScale():Number 
		{
			throw new IllegalOperationError;
		}
		
		public function get timeScale():void 
		{
			throw new IllegalOperationError;
		}
		
		public function get isPlaying():Boolean 
		{
			throw new IllegalOperationError;
		}
		
		public function get isPaused():Boolean 
		{
			throw new IllegalOperationError;
		}
		
		public function add(animation:IAnimation):IAnimationBuilder 
		{
			throw new IllegalOperationError;
		}
		
		public function animate(target:Object):IAnimationBuilder 
		{
			throw new IllegalOperationError;
		}
		
		public function to(...args):IAnimationBuilder 
		{
			throw new IllegalOperationError;
		}
		
		public function from(...args):IAnimationBuilder 
		{
			throw new IllegalOperationError;
		}
		
		public function delay(duration:Number):IAnimationBuilder 
		{
			throw new IllegalOperationError;
		}
		
		public function call(callback:Function, ...args):IAnimationBuilder 
		{
			throw new IllegalOperationError;
		}
		
		public function play():IAnimation 
		{
			throw new IllegalOperationError;
		}
		
		public function pause():IAnimation 
		{
			throw new IllegalOperationError;
		}
		
		public function toggle(flag:Boolean):IAnimation 
		{
			throw new IllegalOperationError;
		}
		
		public function stop():IAnimation 
		{
			throw new IllegalOperationError;
		}
		
		public function replay():IAnimation 
		{
			throw new IllegalOperationError;
		}
		
		public function goto(position:Number):IAnimation 
		{
			throw new IllegalOperationError;
		}
		
		public function rewind():IAnimation 
		{
			throw new IllegalOperationError;
		}
		
		public function end(triggerCallbacks:Boolean = true):IAnimation 
		{
			throw new IllegalOperationError;
		}
		
	}

}