package orichalcum.datastructure 
{

	internal class LinkedListNode
	{
		public var value:*;
		public var next:LinkedListNode;
		
		public function LinkedListNode(value:* = undefined)
		{
			this.value = value;
		}
	}

}