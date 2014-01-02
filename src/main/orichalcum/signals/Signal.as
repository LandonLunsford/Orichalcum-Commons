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
		private var _listenerArgumentClasses:Vector.<Class>;
		
		
		public function Signal(...listenerArgumentClasses)
		{
			if (listenerArgumentClasses.length > 1)
			{
				this.listenerArgumentClasses = Vector.<Class>(
					listenerArgumentClasses.length == 1
					&& (listenerArgumentClasses[0] is Array
					|| listenerArgumentClasses[0] is Vector.<Class>)
						? listenerArgumentClasses[0]
						: listenerArgumentClasses
				);
			}
		}
		
		public function dispose():void
		{
			_listeners = null;
			_listenerArgumentClasses = null;
		}
		
		protected function get listeners():Vector.<SignalListener>
		{
			/*
				Uses lazy creation because some signals go unlistened to
			*/
			return _listeners ||= new Vector.<SignalListener>;
		}
		
		protected function set listeners(value:Vector.<SignalListener>):void
		{
			_listeners = value;
		}
		
		protected function get listenerArgumentClasses():Vector.<SignalListener>
		{
			return _listenerArgumentClasses;
		}
		
		protected function set listenerArgumentClasses(value:Vector.<Class>):void
		{
			/*
			_listenerArgumentClasses = new Vector.<Class>;
			for each(var listenerArgumentClass:* in listenerArgumentClasses)
			{
				if (listenerArgumentClass is Class || listenerArgumentClass == null)
				{
					_listenerArgumentClasses[_listenerArgumentClasses.length] = listenerArgumentClasse;
				}
				else
				{
					throw new ArgumentError('Value found in argument "listenerArgumentClasses" must be null or of type "Class".');
				}
			}
			*/
		
			_listenerArgumentClasses = value;
		}
		
		public function hasListeners():Boolean
		{
			return _listeners && _listeners.length > 0;
		}
	
		public function hasListener(callback:Function):Boolean
		{
			return _listeners && _listeners.lastIndexOf(callback) >= 0;
		}
		
		public function addListener(callback:Function):ISignalListener
		{
			if (callback == null)
			{
				throw new ArgumentError('Argument "callback" passed to method "Signal.addListener()" must not be null.');
			}
			
			/*
				To prevent infinite chaining of callbacks adding callbacks 
				I can add them to a limbo list to add later on call()
			 */
			const listener:SignalListener = listenerPool.getInstance().compose(callback);
			listeners.push(listener);
			return listener;
		}
		
		public function removeListener(callback:Function):void
		{
			if (!_listeners) return;
			const index:int = _listeners.lastIndexOf(callback);
			index < 0 || _removeListenerAt(index);
		}
		
		public function dispatch(...listenerArguments):void
		{
			if (!_listeners) return;
			if (_listenerArgumentClasses)
			{
				/*
					Execute argument length check ?
					Execute argument type check
				*/
			}
			
			/*
				later add listeners in limbo here
			*/
			_callListeners();
			_cleanListeners();
		}
		
		public function removeListeners():void
		{
			if (!_listeners) return;
			listenerPool.returnInstance.apply(_listeners);
			_listeners.length = 0;
			_listeners = null;
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
			listenerPool.returnInstance(_listeners[index]);
			_listeners[index] = null;
		}
		
	}
	
}
