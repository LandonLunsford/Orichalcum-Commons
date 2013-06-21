package orichalcum.animation20130620 
{

	internal class _AnimationCallback 
	{
		private var _startPosition:Number;
		private var _callback:Function;
		private var _callbackArguments:Array;
		
		public function _AnimationCallback(startPosition:Number, callback:Function, callbackArguments:Array) 
		{
			_startPosition = startPosition;
			_callback = callback;
			_callbackArguments = callbackArguments;
			
		}
		
		public function call():Boolean
		{
			
		}
		
	}

}