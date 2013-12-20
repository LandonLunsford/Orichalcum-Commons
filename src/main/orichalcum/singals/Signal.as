package orichalcum.signals
{

	import orichalcum.datastructure.Pool;

	public class Signal implements ISignal
	{
	
		static public const listenerPool:Pool = new Pool(
			function(type:Class):SignalListener { return new type; },
			function(instance:SignalListener):SignalListener { return instance.dispose(); }
		);
		
		private var _listeners:Vector.<SignalListener>;
		
		public function Signal()
		{
			_listeners = new Vector.<SignalListener>;
		}
		
		public function dispose():void
		{
			_listeners = null;
		}
		
		protected function get listeners():Vector.<SignalListener>
		{
			return _listeners;
		}
		
		protected function set listeners(value:Vector.<SignalListener>):void
		{
			_listeners = value;
		}
		
		public function hasListeners():Boolean
		{
			return totalListeners > 0;
		}
	
		public function hasListener(callback:Function):Boolean
		{
			return _listeners.lastIndexOf(callback) >= 0;
		}
		
		public function addListener(callback:Function):ISignalListener
		{
			if (callback == null)
			{
				throw new NullArgumentError();
			}
			
			/*
				To prevent infinite chaining of callbacks adding callbacks 
				I can add them to a limbo list to add later on call()
			 */
			
			_listeners[_listeners.length] = listenerPool.getInstance().compose(callback);
		}
		
		public function removeListener(callback:Function):void
		{
			const index:int = _listeners.lastIndexOf(callback);
			index < 0 || _removeListenerAt(i);
		}
		
		public function dispatch():void
		{
			if (hasListeners)
			{
				/*
					later add listeners in limbo here
				*/
				_callListeners();
				_cleanListeners();
			}
		}
		
		public function removeListeners():void
		{
			listenerPool.add.apply(_listeners);
			_listeners.length = 0;
		}
		
		private function _cleanListeners():void
		{
			for (var i:int = _listeners.length - 1; i >= 0; i--)
			{
				_listeners[i] || _listeners.splice(i, 1);
			}
		}
		
		private function _callListeners():void
		{
			for (var i:int = 0; i < listeners.length; i++)
			{
				var listener:SignalListener = _listeners[i];
				listener.call();
				listener.remove && _removeListenerAt(i);
			}
		}
		
		private function _removeListenerAt(index:int):void
		{
			listenerPool.add(_listener[index]);
			_listeners[index] = null;
		}
		
	}
	
}
