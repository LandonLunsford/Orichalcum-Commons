package orichalcum.utility
{

	public class FunctionUtil
	{
		
		static public const noop:Function = function(...args):* { return undefined; };
		
		static public function safeCallWithArgs(method:Function, thisObject:Object = null, args:Array = null):*
		{
			args.length > method.length && (args.length = method.length);
			return method.apply(thisObject, args);
		}
		
		static public function safeCall(method:Function, thisObject:Object = null, ...args):*
		{
			return safeCallWithArgs(method, thisObject, args);
		}
		
	}

}
