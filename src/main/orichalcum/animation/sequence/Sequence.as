package orichalcum.animation.sequence 
{
	import flash.errors.IllegalOperationError;
	import orichalcum.animation.IPlayable;
	import orichalcum.utility.FunctionUtil;

	public class Sequence implements ISequence
	{
		
		static private function create():ISequence 
		{
			return new Sequence;
		}
		
		static public function add(command:ISequence):ISequence
		{
			return create().add(command);
		}
		
		static public function call(...args):ISequence
		{
			return create().call.apply(null, args);
		}
		
		static public function wait(duration:Number, useFrames:Boolean = false):ISequence
		{
			return create().wait(duration, useFrames);
		}
		
		public function add(playable:IPlayable):ISequence
		{
			commands.push(playable);
			return this;
		}
		
		public function call(...args):ISequence
		{
			args.length && add(new CallCommand(args));
			return this;
		}
		
		public function wait(duration:Number, useFrames:Boolean = false):ISequence
		{
			duration > 0 && add(new WaitCommand(duration, useFrames));
			return this;
		}
		
		/* INTERFACE orichalcum.animation.IPlayable */
		
		public function play(callback:Function = null, ...args):IPlayable
		{
			return _play(callback, args, 0);
		}
		
		public function replay():IPlayable 
		{
			return this;
		}
		
		public function pause():IPlayable 
		{
			return this;
		}
		
		public function stop():IPlayable 
		{
			return this;
		}
		
		public function toggle():IPlayable 
		{
			return this;
		}
		
		public function end(supressCallbacks:Boolean = false):IPlayable 
		{
			return this;
		}
		
		//////////////////////////////////////////////////////////////////////////////////////////
		// INTERNAL
		//////////////////////////////////////////////////////////////////////////////////////////		
		
		private var _commands:Vector.<IPlayable>;
		
		private function hasCommands():Boolean
		{
			return _commands && _commands.length;
		}
		
		private function get commands():Vector.<IPlayable>
		{
			return _commands ||= new Vector.<IPlayable>;
		}
		
		private function _play(callback:Function, args:Array, commandIndex:int = 0):ISequence
		{
			if (_commands == null || commandIndex >= _commands.length)
			{
				//trace('finish', commandIndex, _commands);
				callback != null && FunctionUtil.callWith(callback, null, args);
			}
			else
			{
				//trace('running', commandIndex, _commands);
				_commands[commandIndex].play(_play, callback, args, commandIndex + 1);
			}
			return this;
		}
		
		
		
		
		
		
		//static private function _createCommand(previous:Command = null):Command
		//{
			//return new Command(previous);
		//}
		
		
		//static public function call(...args):Command
		//{
			//add(new CallCommand(args));
			//
			//throw new IllegalOperationError;
		//}
		//
		//static public function wait(timeOrFrames:Number):Command
		//{
			//throw new IllegalOperationError;
		//}
		//
		//static public function animate(...args):Command
		//{
			//throw new IllegalOperationError;
		//}
		
		
		
		/**
		 * call(Function[, args])
		 * @param	...args 
		 * @return
		 */
		//public function call(...args):Command
		//{
			// if queue && queue.length add callback to endCallbacks on queue.last
			
			//throw new IllegalOperationError;
		//}
		
		//public function callWith(caller:Object, ...args):Command
		//{
			// if queue && queue.length add callback to endCallbacks on queue.last
			
			//throw new IllegalOperationError;
		//}
		
		//public function wait(secondsOrFrames:Number, useFrames:Boolean = false):Command
		//{
			// if wait is <= 0 do nothing and return adding nothing to queue
			// else place a defered on the queue
			
			//throw new IllegalOperationError;
		//}
		
		/**
		 * same as tween args
		 * @param	...args
		 * @return
		 */
		//public function animate(...args):Command
		//{
			// if duration is <= 0 set to final values and return adding nothing to queue
			// else place a defered on the queue
			
			//throw new IllegalOperationError;
		//}
		
		//private function _run(onComplete:Function):ICommand
		//{
			//throw new IllegalOperationError;
		//}
	}

}
