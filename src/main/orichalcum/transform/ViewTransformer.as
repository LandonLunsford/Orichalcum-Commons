package orichalcum.transform
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;

	/**
	 * Derived from Daniel Gasienica
	 * daniel@gasienica.ch
	 * http://gasi.ch/
	 * http://www.gasi.ch/blog/zooming-in-flash-flex/
	 * http://www.gasi.ch/blog/examples/2008/02/05/zooming/source/
	 */
	public class ViewTransformer
	{
		static private var _instance:ViewTransformer;
		private var _matrixTransformer:MatrixTransformer;
		
		static public function getInstance():ViewTransformer
		{
			return _instance ||= new ViewTransformer(MatrixTransformer.getInstance());
		}
		
		public function ViewTransformer(matrixTransformer:MatrixTransformer)
		{
			_matrixTransformer = matrixTransformer;
		}
		
		public function reflect(view:DisplayObject):DisplayObject
		{
			return flipVertically(flipHorizontally(view));
		}
		
		public function reflectAt(view:DisplayObject, x:Number, y:Number):DisplayObject
		{
			view.transform.matrix = _matrixTransformer.scaleAboutPoint(view.transform.matrix, x, y, -1, -1);
			return view;
		}
		
		public function flipHorizontally(view:DisplayObject):DisplayObject
		{
			view.scaleX = -view.scaleX;
			return view;
		}
		
		public function flipVertically(view:DisplayObject):DisplayObject
		{
			view.scaleY = -view.scaleY;
			return view;
		}
		
		public function flipHorizontallyAt(view:DisplayObject, x:Number):DisplayObject
		{
			view.transform.matrix = _matrixTransformer.scaleAboutPoint(view.transform.matrix, x, 0, -1, 1);
			return view;
		}
		
		public function flipVerticallyAt(view:DisplayObject, y:Number):DisplayObject
		{
			view.transform.matrix = _matrixTransformer.scaleAboutPoint(view.transform.matrix, 0, y, 1, -1);
			return view;
		}
		
		public function zoomAt(view:DisplayObject, x:Number, y:Number, scaleIncrement:Number):DisplayObject
		{
			return scaleAt(view, x, y, 1 + scaleIncrement);
		}
		
		public function scaleAt(view:DisplayObject, x:Number, y:Number, scale:Number):DisplayObject
		{
			view.transform.matrix = _matrixTransformer.scaleAboutPoint(view.transform.matrix, x, y, scale, scale);
			return view;
		}
		
		public function rotateAt(view:DisplayObject, x:Number, y:Number, angle:Number):DisplayObject
		{
			view.transform.matrix = _matrixTransformer.rotatedAboutPoint(view.transform.matrix, x, y, angle);
			return view;
		}
		
	}

}