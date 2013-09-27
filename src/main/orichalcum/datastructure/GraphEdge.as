package orichalcum.datastructure 
{
	
	public class GraphEdge 
	{
		
		private var _a:GraphVertex;
		private var _b:GraphVertex;
		private var _weight:Number;
		
		public function GraphEdge(a:GraphVertex, b:GraphVertex, weight:Number = 1) 
		{
			this.a = a;
			this.b = b;
			this.weight = weight;
		}
		
		public function get a():GraphVertex 
		{
			return _a;
		}
		
		public function set a(value:GraphVertex):void 
		{
			_a = value;
		}
		
		public function get b():GraphVertex 
		{
			return _b;
		}
		
		public function set b(value:GraphVertex):void 
		{
			_b = value;
		}
		
		public function get weight():Number 
		{
			return _weight;
		}
		
		public function set weight(value:Number):void 
		{
			_weight = value;
		}
		
		public function clone():GraphEdge
		{
			return new GraphEdge(a, b, weight);
		}
		
		public function equals(edge:GraphEdge):Boolean
		{
			return edge && edge.a == a && edge.b == b;
		}
		
		public function complements(edge:GraphEdge):Boolean
		{
			return edge && edge.a == b && edge.b == a;
		}
		
		public function toJSON(k:*):*
		{
			return {a:a, b:b, weight:weight};
		}
		
	}

}
