package orichalcum.collection
{
	import flash.utils.Dictionary;

	public class DirectedGraph
	{
		private var _vertices:Dictionary;
		private var _totalVertices:int;
		
		public function DirectedGraph() 
		{
			_vertices = new Dictionary;
		}
		
		public function get isEmpty():Boolean
		{
			return _totalVertices == 0;
		}
		
		public function empty():DirectedGraph
		{
			for (var id:* in _vertices)
			{
				const vertex:DirectedGraphNode = _vertices[id];
				vertex.dispose();
				delete _vertices[id];
			}
			return this;
		}
		
		public function clone():DirectedGraph
		{
			const clone:DirectedGraph = new DirectedGraph;
			for (var id:* in _vertices)
			{
				clone._vertices[id] = _vertices[id].clone();
			}
			return clone;
		}
		
		public function concat(graph:DirectGraph = null):DirectedGraph
		{
			const concatination:DirectedGraph = clone();
			// TODO
			return concatination;
		}
		
		public function disconnect(id:*):DirectedGraph
		{
			const vertex:GraphNode = _getVertex(id);
			vertex && vertex.disconnect();
			return this;
		}
		
		public function addVertex(id:*):DirectedGraph
		{
			_vertices[id] = new GraphNode(id);
			return this;
		}
		
		public function removeVertex(id:*, forcefully:Boolean = true):DirectedGraph
		{
			if (id in _vertices)
			{
				delete _vertices[id];
				for each(var vertex:GraphNode in _vertices)
				{
					vertex.removeAdjacency(id);
				}
			}
			return this;
		}
		
		private function _getVertex(id:*):DirectedGraphNode
		{
			return _vertices[id];
		}
		
		private function _getOrCreateVertex(id:*):DirectedGraphNode
		{
			const vertex:GraphNode = _vertices[id];
			if (!_vertices[id])
			{
				_totalVertices++;
				return _vertices[id] = new GraphNode(id);
			}
			return vertex;
		}
		
		public function addEdge(vertexA:*, vertexB:*, undirected:Boolean = false):DirectedGraph
		{
			return undirected
				? _addUndirectedEdge(vertexA, vertexB)
				: _addDirectedEdge(vertexA, vertexB);
		}
		
		public function removeEdge(vertexA:*, vertexB:*, undirected:Boolean = false, removeOrphans:Boolean = true):DirectedGraph
		{
			return undirected
				? _removeUndirectedEdge(vertexA, vertexB)
				: _removeDirectedEdge(vertexA, vertexB);
		}
		
		private function _addDirectedEdge(vertexA:*, vertexB:*):DirectedGraph
		{
			_getOrCreateVertex(vertexA).addAdjacency(vertexB);
			_getOrCreateVertex(vertexB);
			return this;
		}
		
		private function _addUndirectedEdge(vertexA:*, vertexB:*):DirectedGraph
		{
			_getOrCreateVertex(vertexA).addAdjacency(vertexB);
			_getOrCreateVertex(vertexB).addAdjacency(vertexA);
			return this;
		}
		
		public function depthFirstTraverse(fromVertex:*, closure:Function):DirectedGraph
		{
			isEmpty || _depthFirstRecurse(closure /* == null ? FunctionUtil.null : closure */, fromVertex, []); // use array pool
			return this;
		}
		
		public function breadthFirstTraverse(fromVertex:*, closure:Function):DirectedGraph
		{
			isEmpty || _breadthFirstTraverse(closure /* == null ? FunctionUtil.null : closure */, fromVertex, [], []); // use array pool
			return this;
		}
		
		public function isAdjacent(x:*, y:*):Boolean
		{
			const vertexA:GraphNode = _getVertex(x);
			return vertexA && vertexA.hasAdjacency(y);
		}
		
		private function _depthFirstVertexCount(vertex:*, visited:Array):int
		{
			//hmmm... no worky even when trying to conpensate for nulls inbetween
			var count:int = _vertices[vertex] ? 1 : 0;
			visited[vertex] = true;
			for each(var adjacentVertex:int in _getVertex(vertex).adjacencies)
			{
				if (!visited[adjacentVertex])
				{
					count += _depthFirstVertexCount(adjacentVertex, visited);
				}
			}
			return count;
		}
		
		private function _depthFirstRecurse(closure:Function, vertex:*, visited:Array):void
		{
			/* FunctionUtil.call(closure, vertex, false) */
			closure(vertex, false);
			visited[vertex] = true;
			for each(var adjacentVertex:* in _getVertex(vertex).adjacencies)
			{
				visited[adjacentVertex] || _depthFirstRecurse(closure, adjacentVertex, visited);
			}
			/* FunctionUtil.call(closure, vertex, true) */
			closure(vertex, true);
		}
		
		private function _breadthFirstTraverse(closure:Function, fromVertex:*, queue:Array, queued:Array):void
		{
			queued[fromVertex] = true;
			queue.unshift(_getVertex(fromVertex));
			
			while (queue.length > 0)
			{
				var vertex:GraphNode = queue.pop();
				/*
					O(n) -- this can be avoided with GraphNode class having id/index property
				 */
				closure(vertex.id);
				
				for each(var adjacentVertex:* in vertex.adjacencies)
				{
					if (!queued[adjacentVertex])
					{
						queued[adjacentVertex] = true;
						queue.unshift(_getVertex(adjacentVertex));
					}
				}
			}
		}
		
		private function _removeUndirectedEdge(vertexA:*, vertexB:*, removeOrphans:Boolean = true):DirectedGraph 
		{
			const a:GraphNode = _getVertex(vertexA);
			const b:GraphNode = _getVertex(vertexB);
			if (a == null || b == null) return this;
			a.removeAdjacency(vertexB);
			b.removeAdjacency(vertexA);
			if (removeOrphans)
			{
				if (!a.isConnected) delete _vertices[vertexA];
				if (!b.isConnected) delete _vertices[vertexB];
			}
			return this;
		}
		
		private function _removeDirectedEdge(vertexA:*, vertexB:*, removeOrphans:Boolean = true):DirectedGraph 
		{
			const a:GraphNode = _getVertex(vertexA);
			if (a == null) return this;
			a.removeAdjacency(vertexB);
			if (removeOrphans)
			{
				if (!a.isConnected) delete _vertices[vertexA];
				const b:DirectedGraphNode = _getVertex(vertexB);
				if (b && !b.isConnected) delete _vertices[vertexB];
			}
			return this;
		}
		
		public function toString():String
		{
			return JSON.stringify(this);
		}
		
		public function toJSON(k:*):*
		{
			const o:Object = {};
			for (var key:* in _vertices)
				o[key] = _vertices[key];
			return o;
		}
		
		static public function fromJSON(json:String):DirectedGraph
		{
			const graph:DirectedGraph = new DirectedGraph;
			const object:Object = JSON.parse(json);
			for (var vertex:String in object)
			{
				for each(var adjacency:String in object[vertex])
				{
					graph.addEdge(vertex, adjacency);
				}
			}
			return graph;
		}
		
	}

}
