package orichalcum.datastructure 
{

	public class GraphVertex 
	{
		
		private var _data:*;
		private var _edges:Array;
		private var _weight:Number;
		
		/**
		 * Imposes concurrecy limitation but runtime efficiency
		 * Create ConcurrentDirectedGraph
		 */
		internal var _visited:Boolean;
		internal var _id:int;
		internal var _path:GraphVertex;
		
		public function GraphVertex(weight:Number = 1, data:* = null) 
		{
			_data = data;
			_weight = weight;
			_edges = [];
		}
		
		public function dispose():void
		{
			_data = null;
			_edges.length = 0;
			_edges = null;
		}
		
		public function get data():* 
		{
			return _data;
		}
		
		public function set data(value:*):void 
		{
			_data = value;
		}
		
		public function get weight():Number 
		{
			return _weight;
		}
		
		public function set weight(value:Number):void 
		{
			_weight = value;
		}
		
		public function get edges():Array
		{
			return _edges;
		}
		
		public function get isConnected():Boolean
		{
			return _edges.length > 0;
		}
		
		public function removeEdges():void
		{
			_edges.length = 0;
		}
		
		public function clone():GraphVertex
		{
			const clone:GraphVertex = new GraphVertex(data, weight);
			for each(var edge:GraphEdge in _edges)
			{
				clone._edges.push(edge.clone());
			}
			return clone;
		}
		
		public function hasEdge(vertex:GraphVertex):Boolean
		{
			for each(var edge:GraphEdge in _edges)
			{
				if (edge.b == vertex)
					return true;
			}
			return false;
		}
		
		public function addEdge(edge:GraphEdge):void
		{
			_edges[_edges.length] = edge;
		}
		
		public function removeEdge(vertex:GraphVertex):void
		{
			for (var i:int = _edges.length - 1; i >= 0; i--)
			{
				var edge:GraphEdge = _edges[i];
				if (edge.b == vertex)
				{
					_edges.splice(i, 1);
					break;
				}
			}
		}
		
		public function toJSON(k:*):*
		{
			return {data:data, weight:weight, edges:edges};
		}
		
	}

}
