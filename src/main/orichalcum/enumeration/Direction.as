package orichalcum.enumeration
{
	import flash.ui.Keyboard;

	public class Direction 
	{
		static public const NONE:Direction = new Direction(0, 'none', -1);
		static public const UP:Direction = new Direction(1, 'up', Keyboard.UP);
		static public const DOWN:Direction = new Direction(2, 'down', Keyboard.DOWN);
		static public const LEFT:Direction = new Direction(3, 'left', Keyboard.LEFT);
		static public const RIGHT:Direction = new Direction(4, 'right', Keyboard.RIGHT);
		
		static private const _directionsByCode:Array = [NONE, UP, DOWN, LEFT, RIGHT];
		static private const _directionsByName:Object = {none:NONE, up:UP, down:DOWN, left:LEFT, right:RIGHT};
		static private const _directionsByKey:Array = [];
		
		{
			NONE._opposite = NONE;
			UP._opposite = DOWN;
			DOWN._opposite = UP;
			LEFT._opposite = RIGHT;
			RIGHT._opposite = LEFT;
			
			_directionsByKey[Keyboard.UP] = UP;
			_directionsByKey[Keyboard.DOWN] = DOWN;
			_directionsByKey[Keyboard.LEFT] = LEFT;
			_directionsByKey[Keyboard.RIGHT] = RIGHT;
		}
		
		private var _code:int;
		private var _name:String;
		private var _keyCode:int;
		private var _opposite:Direction;
		
		public function Direction(code:int, name:String, keyCode:int) 
		{
			_code = code;
			_name = name;
			_keyCode = keyCode;
		}
		
		public function get code():int 
		{
			return _code;
		}
		
		public function get name():String 
		{
			return _name;
		}
		
		public function get keyCode():int
		{
			return _keyCode;
		}
		
		public function get opposite():Direction
		{
			return _opposite;
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
		
		static public function fromKey(code:int):Direction
		{
			return _directionsByKey[code];
		}
		
		static public function fromVector(x:Number, y:Number):Direction
		{
			if (x == 0 && y == 0) return NONE;
			
			return Math.abs(y) > Math.abs(x)
				? y > 0 ? DOWN : UP
				: x > 0 ? RIGHT : LEFT;
		}
		
	}

}
