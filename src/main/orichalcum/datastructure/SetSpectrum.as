package orichalcum.datastructure
{
	import flash.utils.Dictionary;

	public class SetSpectrum
	{
	
		private var _a:Dictionary;
		private var _b:Dictionary;
		private var _left:Dictionary;
		private var _middle:Dictionary;
		private var _right:Dictionary;
		
		
		public function SetSpectrum(a:Dictionary, b:Dictionary)
		{
			if (!a) throw new ArgumentError();
			if (!b) throw new ArgumentError();
			
			_a = a;
			_b = b;
			_left = Sets.create();
			_middle = Sets.create();
			_right = Sets.create();
			
			for (var key:String in a)
			{
				if (key in b)
				{
					_middle[key] = key;
				}
				else
				{
					_left[key] = key;
				}
			}
			
			for (key in b)
			{
				if (key in a)
				{
					_middle[key] = key;
				}
				else
				{
					_right[key] = key;
				}
			}
		}
		
		public function get a():Dictionary
		{
			return _a;
		}
		
		public function get b():Dictionary
		{
			return _b;
		}
		
		public function get left():Dictionary
		{
			return _left;
		}
		
		public function get middle():Dictionary
		{
			return _middle;
		}
		
		public function get right():Dictionary
		{
			return _right;
		}
		
	}
}
