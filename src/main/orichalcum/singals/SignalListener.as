package orichalcum.framework.signal
{

	public class SignalListener implements ISignalListener
	{
	
		private var _callback:Function;
		private var _callOnce:Boolean;
		
		public function compose(callback:Function):SignalListener
		{
			_callback = callback;
			_callOnce = false;
			return this;
		}
		
		public function dispose():SignalListener
		{
			_callback = null;
			return this;
		}
		
		public function callOnce():void
		{
			_callOnce = true;
		}
		
		public function call():void
		{
			_callback();
		}
		
		public function get remove():Boolean
		{
			return _callOnce;
		}
		
	}
	
}	
	
