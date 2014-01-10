package orichalcum.signals
{

	import flash.utils.getQualifiedClassName;
	import orichalcum.datastructure.Pool;
	import orichalcum.utility.Strings;
	
	/**
	 * Signal implementation with Once-fire signals
	 * With this implementation comes the following overhead:
	 * signal listener object wrappers
	 * signal listener pool transactions
	 */
	public class Signal implements ISignal
	{
		
		static private const NULL_LISTENER:Function = function(...args):void { };
		private var _totalListeners:int;
		private var _listeners:Vector.<Function>;
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
		
		public function get listeners():Vector.<Function>
		{
			return Vector.<Function>(_listeners);
		}
		
		public function set listeners(value:Vector.<Function>):void
		{
			_listeners = Vector.<Function>(value);
		}
		
		public function get listenerArgumentClasses():Vector.<Class>
		{
			return Vector.<Class>(_listenerArgumentClasses);
		}
		
		public function set listenerArgumentClasses(value:Vector.<Class>):void
		{
			_listenerArgumentClasses = Vector.<Class>(value);
		}
		
		public function get totalListenerArgumentClasses():int
		{
			return _listenerArgumentClasses ? _listenerArgumentClasses.length : 0;
		}
		
		public function get totalListeners():int
		{
			return _totalListeners;
		}
		
		public function get isEmpty():Boolean
		{
			return totalListeners == 0;
		}
		
		public function get hasListeners():Boolean
		{
			return totalListeners > 0;
		}
	
		public function has(listener:Function):Boolean
		{
			if (isEmpty || listener == null) return false;
			
			for each(var callback:Function in _listeners)
			{
				if (callback == listener)
				{
					
					return true;
				}
			}
			
			return false;
		}
		
		public function add(listener:Function):void
		{
			_add(listener);
		}
		
		public function remove(listener:Function):void
		{
			if (isEmpty) return;
			for (var i:int = 0; i < _listeners.length; i++)
			{
				if (_listeners[i] == listener)
				{
					_removeListenerAt(i);
				}
			}
		}
		
		public function removeAll():void
		{
			if (isEmpty) return;
			_listeners.length = 0;
		}
		
		public function dispatch(...listenerArguments):void
		{
			if (isEmpty) return;
			
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
				
			/*
				Call listeners
			*/
			for each(var listener:Object in _listeners)
			{
				
				/*
				 * Cases
				 * 0. Listener has same number of arguments as dispatched
				 * 1. listener has more arguments than dispatched
				 * 	Allow runtime to determin argument count missmatch
				 * 2. Listener has less arguments than dispatched
				 * 	Trim back dispatched arguments to the appropriate set
				 */
				if (listenerArguments.length > listener.length)
				{
					listenerArguments.length = listener.length;
				}
				
				listener.apply(null, listenerArguments);
			}
			
			/*
				Clean listeners
			*/
			for (i = _listeners.length - 1; i >= 0; i--)
			{
				_listeners[i] === NULL_LISTENER && _listeners.splice(i, 1);
			}
		}
		
		private function _add(listener:Function):void
		{
			if (listener == null)
			{
				throw new ArgumentError(Strings.interpolate(
					'Argument "{}" passed to method "{}#{}" must not be null.',
					'listener',
					getQualifiedClassName(this),
					'addListener'
				));
			}
			
			if (listener.length > totalListenerArgumentClasses)
			{
				throw new ArgumentError(Strings.interpolate(
					'Argument "{}" passed to method "{}#{}" must accept {} arguments.',
					'listener',
					getQualifiedClassName(this),
					'addListener',
					totalListenerArgumentClasses
				));
			}
			
			/*
				To prevent infinite chaining of callbacks adding callbacks 
				I can add them to a limbo list to add later on call()
			 */
			(_listeners ||= new Vector.<Function>)[listeners.length] = listener;
			_totalListeners++;
		}
		
		private function _removeListenerAt(index:int):void
		{
			_listeners[index] = NULL_LISTENER;
			_totalListeners--;
		}
		
	}
	
}

