package orichalcum.datastructure 
{

	public class LinkedListTest extends AbstractListTestBase
	{

		override protected function get newEmptyCollection():IList 
		{
			return new LinkedList;
		}
		
		override protected function get newFilledCollection():IList 
		{
			return new LinkedList(0,1,2);
		}
		
	}

}