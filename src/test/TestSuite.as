package  
{
	import orichalcum.collection.ArrayListTest;
	import orichalcum.collection.LinkedListTest;
	import orichalcum.datastructure.GraphTest;
	import orichalcum.utility.FunctionUtilTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite 
	{
		public var arrayListTest:ArrayListTest;
		public var linkedListTest:LinkedListTest;
		
		public var functionUtilTest:FunctionUtilTest;
		
		public var graphTest:GraphTest;
	}

}
