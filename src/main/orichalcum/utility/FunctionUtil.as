package orichalcum.utility
{

	public class FunctionUtil
	{
		
		static public const noop:Function = function(...args):* { return undefined; };
		
		static public function callWith(method:Function, thisObject:Object = null, args:Array = null):*
		{
			if (method == null) return undefined;
			
			args && args.length > method.length && (args.length = method.length);
			return method.apply(thisObject, args);
		}
		
		static public function call(method:Function, thisObject:Object = null, ...args):*
		{
			return callWith(method, thisObject, args);
		}
		
	}

}
