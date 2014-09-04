package orichalcum.datastructure
{
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import orichalcum.datastructure.FallbackMap;

	public class FallbackMapTest 
	{
		
		[Test]
		public function testNoFallback():void
		{
			assertThat(undefined, equalTo(new FallbackMap().propertyThatDoesntExist));
		}
		
		[Test]
		public function testFallback():void
		{
			const fallback:* = 99;
			assertThat(fallback, equalTo(new FallbackMap(fallback).propertyThatDoesntExist));
		}
		
	}

}