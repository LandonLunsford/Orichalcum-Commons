package orichalcum.logging 
{

	public interface ILog
	{
		function debug(message:String, ...substitutions):void;
		function info(message:String, ...substitutions):void;
		function warn(message:String, ...substitutions):void;
		function error(message:String, ...substitutions):void;
		function fatal(message:String, ...substitutions):void;
	}

}