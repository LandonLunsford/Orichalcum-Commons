package orichalcum.datastructure 
{

	public class ArrayListTest extends AbstractListTestBase
	{

		override protected function get newEmptyCollection():IList 
		{
			return new ArrayList;
		}
		
		override protected function get newFilledCollection():IList 
		{
			return new ArrayList(0,1,2);
		}
		
	}

}