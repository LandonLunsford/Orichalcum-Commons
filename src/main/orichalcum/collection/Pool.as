package orichalcum.collection 
{
	import orichalcum.utility.FunctionUtil;

	public class Pool extends Array
	{
		
		private var _factory:Function;
		
		public function Pool(factory:Function) 
		{
			_factory = factory == null || factory.length != 0 ? FunctionUtil.NULL : factory;
		}
		
		public function provide():*
		{
			return length ? pop() : _factory();
		}
		
		public function add(value:*):*
		{
			return push(value);
		}
		
	}

}