package  
{
	import orichalcum.datastructure.ArrayListTest;
	import orichalcum.datastructure.GraphTest;
	import orichalcum.datastructure.LinkedListTest;
	import orichalcum.signals.SignalTest;
	import orichalcum.utility.FunctionUtilTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite 
	{
		public var arrayListTest:ArrayListTest;
		public var linkedListTest:LinkedListTest;
		public var functionUtilTest:FunctionUtilTest;
		public var graphTest:GraphTest;
		public var signalTest:SignalTest;
	}

}
