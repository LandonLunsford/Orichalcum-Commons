package orichalcum.utility
{
	public class Strings
	{
		static private const DIGIT_STRINGS:Vector.<String> = new < String > ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
		
		static public function fromDigit(digit:int):String
		{
			return DIGIT_STRINGS[digit];
		}
		
		static public function isNullOrEmpty(value:String):Boolean
		{
			return value == null || value.length == 0;
		}
		
		static public function nullToEmpty(value:String):String
		{
			return value ? value : '';
		}
		
		static public function startsWith(value:String, prefix:String):Boolean
		{
			return prefix == value.substring(0, prefix.length);
		}
		
		static public function startsWithIgnoreCase(value:String, prefix:String):Boolean
		{
			value = value.toLowerCase();
			prefix = prefix.toLowerCase();
			return prefix == value.substring(0, prefix.length);
		}
		
		static public function endsWith(value:String, suffix:String):Boolean
		{
			return suffix == value.substring(value.length - suffix.length);
		}
		
		static public function endsWithIgnoreCase(value:String, suffix:String):Boolean
		{
			value = value.toLowerCase();
			suffix = suffix.toLowerCase();
			return suffix == value.substring(value.length - suffix.length);
		}
		
		static public function padLeft(string:String, padding:String = ' ', totalLength:int = 0):String
		{
			if (totalLength == 0) return string;
				
			while (string.length < totalLength)
				string = padding + string;
				
			return string;
		}
		
		static public function padRight(string:String, padding:String = ' ', totalLength:int = 0):String
		{
			if (totalLength == 0) return string;
				
			while (string.length < totalLength)
				string = string + padding;
				
			return string;
		}
		
		static public function substitute(string:String, ...substitutions):String
		{
			if (!substitutions
			|| substitutions.length == 0)
				return string;
				
			return substitutions[0] is Array
				? _substitute(string, substitutions[0])
				: _substitute(string, substitutions);
		}
		
		static private function _substitute(string:String, substitutions:Array):String
		{
			var i:int;
			return string.replace(/{}/g, function():String { return substitutions[i++]; });
		}
		
	}
}
