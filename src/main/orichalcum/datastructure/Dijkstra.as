package orichalcum.datastructure
{

	import orichalcum.datastructure.Graph;
	import orichalcum.datastructure.GraphVertex;
	
	public class Dijkstra
	{
		private var _graph:Graph;
		private var _from:GraphVertex;
		private var _to:GraphVertex;
		private var _queue:Array;
		
		public function Dijkstra(graph:Graph, from:GraphVertex, to:GraphVertex)
		{
			_graph = graph;
			_from = from;
			_to = to;
			_queue = [];
		}
		
		public function getEnd():GraphVertex
		{
			_queue.length = 0;
			for each(var m:GraphVertex in _graph.vertices)
			{
				m._weight = Number.MAX_VALUE;
				m._visited = false;
				m._parent = null;
				_queue[_queue.length] = m;
			}
			
			_from._weight = 0;
			
			while (_queue.length)
			{
				var nextClosest:GraphVertex = _queue[0];
				var minimumPriority:Number = nextClosest._weight;
				var index:int = 0;
				
				for (var i:int = 1; i < _queue.length; i++)
				{
					var j:GraphVertex = _queue[i];
					if (j._weight < minimumPriority)
					{
						nextClosest = j;
						minimumPriority = nextClosest._weight;
						index = i;
					}
				}
				_queue.splice(index, 1);
				
				if (!nextClosest)
				{
					break;
				}
					
				if (nextClosest == _to)
				{
					return _to;
				}
				
				for each(var n:GraphEdge in nextClosest.edges)
				{
					var neighbor:GraphVertex = n.b;
					
					if (neighbor._visited)
					{
						continue;
					}
					
					var totalWeight:Number = nextClosest._weight + n.weight;
					
					if (neighbor._weight > totalWeight)
					{
						neighbor._weight = totalWeight;
						neighbor._parent = nextClosest;
					}
				}
				nextClosest._visited = true;
				
			}
			return null;
		}
	
	}

}