package orichalcum.datastructure 
{
	import flash.utils.Dictionary;

	public class Maps 
	{
		
		static public function fromObject(value:Object):Dictionary
		{
			const map:Dictionary = new Dictionary;
			for (var key:* in value)
			{
				map[key] = value[key];
			}
			return map;
		}
		
	}

}