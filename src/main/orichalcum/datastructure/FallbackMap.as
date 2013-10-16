package orichalcum.datastructure
{

	import flash.utils.Dictionary;

	public class FallbackMap
	{
	
		private var _fallback:*;
		private var _data:Dictionary;
		
	
		public function FallbackMap(fallback:* = undefined)
		{
			_fallback = fallback;
			_data = new Dictionary;
		}
		
		public function get data():Dictionary
		{
			return _data;
		}
		
		public function set data(value:Dictionary):void
		{
			_data = value;
		}
	
		public function get fallback():*
		{
			return _fallback;
		}
		
		public function set fallback(value:*):void
		{
			_fallback = value;
		}
		
		public function map(key:*, value:*):void
		{
			_data[key] = value;
		}
		
		public function unmap(key:*):void
		{
			delete _data[key];
		}
		
		public function getValue(key:*):*
		{
			return key in _data ? _data[key] : fallback;
		}
	
	}
}
