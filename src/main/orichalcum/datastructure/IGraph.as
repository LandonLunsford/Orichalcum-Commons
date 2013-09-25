package orichalcum.datastructure 
{
	import flash.display.IGraphicsData;
	
	
	public interface IGraph 
	{
		function getVertex(id:*):*;
		function get isConnected():Boolean;
		function get isCyclic():Boolean;
		function depthFirstTraverse(closure:Function, fromVertex:int):IGraph;
		function breadthFirstTraverse(closure:Function, fromVertex:int):IGraph;
		
		// graph type dependent
		//function setVertex(id:*, value:*):IGraph;
		//function setEdge(vertexA:*, vertexB:*):IGraph;
		
	}

}
