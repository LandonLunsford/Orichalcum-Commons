package orichalcum.transform
{
	import flash.geom.Matrix;
	
	public class MatrixTransformer 
	{
		
		static private var _instance:MatrixTransformer;
		
		static public function getInstance():MatrixTransformer
		{
			return _instance ||= new MatrixTransformer;
		}
		
		public function scaleAboutPoint(matrix:Matrix, x:Number, y:Number, scaleX:Number, scaleY:Number):Matrix
		{
			matrix.translate( -x, -y);
			matrix.scale(scaleX, scaleY);
			matrix.translate(x, y);
			return matrix;
		}
		
		public function rotatedAboutPoint(matrix:Matrix, x:Number, y:Number, angle:Number):Matrix
		{
			matrix.translate( -x, -y);
			matrix.rotate(angle);
			matrix.translate(x, y);
			return matrix;
		}
	}

}