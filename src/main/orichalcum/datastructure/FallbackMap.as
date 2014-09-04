package orichalcum.datastructure 
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;

	public dynamic class FallbackMap extends AbstractMap
	{
		private var _fallback:*;
		
		public function FallbackMap(fallback:* = undefined) 
		{
			this.fallback = fallback;
		}
		
		public function get fallback():* 
		{
			return _fallback;
		}
		
		public function set fallback(value:*):void 
		{
			_fallback = value;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return name in _entries ? _entries[name] : fallback;
		}
		
	}

}