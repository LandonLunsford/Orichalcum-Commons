package  
{

	public class Direction 
	{
		static public const NONE:Direction = new Direction(0, 'none');
		static public const UP:Direction = new Direction(1, 'up');
		static public const DOWN:Direction = new Direction(2, 'down');
		static public const LEFT:Direction = new Direction(3, 'left');
		static public const RIGHT:Direction = new Direction(4, 'right');
		
		static private const _directionsByCode:Array = [NONE, UP, DOWN, LEFT, RIGHT];
		static private const _directionsByName:Object = {none:NONE, up:UP, down:DOWN, left:LEFT, right:RIGHT};
		
		private var _code:int;
		private var _name:String;
		
		public function Direction(code:int, name:String) 
		{
			_code = code;
			_name = name;
		}
		
		public function get code():int 
		{
			return _code;
		}
		
		public function get name():String 
		{
			return _name;
		}
		
		public function toString():String
		{
			return _name;
		}
		
		public function valueOf():*
		{
			return _name;
		}
		
		static public function fromCode(code:int):Direction
		{
			return _directionsByCode[code];
		}
		
		static public function fromName(name:String):Direction
		{
			return _directionsByName[name];
		}
		
		static public function fromVector(x:Number, y:Number):Direction
		{
			if (x - y == 0)
				return NONE;
			
			return Math.abs(y) > Math.abs(x)
				? y > 0 ? DOWN : UP
				: x > 0 ? RIGHT : LEFT;
		}
		
	}

}
