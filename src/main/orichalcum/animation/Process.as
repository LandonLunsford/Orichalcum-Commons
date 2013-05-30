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
	
	internal class Process extends EventDispatcher
	{
		static private var _emptyFunction:Function = function():void {};
		
		static public function loop(callback:Function, interval:int = 1, ...args):Process
		{
			return fork(callback, interval, Infinity, args);
		}
		
		static public function delay(callback:Function, duration:int = 1, ...args):Process
		{
			return fork(callback, duration, 0, args);
		}
		
		static public function begin(callback:Function, interval:int = 1, iterations:Number = Infinity, ...args):Process
		{
			return fork(callback, interval, iterations - 1, args);
		}
		
		static private function fork(callback:Function, interval:int = 1, repeats:Number = 0, args:Array = null):Process
		{
			const process:Process = new Process;
			process.callback = callback == null ? _emptyFunction : callback;
			process.interval = interval;
			process.repeats = repeats;
			process.args = args;
			process.time = 0;
			process.start();
			return process;
		}
		
		public var time:int;
		public var interval:int;
		public var repeats:Number = 0;
		public var callback:Function;
		public var args:Array;
		
		public function start():void
		{
			_eventDispatcher.addEventListener(Event.ENTER_FRAME, update, true, 0, false);
			//dispatchEvent(INIT_EVENT);
		}
		
		public function pause():void
		{
			_eventDispatcher.removeEventListener(Event.ENTER_FRAME, update);
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