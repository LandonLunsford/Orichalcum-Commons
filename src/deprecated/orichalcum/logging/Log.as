package orichalcum.logging 
{
	import flash.utils.getTimer;
	import mx.utils.StringUtil;

	internal class Log implements ILog
	{
		private var _source:Object;
		private var _target:ILogTarget;
		
		public function Log(source:Object, target:ILogTarget)
		{
			_source = source;
			_target = target;
		}
		
		/* INTERFACE orichalcum.logging.ILog */
		
		public function debug(message:String, ...substitutions):void 
		{
			log(LogLevel.DEBUG, message, substitutions);
		}
		
		public function info(message:String, ...substitutions):void 
		{
			log(LogLevel.INFO, message, substitutions);
		}
		
		public function warn(message:String, ...substitutions):void 
		{
			log(LogLevel.WARN, message, substitutions);
		}
		
		public function error(message:String, ...substitutions):void 
		{
			log(LogLevel.ERROR, message, substitutions);
		}
		
		public function fatal(message:String, ...substitutions):void 
		{
			log(LogLevel.FATAL, message, substitutions);
		}
		
		/* PRIVATE */
		
		private function log(level:LogLevel, message:String, substitutions:Array = null):void
		{
			_target.log(level, _source, StringUtil.substitute(message, substitutions));
		}
		
	}

}