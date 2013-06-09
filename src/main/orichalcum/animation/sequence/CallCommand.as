package orichalcum.animation.sequence 
{
	import orichalcum.animation.IPlayable;
	import orichalcum.utility.FunctionUtil;

	internal class CallCommand extends BaseCommand
	{
		
		private var _caller:Object;
		private var _function:Function;
		private var _arguments:Array;
		
		public function CallCommand(args:Array) 
		{
			if (args.length == 0)
				throw new ArgumentError('Argument "args" passed to method "CallCommand" must have length greater than 0.');
				
			const arg0:* = args[0];
			
			if (arg0 is Function)
			{
				_function = arg0;
				_arguments = args.slice(1);
			}
			else if (arg0 is Object)
			{
				_caller = arg0;
				
				if (args.length < 2)
					throw new ArgumentError('Method "CallCommand" expects a Function to be either the first or second argument.');
					
				_function = args[1];
				
				if (_function == null)
					throw new ArgumentError('Method "CallCommand" expects Function to be the second argument when an Object is the first.');
				
				if (args.length > 2)
					_arguments = args.slice(2);
			}
		}
		
		override public function play(onComplete:Function = null, ...args):IPlayable 
		{
			FunctionUtil.callWith(_function, _caller, _arguments);
			FunctionUtil.callWith(onComplete, null, args);
			return this;
		}
		
	}

}