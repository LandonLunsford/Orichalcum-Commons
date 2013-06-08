package orichalcum.animation 
{
	import flash.errors.IllegalOperationError;

	public class Command
	{
		
		private static const _commandPool:Array = [];
		private var _previous:Command;
		private var _next:Command;
		
		public function Command(previous:Command) 
		{
			_previous = previous;
		}
		
		static private function _createCommand(previous:Command = null):Command
		{
			return new Command(previous);
		}
		
		
		static public function call(...args):Command
		{
			return _createCommand().call.apply(args);
		}
		
		static public function wait(timeOrFrames:Number):Command
		{
			return _createCommand().wait.apply(args);
		}
		
		static public function animate(...args):Command
		{
			return _createCommand().animate.apply(args);
		}
		
		/**
		 * 
		 * @param	...args
		 * 			call(Function[, args])
		 * 			call(Function[, thisObject, args])
		 * @return
		 */
		public function call(...args):Command
		{
			var totalArguments:int = args.length, params:Array;
			
			if (totalArguments == 0)
				return this;
			
			const fn:Function = args[0];
			
			if (fn == null)
				return this; // or throw error
			
			if (totalArguments > 1)
				params = args.slice(1);
			
			fn.apply(null, params);
			
			return _next = new Command(this);
		}
		
		public function callWith(caller:Object, ...args):Command
		{
			throw new IllegalOperationError;
		}
		
		public function wait(secondsOrFrames:Number, useFrames:Boolean = false):Command
		{
			if (secondsOrFrames <= 0)
				trace('bypass');//bypass
			
			return _next = new Command(this);
		}
	}

}
