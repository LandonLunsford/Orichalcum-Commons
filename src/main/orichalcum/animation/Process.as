package orichalcum.animation 
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * @TODO add necessary target argument -- this will be to implement a 'pauseAllProcessesFor(target)' which will be useful for
	 * pausing delays, tweens etc.
	 * 
	 * @author Landon Lunsford
	 */
	
	public class Process extends EventDispatcher
	{
		public var time:int;
		public var interval:int;
		public var repeats:Number = 0;
		public var callback:Function;
		public var args:Array;
		
		public function start():void
		{
			coreEventDispatcher.addEventListener(Event.ENTER_FRAME, update, true, 0, false);
			//dispatchEvent(INIT_EVENT);
		}
		
		public function pause():void
		{
			coreEventDispatcher.removeEventListener(Event.ENTER_FRAME, update);
		}
		
		public function reset():void
		{
			time = 0;
		}
		
		public function restart():void
		{
			reset();
			start();
		}
		
		internal function update(event:Event = null):void
		{
			time++;
			onUpdate();
			if (time >= interval)
			{
				if (isFinite(repeats) && --repeats < 0)
					return onComplete();
				time = interval - time;
				onIteration();
			}
		}
		
		public function dispose():void
		{
			callback = null;
			args.length = 0;
			args = null;
		}
		
		protected function onUpdate():void
		{
			//dispatchEvent(CHANGE_EVENT);
		}

		protected function onIteration():void
		{
			execute();
			//dispatchEvent(REPEAT_EVENT);
		}
		
		protected function onComplete():void
		{
			pause();
			execute();
			//dispatchEvent(COMPLETE_EVENT);
		}
		
		protected function execute():void
		{
			if (callback != null)
				callback.apply(null, args);
		}
		
	}

}