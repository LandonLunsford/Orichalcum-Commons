package orichalcum.ui.filter
{
	public class ParallaxView extends Sprite
	{
		private var _focusX:Number = 0;
		private var _focusY:Number = 0;
		private var _focusOnMouse:Boolean;
		private var _panDuration:Number = 0;
	
		public function ParallaxView()
		{
		
		}
		
		public function get focusX():Number
		{
			return _focusX;
		}
		
		public function set focusX(value:Number):void
		{
			if (_focusX === value) return;
			_focusX = value;
			render();
		}
		
		public function get focusY():Number
		{
			return _focusY;
		}
		
		public function set focusY(value:Number):void
		{
			if (_focusY === value) return;
			_focusY = value;
			render();
		}
		
		public function get focusOnMouse():Boolean
		{
			return _focusOnMouse;
		}
		
		public function set focusOnMouse(value:Boolean):void
		{
			_focusOnMouse
		}
		
		public function panTo(x:Number, y:Number):void
		{
		
		}
		
		public function render():void
		{
			for (var i:int = numChildren - 1; i >= 0; i--)
			{
				
			}
		
		}
		
		private function _applyParallaxEffect(target:DisplayObject, focusX:Number, focusY:Number, width:Number, height:Number):void
		{
			
		}
		
		
	}
}
