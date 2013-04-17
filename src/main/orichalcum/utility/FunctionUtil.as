package orichalcum.utility
{

	public class FunctionUtil
	{
		
		static public const noop:Function = function(...args):* { return undefined; };
		
		static public function safeCall(method:Function, thisObject:Object = null, ...arguments):*
		{
			const args:Array = arguments;
			args.length = method.length;
			return method.apply(thisObject, args);
		}
		
	}

}
