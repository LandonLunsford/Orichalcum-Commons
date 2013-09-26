package orichalcum.datastructure
{
	import flash.utils.Dictionary;
	import orichalcum.utility.FunctionUtil;

	public class Graph
	{
		/**
		 * Flyweights for iteration in dfs and bfs traversal
		 */
		static private var _arrays:Pool = new Pool(
			function():Array { return []; },
			function(array:Array):void { array.length = 0; }
		);
		
		private var _vertices:Dictionary;
		//private var _vertexById:Array;
		
		private var _totalVertices:int;
		private var _totalEdges:int;
		
		public function Graph() 
		{
			_vertices = new Dictionary;
			//_vertexById = [];
		}
		
		public function get isEmpty():Boolean
		{
			for (var id:String in _vertices)
			{
				return false;
			}
			return true;
		}
		
		public function get vertices():Dictionary 
		{
			return _vertices;
		}
		
		public function empty():Graph
		{
			for (var vertex:* in _vertices)
			{
				vertex.dispose();
				delete _vertices[vertex];
			}
			return this;
		}
		
		public function clone():Graph
		{
			const clone:Graph = new Graph;
			for (var vertex:* in _vertices)
			{
				clone._vertices[vertex] = vertex.clone();
			}
			//clone._totalVertices = _totalVertices;
			//clone._totalEdges = _totalEdges;
			return clone;
		}
		
		public function concat(graph:Graph = null):Graph
		{
			const concatination:Graph = clone();
			//TODO
			return concatination;
		}
		
		public function removeEdgesOf(vertex:GraphVertex):Graph
		{
			// need to modify _totalEdges
			vertex && vertex.removeEdges();
			return this;
		}
		
		public function hasVertex(vertex:GraphVertex):Boolean
		{
			return _vertices[vertex] != null;
		}
		
		public function addVertex(vertex:GraphVertex):Graph
		{
			if (!_vertices[vertex])
			{
				//_vertexById[i++._id
				_vertices[vertex] = vertex;
			}
			
			return this;
		}
		
		public function removeVertex(vertex:GraphVertex):Graph
		{
			if (vertex in _vertices)
			{
				delete _vertices[vertex];
				for each(var otherVertex:* in _vertices)
				{
					// need to modify totalEdges/totalVertices
					otherVertex.removeEdge(vertex);
				}
			}
			return this;
		}
		
		public function hasEdge(a:GraphVertex, b:GraphVertex, inBothDirections:Boolean = false):Boolean
		{
			return inBothDirections
				? a && a.hasEdge(b) && b.hasEdge(a)
				: a && a.hasEdge(b);
		}
		
		public function addEdge(a:GraphVertex, b:GraphVertex, weight:Number = 1, inBothDirections:Boolean = false):Graph
		{
			if (!a || !b || a == b) return this;
			a.addEdge(b, weight);
			inBothDirections && b.addEdge(a, weight);
			return addVertex(a).addVertex(b);
		}
		
		public function removeEdge(a:GraphVertex, b:GraphVertex, inBothDirections:Boolean = false, removeOrphans:Boolean = true):Graph
		{
			return inBothDirections
				? _removeUndirectedEdge(a, b, removeOrphans)
				: _removeDirectedEdge(a, b, removeOrphans);
		}
		
		public function depthFirstTraverse(from:GraphVertex, closure:Function):Graph
		{
			isEmpty || _depthFirstRecurse(closure == null ? FunctionUtil.NULL : closure, from);
			_unmarkVisited();
			return this;
		}
		
		public function breadthFirstTraverse(from:GraphVertex, closure:Function):Graph
		{
			const a:Array = _arrays.getInstance();
			isEmpty || _breadthFirstTraverse(closure == null ? FunctionUtil.NULL : closure, from, a);
			_arrays.returnInstance(a);
			_unmarkVisited();
			return this;
		}
		
		public function isAdjacent(a:GraphVertex, b:GraphVertex):Boolean
		{
			return a && a.hasEdge(b);
		}
		
		/**
			http://www.geeksforgeeks.org/greedy-algorithms-set-7-dijkstras-algorithm-for-adjacency-list-representation/
			http://www.signalsondisplay.com/blog/wp-content/uploads/as3/algorithms/dijkstra/srcview/
			
			http://mochiland.com/articles/flash-game-developer-tutorial-pathfinding-with-dijkstras-algorithm
			Set all verticies as not known, and with infinity distance
			Set s.distance to 0
			while true
			  set v to be the vertex with the smallest distance, that isn't known
			  if v is null
				break
			  set v.known to true
			  for each w adjacent to v
				if w.known is false
				  //costVW is the distance from vertex v to vertex w
					if v.distance + costVW < w.distance
					  w.distance = v.distance + costVW
					  w.path = v 
					  
			http://www.actionscript.org/forums/showthread.php3?t=77709
		*/
		public function shortestPath(a:GraphVertex, b:GraphVertex, ignoreWeight:Boolean = false, flyweight:Array = null):Array
		{
			if (!hasVertex(a))
				throw new ArgumentError('Cannot find shortest path to vertex ' + a + ' because it is not on the graph.');
				
			if (!hasVertex(b))
				throw new ArgumentError('Cannot find shortest path to vertex ' + b + ' because it is not on the graph.');
			
			const path:Array = flyweight || [];
			
			if (ignoreWeight)
				return _shortestUnweightedPath(a, b, path);
			
			
			const distances:Dictionary = new Dictionary;
			const visited:Dictionary = new Dictionary;
			
			
			distances[a] = 0;
			while (true)
			{
				var j:Number = Number.MAX_VALUE;
				var v:GraphVertex = null;
				for (var k:* in _vertices)
				{
					trace(k.data, distances[k], j);
					if (!visited[k] && distances[k] < j)
					{
						j = distances[k];
						v = k;
					}
				}
				
				if (!v) break;
				
				visited[v] = true;
				
				for each(var edge:GraphEdge in v.edges)
				{
					var w:GraphVertex = edge.b;
					if (!visited[w])
					{
						trace('ew', edge.weight);
						trace('dist?', distances[v] + edge.weight, distances[w]);
						if (distances[v] + edge.weight < distances[w])
						{
							trace('adding', v);
							distances[w] = distances[v] + edge.weight;
							path[path.length] = v;
						}
					}
				}
				
			}
			
			return path;
		}
		
		private function _shortestUnweightedPath(a:GraphVertex, b:GraphVertex, path:Array):Array
		{
			// USE BFS
			return path;
		}
		
		//private function _depthFirstVertexCount(vertex:*, visited:Array):int
		//{
			//hmmm... no worky even when trying to conpensate for nulls inbetween
			//var count:int = _vertices[vertex] ? 1 : 0;
			//visited[vertex] = true;
			//for each(var adjacentVertex:int in _getVertex(vertex).edges)
			//{
				//if (!visited[adjacentVertex])
				//{
					//count += _depthFirstVertexCount(adjacentVertex, visited);
				//}
			//}
			//return count;
		//}
		
		private function _depthFirstRecurse(closure:Function, vertex:GraphVertex):void
		{
			closure(vertex, true);
			vertex._visited = true;
			for each(var edge:GraphEdge in vertex.edges)
			{
				edge.b._visited || _depthFirstRecurse(closure, edge.b);
			}
			closure(vertex, false);
		}
		
		private function _breadthFirstTraverse(closure:Function, from:GraphVertex, queue:Array):void
		{
			from._visited = true;
			queue.unshift(from);
			
			while (queue.length > 0)
			{
				var vertex:GraphVertex = queue.pop();
				/*
					O(n) -- this can be avoided with GraphVertex class having id/index property
				 */
				closure(vertex);
				
				for each(var edge:GraphEdge in vertex.edges)
				{
					if (!edge.b._visited)
					{
						edge.b._visited = true;
						queue.unshift(edge.b);
					}
				}
			}
		}
		
		private function _removeUndirectedEdge(a:GraphVertex, b:GraphVertex, removeOrphans:Boolean = true):Graph 
		{
			if (a == null || b == null) return this;
			a.removeEdge(b);
			b.removeEdge(a);
			if (removeOrphans)
			{
				if (!a.isConnected)
				{
					_totalVertices--;
					delete _vertices[a];
				}
				if (!b.isConnected)
				{
					_totalVertices--;
					delete _vertices[b];
				}
			}
			return this;
		}
		
		private function _removeDirectedEdge(a:GraphVertex, b:GraphVertex, removeOrphans:Boolean = true):Graph 
		{
			if (a == null || b == null) return this;
			a.removeEdge(b);
			if (removeOrphans)
			{
				if (!a.isConnected)
				{
					_totalVertices--;
					delete _vertices[a];
				}
				
				if (!b.isConnected)
				{
					_totalVertices--;
					delete _vertices[b];
				}
			}
			return this;
		}
		
		private function _unmarkVisited():void 
		{
			for each(var vertex:GraphVertex in _vertices)
			{
				vertex._visited = false;
			}
		}
		
		public function toString():String
		{
			return _vertices.toString();
			//return JSON.stringify(this);
		}
		
		//public function toJSON(k:*):*
		//{
			// need index all vertices with id
			//const a:Array = [];
			//var i:int = 0;
			//for (var vertex:* in _vertices)
			//{
				//a[i++] = vertex;
			//}
			//return a;
		//}
		
		//static public function fromJSON(json:String):Graph
		//{
			//const graph:Graph = new Graph;
			//const a:Array = JSON.parse(json);
			//for each(var vertexVO:Object in a)
			//{
				//var vertex:GraphVertex = new GraphVertex(vertexVO.data, vertexVO.weight);
				//for each(var edge:Object in vertexVO.edges)
				//{
					//vertex.addEdge(
				//}
				//graph.addVertex(vertex);
			//}
			//return graph;
		//}
		
	}

}

