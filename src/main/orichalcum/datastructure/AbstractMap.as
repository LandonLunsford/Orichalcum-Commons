package orichalcum.datastructure
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;
	
	use namespace flash_proxy;
	
	public dynamic class AbstractMap extends Proxy implements IEventDispatcher
	{
		protected var _dispatcher:EventDispatcher;
		protected var _keys:Array;
		protected var _values:Array;
		protected var _entries:Dictionary;
		
		public function AbstractMap()
		{
			_dispatcher = new EventDispatcher(this);
			_keys = [];
			_values = [];
			_entries = new Dictionary;
		}
		
		override flash_proxy function callProperty(name:*, ... rest):*
		{
			return _entries[name].apply(_entries, rest);
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			return remove(name) !== null;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return _entries[name];
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return hasKey(name);
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			put(name, value);
		}
		
		override flash_proxy function nextName(index:int):String
		{
			return _keys[index - 1] as String;
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			return index < _keys.length ? index + 1 : 0;
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			return _entries[_keys.getItemAt(index - 1)];
		}
		
		public function get keys():Array
		{
			return _keys.concat();
		}
		
		public function get values():Array
		{
			return _values.concat();
		}
		
		public function hasKey(key:*):Boolean
		{
			return key in _entries;
		}
		
		public function hasValue(value:*):Boolean
		{
			return _values.indexOf(value) != -1;
		}
		
		public function remove(key:*):Object
		{
			var removed:*;
			if (hasKey(key))
			{
				removed = _entries[key];
				const index:int = _keys.indexOf(key);
				_keys.splice(index, 1);
				_values.splice(index, 1);
				delete _entries[key];
				//var ce:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REMOVE, -1, -1, entry);
				//dispatcher.dispatchEvent(ce);
			}
			return removed;
		}
		
		public function put(key:*, value:*):*
		{
			var replaced:*;
			var index:int;
			if (hasKey(key))
			{
				replaced = _entries[key];
				index = _keys.indexOf(key);
				_values[index] = value;
				_entries[key] = value;
				//var pce:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(this, key, replaced, value);
				//ce = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REPLACE, -1, -1, entry);
				//dispatcher.dispatchEvent(ce);
			}
			else
			{
				index = _keys.length;
				_keys[index] = key;
				_values[index] = value;
				_entries[key] = value;
				//var ce:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD, -1, -1, entry);
				//dispatcher.dispatchEvent(ce);
			}
			return replaced;
		}
		
		public function clear():void
		{
			_keys.length = 0;
			_values.length = 0;
			_entries = new Dictionary();
			//var ce:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET, -1, -1, null);
			//dispatcher.dispatchEvent(ce);
		}
		
		public function get length():int
		{
			return _keys.length;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
		
		// todo
		//public function toString():String
		//{
			//
		//}
	}
}