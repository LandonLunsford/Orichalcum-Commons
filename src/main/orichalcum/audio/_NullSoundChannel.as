package orichalcum.audio 
{
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.media.SoundTransform;

	internal class _NullSoundChannel implements IEventDispatcher
	{
		public function get position():Number { return 0; }
		public function set soundTransform(value:SoundTransform):void {}
		
		/* INTERFACE flash.events.IEventDispatcher */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {}
		public function dispatchEvent(event:Event):Boolean {return false;}
		public function hasEventListener(type:String):Boolean {return false;}
		public function willTrigger(type:String):Boolean {return false;}
	}

}