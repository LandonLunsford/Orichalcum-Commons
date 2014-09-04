package orichalcum.datastructure 
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;

	public dynamic class HierarchyMap extends AbstractMap
	{
		private var _parent:*;
		
		public function HierarchyMap(parent:Object = undefined) 
		{
			this.parent = parent;
		}
		
		public function get parent():Object 
		{
			return _parent;
		}
		
		public function set parent(value:Object):void 
		{
			_parent = value;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return name in _entries ? _entries[name] : parent ? parent[name] : undefined;
		}
		
	}

}