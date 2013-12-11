package orichalcum.utility 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Rectangles 
	{
		
		static public function globalToLocal(stage:Stage, view:DisplayObject, rectangle:Rectangle):Rectangle
		{
			if (stage == view || !stage || !view || !rectangle) return rectangle;
			
			//var topLeft:Point = view.globalToLocal(rectangle.topLeft);
			rectangle.topLeft = view.globalToLocal(rectangle.topLeft);
			rectangle.bottomRight = view.globalToLocal(rectangle.bottomRight);
		}
		
	}

}