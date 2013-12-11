package orichalcum.datastructure
{
	import flash.utils.Dictionary;

	public class Sets
	{
	
		static public function create():Dictionary
		{
			return new Dictionary;
		}
		
		static public function fromValues(...values):Dictionary
		{
			return fromArray(values);
		}
		
		static public function fromObject(object:Object):Dictionary
		{
			const dictionary:Dictionary = create();
			for (var key:String in object)
			{
				dictionary[key] = key;
			}
			return dictionary;
		}
		
		static public function fromArray(array:Array):Dictionary
		{
			const dictionary:Dictionary = create();
			for each(var value:* in array)
			{
				dictionary[value] = value;
			}
			return dictionary;
		}
		
		static public function toArray(dictionary:Dictionary):Array
		{
			const array:Array = [];
			for (var key:* in dictionary)
			{
				array.push(key);
			}
			return array;
		}
		
		static public function spectrum(a:Dictionary, b:Dictionary):SetSpectrum
		{
			return new SetSpectrum(a, b);
		}
		
		static public function intersect(a:Dictionary, b:Dictionary):Boolean
		{
			for (var key:* in a)
			{
				if (key in b)
				{
					return true;
				}
			}
			return false;
		}
		
		static public function intersection(a:Dictionary, b:Dictionary):Dictionary
		{
			const intersection:Dictionary = create();
			for (var key:* in a)
			{
				if (key in b)
				{
					intersection[key] = key;
				}
			}
			return intersection;
		}
		
		static public function union(a:Dictionary, b:Dictionary):Dictionary
		{
			const union:Dictionary = create();
			for (var key:String in a)
			{
				union[key] = key;
			}
			for (key in b)
			{
				union[key] = key;
			}
			return union;
		}
		
		static public function difference(a:Dictionary, b:Dictionary):Dictionary
		{
			const difference:Dictionary = create();
			for (var key:String in a)
			{
				if (!(key in b))
				{
					difference[key] = key;
				}
			}
			for (key in b)
			{
				if (!(key in a))
				{
					difference[key] = key;
				}
			}
			return difference;
		}
		
		static public function complement(a:Dictionary, b:Dictionary):Dictionary
		{
			const complement:Dictionary = create();
			for (var key:String in b)
			{
				if (!(key in a))
				{
					complement[key] = key;
				}
			}
			return complement;
		}
		
	}
	
}
