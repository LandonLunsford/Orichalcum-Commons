package orichalcum.datastructure 
{
	
	public class Pool
	{
		private var _values:Array;
		private var _creator:Function;
		private var _destroyer:Function;
		
		public function Pool(creator:Function, destroyer:Function = null)
		{
			_values = [];
			_creator = creator;
			_destroyer = destroyer;
		}
		
		public function getInstance():*
		{
			return _values.length ? _values.pop() : _creator();
		}
		
		public function returnInstance(value:*):void
		{
			_destroyer != null && _destroyer(value);
			_values.push(value);
		}
		
	}

}
