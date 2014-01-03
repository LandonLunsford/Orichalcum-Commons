package orichalcum.signals
{

	import flash.utils.getQualifiedClassName;
	import orichalcum.datastructure.Pool;
	import orichalcum.utility.Strings;

	public class Signal implements ISignal
	{
	
		static public const listenerPool:Pool = new Pool(
			function():SignalListener { return new SignalListener; },
			function(instance:SignalListener):SignalListener { return instance.dispose(); }
		);
		
		private var _listeners:Vector.<SignalListener>;
		private var _listenerArgumentClasses:Vector.<Class>;
		
		public function Signal(...listenerArgumentClasses)
		{
			if (listenerArgumentClasses.length > 0)
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
		
		protected function get listenerArgumentClasses():Vector.<Class>
		{
			return _listenerArgumentClasses;
		}
		
		protected function set listenerArgumentClasses(value:Vector.<Class>):void
		{
			_listenerArgumentClasses = value;
		}
		
		protected function get totalListenerArgumentClasses():int
		{
			return _listenerArgumentClasses ? _listenerArgumentClasses.length : 0;
		}
		
		public function get totalListeners():int
		{
			/*
				O( totalListeners )
				because of null storage in _listeners for "concurrent" dispatch / remove
			*/
			if (_listeners)
			{
				
				var totalListeners:int = 0;
				for each(var listener:SignalListener in _listeners)
				{
					if (listener != null)
					{
						totalListeners++;
					}
				}
				return totalListeners;
			}
			return 0;
		}
		
		public function get hasListeners():Boolean
		{
			/*
				O( totalListeners )
			*/
			return totalListeners > 0;
		}
	
		public function hasListener(callback:Function):Boolean
		{
			/*
				O( totalListeners )
			*/
			if (_listeners)
			{
				for each(var listener:SignalListener in _listeners)
				{
					if (listener && listener.equals(callback))
					{
						return true;
					}
				}
			}
			return false;
		}
		
		public function addListener(callback:Function):ISignalListener
		{
			/*
				O( constant )
			*/
			if (callback == null)
			{
				throw new ArgumentError(Strings.interpolate(
					'Argument "{}" passed to method "{}#{}" must not be null.',
					'callback',
					getQualifiedClassName(this),
					'addListener'
				));
			}
			
			if (callback.length > totalListenerArgumentClasses)
			{
				throw new ArgumentError(Strings.interpolate(
					'Argument "{}" passed to method "{}#{}" must accept {} arguments.',
					'callback',
					getQualifiedClassName(this),
					'addListener',
					totalListenerArgumentClasses
				));
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
			/*
				O( totalListeners )
			*/
			if (_listeners)
			{
				for (var i:int = 0; i < _listeners.length; i++)
				{
					if (_listeners[i].equals(callback))
					{
						_removeListenerAt(i);
					}
				}
			}
		}
		
		public function removeListeners():void
		{
			/*
				O( constant )
			*/
			if (_listeners == null) return;
			listenerPool.returnInstance.apply(_listeners);
			_listeners.length = 0;
			_listeners = null;
		}
		
		public function dispatch(...listenerArguments):void
		{
			if (_listeners == null) return;
			
			const totalDispatchedArguments:int = listenerArguments.length;
			const totalExpecedArguments:int = this.totalListenerArgumentClasses;
			
			/**
			 * Dispatched argument count / types must match expected count and types
			 * It is the responsibility of the dispatcher to uphold the dispatch contract.
			 */
			if (totalDispatchedArguments != totalExpecedArguments)
			{
				throw new ArgumentError(
					Strings.interpolate(
						'Argument count mismatch found on "{}#dispatch()". Found <{}> expected <{}>.',
						getQualifiedClassName(this),
						totalDispatchedArguments,
						totalExpecedArguments
					)
				);
			}
			
			/**
			 * Dispatched argument types must be null or match the expected argument types defined at construction time
			 * This is a best attempt at a "Generics" contract.
			 */
			for (var i:int = 0; i < totalExpecedArguments; i++)
			{
				var argument:* = listenerArguments[i];
				var expectedArgumentType:Class = _listenerArgumentClasses[i];
				
				if (argument == null || expectedArgumentType == null || argument is expectedArgumentType)
					continue;
				
				throw new ArgumentError(
					Strings.interpolate(
						'Argument type mismatch found on "{}#dispatch()". Found value of type "{}" at index <{}>. Expected value of type "{}".',
						getQualifiedClassName(this),
						getQualifiedClassName(argument),
						i,
						getQualifiedClassName( _listenerArgumentClasses[i])
					)
				);
			}
			
			/*
				later add listeners in limbo here
			*/
			_callListeners(listenerArguments);
			_cleanListeners();
		}
		
		private function _callListeners(listenerArguments:Array):void
		{
			for (var i:int = 0; i < listeners.length; i++)
			{
				var listener:SignalListener = _listeners[i];
				
				/**
				 * Remove this check by assigning "NULL_SIGNAL_LISTENER" to removed listeners
				 */
				if (listener == null) continue;
				
				/*
				 * Cases
				 * 0. Listener has same number of arguments as dispatched
				 * 1. listener has more arguments than dispatched
				 * 	Allow runtime to determin argument count missmatch
				 * 2. Listener has less arguments than dispatched
				 * 	Trim back dispatched arguments to the appropriate set
				 */
				if (listener.callback.length < listenerArguments.length)
				{
					listenerArguments.length = listener.callback.length;
				}
				
				listener.callback.apply(null, listenerArguments);
				listener.remove && _removeListenerAt(i);
			}
		}
		
		private function _cleanListeners():void
		{
			for (var i:int = _listeners.length - 1; i >= 0; i--)
			{
				_listeners[i] || _listeners.splice(i, 1);
			}
		}
		
		private function _removeListenerAt(index:int):void
		{
			listenerPool.returnInstance(_listeners[index]);
			_listeners[index] = null;
		}
		
	}
	
}
