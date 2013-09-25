package orichalcum.utility
{
	public class Strings
	{

		static public function interpolate(string:String, ...substitutions):String
		{
			return _interpolate(string, substitutions);
		}
		
		static private function _interpolate(string:String, substitutions:Array):String
		{
			var i:int;
			return string.replace(/{}/g, function():String { return substitutions[i++]; });
		}
		
	}
}
