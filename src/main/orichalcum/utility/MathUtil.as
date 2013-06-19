package orichalcum.utility 
{

	import flash.geom.Point;
	
	public class MathUtil 
	{
		static private var _powers:Array = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000];
		static public const DEGREE_TO_RADIAN:Number = Math.PI / 180;
		static public const RADIAN_TO_DEGREE:Number = 180 / Math.PI;
		
		static public function toDegrees(radians:Number):Number
		{
			return radians * RADIAN_TO_DEGREE;
		}
		
		static public function toRadians(degrees:Number):Number
		{
			return degrees * DEGREE_TO_RADIAN;
		}
		
		static public function getDigit(index:int, number:int):int
		{
			return int((number / _powers[index]) % 10);
		}

		static public function gcd(x:int, y:int):int
		{
			while (x * y != 0) x >= y ? x %= y : y %= x;
			return x + y;
		}
		
		static public function ratio(width:int = 0, height:int = 0):Point
		{
			const gcd:int = gcd(width, height);
			return new Point(width / gcd, height / gcd);
		}
		
		/**
		 * @param	value Number that will be bound by upper and lower limits
		 * @param	minimum The minimum possible value that 'value' to take on
		 * @param	maximum The maximum possible value that 'value' may take on
		 * @return Number 'value' if value falls between bounds
		 * if it falls below minimum, minimum will be returned
		 * if it exceeds maximum, maximum will be returned
		 */
		static public function limit(value:Number, minimum:Number, maximum:Number):Number
		{
			if (value > maximum) return maximum;
			if (value < minimum) return minimum;
			return value;
		}
		
		static public function fuzzyEquals(a:Number, b:Number, threshold:Number = 1):Boolean
		{
			return Math.abs(a - b) < threshold;
		}
		
		static public function numberInterpolation(a:Number, b:Number, lamda:Number):Number
		{
			return a + (b - a) * lamda;
		}
		
		static public function isBetween(value:Number, a:Number, b:Number):Boolean
		{
			return value >= a && value <= b;
		}
		
		static public function sum(...values):Number
		{
			var sum:Number = 0;
			for each(var value:Number in values)
				sum += value;
			return sum;
		}
		
		static public function average(...values):Number
		{
			return values.length == 0 ? 0 : sum.apply(null, values) / values.length;
		}
		
		
	}

}
