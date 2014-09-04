package orichalcum.datastructure
{
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import orichalcum.datastructure.FallbackMap;

	public class HierarchyMapTest 
	{
		
		[Test]
		public function testNoParent():void
		{
			
		}
		
		[Test]
		public function testParent():void
		{
			
		}
		
		[Test]
		public function testGrandparent():void
		{
			const grandparent:HierarchyMap = new HierarchyMap;
			const parent:HierarchyMap = new HierarchyMap;
			const child:HierarchyMap = new HierarchyMap;
			parent.parent = grandparent;
			child.parent = parent;
			
			grandparent.propertyOfGrandparent = 99;
			parent.propertyOfParent = 88;
			child.propertyOfChild = 77;
			
			assertThat(child.propertyOfGrandparent, equalTo(grandparent.propertyOfGrandparent));
			assertThat(child.propertyOfParent, equalTo(parent.propertyOfParent));
			assertThat(child.propertyOfChild, equalTo(child.propertyOfChild));
			
		}
		
	}

}