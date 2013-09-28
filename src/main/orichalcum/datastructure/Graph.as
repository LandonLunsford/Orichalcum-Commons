package orichalcum.datastructure
{
	import flash.utils.Dictionary;
	import orichalcum.utility.FunctionUtil;

	/* helped by : http://www.signalsondisplay.com/blog/wp-content/uploads/as3/algorithms/dijkstra/srcview/ */
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
		private var _edges:Dictionary;
		private var _dijkstra:Dijkstra;
		
		public function Graph() 
		{
			_vertices = new Dictionary;
			_edges = new Dictionary;
		}
		
		public function get vertices():Dictionary 
		{
			return _vertices;
		}
		
		public function get edges():Dictionary 
		{
			return _edges;
		}
		
		public function get isEmpty():Boolean
		{
			for (var id:String in _vertices)
			{
				return false;
			}
			return true;
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
			
			if (!a.hasEdge(b))
			{
				const e1:GraphEdge = new GraphEdge(a, b, weight);
				a.addEdge(e1);
				_edges[e1] = e1;
			}
			if (inBothDirections && !b.hasEdge(a))
			{
				const e2:GraphEdge = new GraphEdge(b, a, weight);
				b.addEdge(e2);
				_edges[e2] = e2;
			}
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
			if (!isEmpty)
			{
				_depthFirstRecurse(closure == null ? FunctionUtil.NULL : closure, from);
				_unmarkVisited();
			}
			return this;
		}
		
		public function breadthFirstTraverse(from:GraphVertex, closure:Function):Graph
		{
			if (!isEmpty)
			{
				const a:Array = _arrays.getInstance();
				_breadthFirstTraverse(closure == null ? FunctionUtil.NULL : closure, from, a);
				_arrays.returnInstance(a);
				_unmarkVisited();
			}
			return this;
		}
		
		public function isAdjacent(a:GraphVertex, b:GraphVertex):Boolean
		{
			return a && a.hasEdge(b);
		}
		
		public function shortestPath(a:GraphVertex, b:GraphVertex, flyweight:Array = null):Array
		{
			if (!a)
				throw new ArgumentError('Cannot find shortest path to vertex "A" because it is null.');
				
			if (!b)
				throw new ArgumentError('Cannot find shortest path to vertex "A" because it is null.');
			
			if (!hasVertex(a))
				throw new ArgumentError('Cannot find shortest path to vertex "A" because it is not on the graph.');
				
			if (!hasVertex(b))
				throw new ArgumentError('Cannot find shortest path to vertex "B" because it is not on the graph.');
			
			const path:Array = flyweight || [];
			path.length = 0;
			
			if (a != b)
			{
				_dijkstra ||= new Dijkstra(this, a, b);
				var v:GraphVertex = _dijkstra.getEnd();
				while (v)
				{
					path.unshift(v);
					v = v._parent;
				}
			}
			
			return path;
		}
		
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
			delete _edges[a.removeEdge(b)];
			delete _edges[b.removeEdge(a)];
			if (removeOrphans)
			{
				if (!a.isConnected)
				{
					//_totalVertices--;
					delete _vertices[a];
				}
				if (!b.isConnected)
				{
					//_totalVertices--;
					delete _vertices[b];
				}
			}
			return this;
		}
		
		private function _removeDirectedEdge(a:GraphVertex, b:GraphVertex, removeOrphans:Boolean = true):Graph 
		{
			if (a == null || b == null) return this;
			
			delete _edges[a.removeEdge(b)];
				
			if (removeOrphans)
			{
				if (!a.isConnected)
				{
					//_totalVertices--;
					delete _vertices[a];
				}
				
				if (!b.isConnected)
				{
					//_totalVertices--;
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

