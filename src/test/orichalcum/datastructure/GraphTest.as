package orichalcum.datastructure 
{
	import org.flexunit.asserts.fail;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	
	public class GraphTest 
	{
		
		private var _graph:Graph;
		private var _a:GraphVertex = new GraphVertex;
		private var _b:GraphVertex = new GraphVertex;
		
		[Before]
		public function setup():void
		{
			_graph = new Graph;
		}
		
		[After]
		public function teardown():void
		{
			_graph = null;
		}
		
		[Test]
		public function isEmpty():void
		{
			assertThat(_graph.isEmpty, isTrue());
			_graph.addVertex(_a);
			assertThat(_graph.isEmpty, isFalse());
			_graph.removeVertex(_a);
			assertThat(_graph.isEmpty, isTrue());
		}
		
		[Test]
		public function addVertex():void
		{
			_graph.addVertex(_a);
			assertThat(_graph.isEmpty, isFalse());
			assertThat(_graph.hasVertex(_a));
		}
		
		[Test]
		public function removeVertex():void
		{
			_graph.addVertex(_a);
			assertThat(_graph.isEmpty, isFalse());
			assertThat(_graph.hasVertex(_a), isTrue());
			_graph.removeVertex(_a);
			assertThat(_graph.isEmpty, isTrue());
			assertThat(_graph.hasVertex(_a), isFalse());
		}
		
		[Test]
		public function addEdge():void
		{
			_graph.addEdge(_a, _b);
			assertThat(_graph.hasVertex(_a), isTrue());
			assertThat(_graph.hasVertex(_b), isTrue());
			assertThat(_graph.hasEdge(_a, _b), isTrue());
			assertThat(_graph.hasEdge(_b, _a), isFalse());
		}
		
		[Test]
		public function removeEdge():void
		{
			_graph.addEdge(_a, _b);
			_graph.removeEdge(_a, _b);
			assertThat(_graph.hasVertex(_a), isFalse());
			assertThat(_graph.hasVertex(_b), isFalse());
			assertThat(_graph.hasEdge(_a, _b), isFalse());
			assertThat(_graph.isEmpty, isTrue());
		}
		
		[Test]
		public function depthFirst():void
		{
			const a:GraphVertex = new GraphVertex('a');
			const b:GraphVertex = new GraphVertex('b');
			const c:GraphVertex = new GraphVertex('c');
			const d:GraphVertex = new GraphVertex('d');
			const forwardPath:Array = [a, b, d, c];
			const reversePath:Array = [d, b, c, a];
			
			_graph.addEdge(a, b);
			_graph.addEdge(a, c);
			_graph.addEdge(b, d);
			
			var i:int, j:int;
			
			_graph.depthFirstTraverse(a, function(vertex:GraphVertex, forward:Boolean):void
			{
				if (forward)
				{
					if (forwardPath[i++] != vertex) fail();
				}
				else
				{
					if (reversePath[j++] != vertex) fail();
				}
			});
		}
		
		[Test]
		public function breadthFirst():void
		{
			const a:GraphVertex = new GraphVertex('a');
			const b:GraphVertex = new GraphVertex('b');
			const c:GraphVertex = new GraphVertex('c');
			const d:GraphVertex = new GraphVertex('d');
			const forwardPath:Array = [a, b, c, d];
			
			_graph.addEdge(a, b);
			_graph.addEdge(a, c);
			_graph.addEdge(b, d);
			
			var i:int;
			
			_graph.breadthFirstTraverse(a, function(vertex:GraphVertex):void
			{
				if (forwardPath[i++] != vertex) fail();
			});
		}
		
		[Test]
		public function shortestPath():void
		{
			const a:GraphVertex = new GraphVertex('a');
			const b:GraphVertex = new GraphVertex('b');
			const c:GraphVertex = new GraphVertex('c');
			const d:GraphVertex = new GraphVertex('d');
			const e:GraphVertex = new GraphVertex('e');
			const f:GraphVertex = new GraphVertex('f');
			const g:GraphVertex = new GraphVertex('g');
			const expectedPath:Array = [a, b, d, f];
			var i:int;
			
			_graph.addEdge(a, b);
			_graph.addEdge(a, c);
			_graph.addEdge(b, d);
			_graph.addEdge(c, e);
			_graph.addEdge(e, d);
			_graph.addEdge(d, f);
			
			assertThat(_graph.shortestPath(a, f), equalTo(expectedPath));
			
		}
		
		
	}

}
