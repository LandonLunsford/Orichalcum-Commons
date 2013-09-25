package orichalcum.datastructure 
{
	import org.hamcrest.assertThat;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	
	public class GraphTest 
	{
		
		private var _graph:Graph;
		private var _vertexA:String = 'a';
		private var _vertexB:String = 'b';
		
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
			_graph.addVertex(_vertexA);
			assertThat(_graph.isEmpty, isFalse());
			_graph.removeVertex(_vertexA);
			assertThat(_graph.isEmpty, isTrue());
		}
		
		[Test]
		public function addVertex():void
		{
			_graph.addVertex(_vertexA);
			assertThat(_graph.isEmpty, isFalse());
			assertThat(_graph.hasVertex(_vertexA));
		}
		
		[Test]
		public function removeVertex():void
		{
			_graph.addVertex(_vertexA);
			assertThat(_graph.isEmpty, isFalse());
			assertThat(_graph.hasVertex(_vertexA), isTrue());
			_graph.removeVertex(_vertexA);
			assertThat(_graph.isEmpty, isTrue());
			assertThat(_graph.hasVertex(_vertexA), isFalse());
		}
		
		[Test]
		public function addEdge():void
		{
			_graph.addEdge(_vertexA, _vertexB);
			assertThat(_graph.hasVertex(_vertexA), isTrue());
			assertThat(_graph.hasVertex(_vertexB), isTrue());
			assertThat(_graph.hasEdge(_vertexA, _vertexB), isTrue());
			assertThat(_graph.hasEdge(_vertexB, _vertexA), isFalse());
		}
		
		[Test]
		public function removeEdge():void
		{
			_graph.addEdge(_vertexA, _vertexB);
			_graph.removeEdge(_vertexA, _vertexB);
			assertThat(_graph.hasVertex(_vertexA), isFalse());
			assertThat(_graph.hasVertex(_vertexB), isFalse());
			assertThat(_graph.hasEdge(_vertexA, _vertexB), isFalse());
			assertThat(_graph.isEmpty, isTrue());
		}
		
		
	}

}
