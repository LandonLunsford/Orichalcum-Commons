package orichalcum.collection 
{

	internal class DirectedGraphNode 
	{
		/**
		 * Imposes concurrecy limitation but runtime efficiency
		 * Create ConcurrentDirectedGraph
		 */
		//internal var _visited:Boolean;
		
		private var _id:*;
		private var _adjacencies:Array;
		
		public function DirectedGraphNode(id:*) 
		{
			_id = id;
			_adjacencies = [];
		}
		
		public function dispose():void
		{
			_id = null;
			_adjacencies.length = 0;
			_adjacencies = null;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get adjacencies():Array
		{
			return _adjacencies;
		}
		
		public function get isConnected():Boolean
		{
			return _adjacencies.length > 0;
		}
		
		public function disconnect():void
		{
			_adjacencies.length = 0;
		}
		
		public function clone():DirectedGraphNode
		{
			const clone:DirectedGraphNode = new DirectedGraphNode(id);
			for each(var adjacency:* in _adjacencies)
				clone._adjacencies.push(adjacency);
			return clone;
		}
		
		public function hasAdjacency(id:*):Boolean
		{
			return _adjacencies.indexOf(id) >= 0;
		}
		
		public function addAdjacency(id:*):void
		{
			if (!hasAdjacency(id))
				_adjacencies[_adjacencies.length] = id;
		}
		
		public function removeAdjacency(id:*):void
		{
			const index:int = _adjacencies.indexOf(id);
			if (index >= 0)
				_adjacencies.splice(index, 1);
		}
		
		public function toJSON(k:*):*
		{
			return _adjacencies;
		}
		
	}

}
