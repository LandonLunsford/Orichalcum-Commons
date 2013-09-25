package orichalcum.datastructure
{
	import flash.utils.Dictionary;

	public class Graph
	{
		private var _vertices:Dictionary;
		
		private var _totalVertices:int;
		private var _totalEdges:int;
		
		public function Graph() 
		{
			_vertices = new Dictionary;
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
			for (var id:* in _vertices)
			{
				const vertex:GraphNode = _vertices[id];
				vertex.dispose();
				delete _vertices[id];
			}
			return this;
		}
		
		public function clone():Graph
		{
			const clone:Graph = new Graph;
			for (var id:* in _vertices)
			{
				clone._vertices[id] = _vertices[id].clone();
			}
			clone._totalVertices = _totalVertices;
			clone._totalEdges = _totalEdges;
			return clone;
		}
		
		public function concat(graph:Graph = null):Graph
		{
			const concatination:Graph = clone();
			// TODO
			return concatination;
		}
		
		public function removeEdgesOf(id:*):Graph
		{
			const vertex:GraphNode = _getVertex(id);
			// need to modify _totalEdges
			vertex && vertex.removeAdjacencies();
			return this;
		}
		
		public function hasVertex(id:*):Boolean
		{
			return _vertices[id] != null;
		}
		
		public function addVertex(id:*):Graph
		{
			_vertices[id] = new GraphNode(id);
			return this;
		}
		
		public function removeVertex(id:*):Graph
		{
			if (id in _vertices)
			{
				delete _vertices[id];
				for each(var vertex:GraphNode in _vertices)
				{
					// need to modify totalEdges/totalVertices
					vertex.removeAdjacency(id);
				}
			}
			return this;
		}
		
		private function _getVertex(id:*):GraphNode
		{
			return _vertices[id];
		}
		
		private function _getOrCreateVertex(id:*):GraphNode
		{
			const vertex:GraphNode = _vertices[id];
			if (!_vertices[id])
			{
				_totalVertices++;
				return _vertices[id] = new GraphNode(id);
			}
			return vertex;
		}
		
		public function hasEdge(vertexA:*, vertexB:*, undirected:Boolean = false):Boolean
		{
			return undirected
				? _hasDirectedEdge(vertexA, vertexB) && _hasDirectedEdge(vertexB, vertexA)
				: _hasDirectedEdge(vertexA, vertexB);
		}
		
		public function addEdge(vertexA:*, vertexB:*, undirected:Boolean = false):Graph
		{
			return undirected
				? _addUndirectedEdge(vertexA, vertexB)
				: _addDirectedEdge(vertexA, vertexB);
		}
		
		public function removeEdge(vertexA:*, vertexB:*, undirected:Boolean = false, removeOrphans:Boolean = true):Graph
		{
			return undirected
				? _removeUndirectedEdge(vertexA, vertexB)
				: _removeDirectedEdge(vertexA, vertexB);
		}
		
		private function _hasDirectedEdge(vertexA:*, vertexB:*):Boolean
		{
			return hasVertex(vertexA) && _getVertex(vertexA).hasAdjacency(vertexB);
		}
		
		private function _addDirectedEdge(vertexA:*, vertexB:*):Graph
		{
			_getOrCreateVertex(vertexA).addAdjacency(vertexB);
			_getOrCreateVertex(vertexB);
			return this;
		}
		
		private function _addUndirectedEdge(vertexA:*, vertexB:*):Graph
		{
			_getOrCreateVertex(vertexA).addAdjacency(vertexB);
			_getOrCreateVertex(vertexB).addAdjacency(vertexA);
			return this;
		}
		
		public function depthFirstTraverse(fromVertex:*, closure:Function):Graph
		{
			isEmpty || _depthFirstRecurse(closure /* == null ? FunctionUtil.null : closure */, fromVertex, []); // use array pool
			return this;
		}
		
		public function breadthFirstTraverse(fromVertex:*, closure:Function):Graph
		{
			isEmpty || _breadthFirstTraverse(closure /* == null ? FunctionUtil.null : closure */, fromVertex, [], []); // use array pool
			return this;
		}
		
		public function isAdjacent(x:*, y:*):Boolean
		{
			const vertexA:GraphNode = _getVertex(x);
			return vertexA && vertexA.hasAdjacency(y);
		}
		
		/**
			http://www.geeksforgeeks.org/greedy-algorithms-set-7-dijkstras-algorithm-for-adjacency-list-representation/
		 */
		public function shortestPath(x:*, y:*):Array
		{
			if (!hasVertex(x))
				throw new ArgumentError('Cannot find shortest path to vertex ' + x + ' because it is not on the graph.');
				
			if (!hasVertex(x))
				throw new ArgumentError('Cannot find shortest path to vertex ' + y + ' because it is not on the graph.');
			
			return [];
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
		
		private function _removeUndirectedEdge(vertexA:*, vertexB:*, removeOrphans:Boolean = true):Graph 
		{
			const a:GraphNode = _getVertex(vertexA);
			const b:GraphNode = _getVertex(vertexB);
			if (a == null || b == null) return this;
			a.removeAdjacency(vertexB);
			b.removeAdjacency(vertexA);
			if (removeOrphans)
			{
				if (!a.isConnected)
				{
					_totalVertices--;
					delete _vertices[vertexA];
				}
				if (!b.isConnected)
				{
					_totalVertices--;
					delete _vertices[vertexB];
				}
			}
			return this;
		}
		
		private function _removeDirectedEdge(vertexA:*, vertexB:*, removeOrphans:Boolean = true):Graph 
		{
			const a:GraphNode = _getVertex(vertexA);
			if (a == null) return this;
			a.removeAdjacency(vertexB);
			if (removeOrphans)
			{
				if (!a.isConnected) delete _vertices[vertexA];
				const b:GraphNode = _getVertex(vertexB);
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
			{
				o[key] = _vertices[key];
			}
			return o;
		}
		
		static public function fromJSON(json:String):Graph
		{
			const graph:Graph = new Graph;
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



/*
 * 

 
 // The main function that calulates distances of shortest paths from src to all
// vertices. It is a O(ELogV) function
void dijkstra(struct Graph* graph, int src)
{
    int V = graph->V;// Get the number of vertices in graph
    int dist[V];      // dist values used to pick minimum weight edge in cut
 
    // minHeap represents set E
    struct MinHeap* minHeap = createMinHeap(V);
 
    // Initialize min heap with all vertices. dist value of all vertices 
    for (int v = 0; v < V; ++v)
    {
        dist[v] = INT_MAX;
        minHeap->array[v] = newMinHeapNode(v, dist[v]);
        minHeap->pos[v] = v;
    }
 
    // Make dist value of src vertex as 0 so that it is extracted first
    minHeap->array[src] = newMinHeapNode(src, dist[src]);
    minHeap->pos[src]   = src;
    dist[src] = 0;
    decreaseKey(minHeap, src, dist[src]);
 
    // Initially size of min heap is equal to V
    minHeap->size = V;
 
    // In the followin loop, min heap contains all nodes
    // whose shortest distance is not yet finalized.
    while (!isEmpty(minHeap))
    {
        // Extract the vertex with minimum distance value
        struct MinHeapNode* minHeapNode = extractMin(minHeap);
        int u = minHeapNode->v; // Store the extracted vertex number
 
        // Traverse through all adjacent vertices of u (the extracted
        // vertex) and update their distance values
        struct AdjListNode* pCrawl = graph->array[u].head;
        while (pCrawl != NULL)
        {
            int v = pCrawl->dest;
 
            // If shortest distance to v is not finalized yet, and distance to v
            // through u is less than its previously calculated distance
            if (isInMinHeap(minHeap, v) && dist[u] != INT_MAX && 
                                          pCrawl->weight + dist[u] < dist[v])
            {
                dist[v] = dist[u] + pCrawl->weight;
 
                // update distance value in min heap also
                decreaseKey(minHeap, v, dist[v]);
            }
            pCrawl = pCrawl->next;
        }
    }
 
    // print the calculated shortest distances
    printArr(dist, V);
}
 
 
 
 
 
 
 
 
 
 
 
 
int ShortestPath(Node AdjacencyList[], int n, int v, int w)
{
	// AdjacencyList -- adjacency list of nodes in graph
	// n -- number of nodes in the graph (6)
	// v -- number of the starting vertex (1..6)
	// w -- number of the destination vertex (1..6)
	int		MinDistance;
	int		ShortestDist[MAXVERTICES];
	int		W[MAXVERTICES];
	int		nextWIdx = 0;
	int		i;
	int		wNode;		// Index of node being considered
	int		tempIdx;	// Temporary use index
	StatusType	status[MAXVERTICES];

	// -------------------- INITIALIZATION SECTION -------------------- 
	for(i = 0; i < MAXVERTICES; i++)
	{
		W[i] = -1;                   // Init W to empty
		ShortestDist[i] = MAXINT;    // Init shortest dists to infinity
		status[i] = unseen;          // Init all nodes to unseen
	}
	// ------------------------ SETUP SECTION -------------------------
	W[nextWIdx] = v;         // Add first node to W 
	nextWIdx++;              // Increment index into W
	ShortestDist[v-1] = 0;   // Set shortest dist from v to v
	status[v-1] = intree;    // Set status of v in W

	// Set shortest distance and status from v to all nodes adjacent to it
	for(i = 0; i < MAXLINKS; i++)
	{
		ShortestDist[AdjacencyList[v-1].links[i].link - 1] =
			AdjacencyList[v-1].links[i].weight;
		status[AdjacencyList[v-1].links[i].link - 1] = fringe;
	}
	// ---------------------- MAIN lOOP SECTION -----------------------
	// Repeatedly enlarge W until it includes all vertices in the graph
	while(nextWIdx < MAXVERTICES)
	{
		// Find the vertex n in V - W at the minimum distance from v
		MinDistance = MAXINT;
		for(i = 0; i < MAXVERTICES; i++)
		{
			if(status[i] == fringe)
			{
				if(ShortestDist[i] < MinDistance)
				{
					MinDistance = ShortestDist[i];
					wNode = i + 1;	// Convert index to node number
				}
			}
		}

		// Add w to W
		W[nextWIdx] = wNode;
		status[wNode - 1] = intree;
		nextWIdx++;

		// Update the shortest distances to vertices in V - W
		for(i = 0; i < MAXLINKS; i++)
		{
			tempIdx = AdjacencyList[wNode -1].links[i].link - 1;
			ShortestDist[tempIdx] = Minimum(ShortestDist[tempIdx],
				ShortestDist[wNode - 1] + AdjacencyList[wNode - 1].links[i].weight);
			status[tempIdx] = fringe;
		}
	} // End while
	return(ShortestDist[w - 1]);
}
*/
