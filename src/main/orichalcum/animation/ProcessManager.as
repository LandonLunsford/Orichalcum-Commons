package orichalcum.animation 
{

	public class ProcessManager 
	{
		
		private var _emptyFunction:Function = function():void {};
		
		public function loop(callback:Function, interval:int = 1, ...args):Process
		{
			return fork(callback, interval, Infinity, args);
		}
		
		public function delay(callback:Function, duration:int = 1, ...args):Process
		{
			return fork(callback, duration, 0, args);
		}
		
		public function begin(callback:Function, interval:int = 1, iterations:Number = Infinity, ...args):Process
		{
			return fork(callback, interval, iterations - 1, args);
		}
		
		private function fork(callback:Function, interval:int = 1, repeats:Number = 0, args:Array = null):Process
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
		
	}

}