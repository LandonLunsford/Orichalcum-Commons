package orichalcum.collection 
{
	import flash.utils.Dictionary;


	public class DirectGraph 
	{
		static private var _arrays:Pool = new Pool(function():Array { return []; } );
		private var _verticesById:Dictionary = new Dictionary(true);
		
		public function DirectGraph() 
		{
			
		}
		
		public function clone():*
		{
			const clone:DirectGraph = new DirectGraph;
			
			for each(var id:* in _verticesById)
			{
				clone._verticesById[id] = _verticesById[id].clone();
			}
			
			return clone;
		}
		
		public function addVertex(id:*):*
		{
			const vertex:DirectGraphNode = new DirectGraphNode(id);	
			_verticesById[id] = vertex;
			return this;
		}
		
		public function addEdge(vertexA:*, vertexB:*):*
		{
			return this;
		}
		
	}

}

internal class DirectGraphNode
{
	private var _id:*;
	private var _adjancencies:Array;
	
	public function DirectGraphNode(id:*)
	{
		_id = id;
		_adjancencies = [];
	}
	
	public function clone():*
	{
		const clone:DirectGraphNode = new DirectGraphNode(id);
		return clone;
	}
	
	public function get id():* 
	{
		return _id;
	}
	
	public function isEmpty():Boolean
	{
		return _adjancencies.length == 0;
	}
	
	public function get adjancencies():Array 
	{
		return _adjancencies;
	}
	
	public function addAdjacency(id:*):*
	{
		_adjancencies.push(id);
		return this;
	}
	
	public function removeAdjacency(id:*):*
	{
		const index:int = _adjancencies.indexOf(id);
		if (index != -1)
		{
			_adjancencies.splice(index, 1);
		}
		return this;
	}
}