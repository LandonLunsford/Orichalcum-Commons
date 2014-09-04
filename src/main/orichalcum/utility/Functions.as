package orichalcum.utility
{

	public class Functions
	{
		
		static public const NULL:Function = function(...args):* { return undefined; };
		static public const NULL_PIPE:Function = function(a:*):* { return a; };
		static public const RETURN_TRUE:Function = function(...args):* { return true; };
		static public const RETURN_FALSE:Function = function(...args):* { return false; };
		
		static public function nullToEmpty(method:Function):Function
		{
			return method == null ? NULL : method;
		}
		
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
