package orichalcum.animation 
{
	final public class Ease
	{
		static private const TWO_PI:Number = Math.PI * 2;
		static private const HALF_PI:Number = Math.PI * 0.5;
		
		static public function linear(t:Number, b:Number, c:Number, d:Number):Number
		{
			return b + (c / d) * t;
		}
		
		static public function quadIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return b + c * (t /= d) * t;
		}
		
		static public function quadOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return 	b - c * (t /= d) * (t - 2);
		}
		
		static public function quadInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return ((t /= d * 0.5) < 1)
				? c * 0.5 * t * t + b
				: -c * 0.5 * ((--t) * (t - 2) - 1) + b;
		}
		
		static public function cubicIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t * t + b;
		}
		
		static public function cubicOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * ((t = t / d -1) * t * t + 1) + b;
		}
		
		static public function cubicInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return ((t /= d * 0.5) < 1)
				? c * 0.5 * t * t * t + b
				: c * 0.5 * ((t -= 2) * t * t + 2) + b;
		}
		
		public static function quartIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t * t * t + b;
		}
		
		public static function quartOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * ((t = t / d -1) * t * t * t - 1) + b;
		}
		
		public static function quartInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return ((t /= d * 0.5) < 1)
				? c * 0.5 * t * t * t * t + b
				: -c * 0.5 * ((t -= 2) * t * t * t - 2) + b;
		}
		
		public static function quintIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t * t * t * t + b;
		}
		
		public static function quintOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
		}
		
		public static function quintInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return ((t /= d * 0.5) < 1)
				? c * 0.5 * t * t * t * t * t + b
				: c * 0.5 * ((t -= 2) * t * t * t * t + 2) + b;
		}
		
		public static function circIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * (Math.sqrt(1 - (t /= d) * t) - 1) + b;
		}
		
		public static function circOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * Math.sqrt(1 - (t = t / d - 1) * t) + b;
		}
		
		public static function circInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return ((t /= d * 0.5) < 1)
				? -c * 0.5 * (Math.sqrt(1 - t * t) - 1) + b
				: c * 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1) + b;
		}
		
		public static function backIn(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
		{
			return c * (t /= d) * t * ((s + 1) * t - s) + b;
		}
		
		public static function backOut(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
		{
			return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
		}
		
		public static function backInOut(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
		{
			return ((t /= d * 0.5) < 1)
				? c * 0.5 * (t*t*(((s*=(1.525))+1)*t - s)) + b
				: c * 0.5 * ((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
		}
		
		public static function bounceIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c - bounceOut(d - t, 0, c, d) + b;
		}
		
		public static function bounceOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if ((t/=d) < (1/2.75))
				return c*(7.5625*t*t) + b;
			else if (t < (2/2.75))
				return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
			else if (t < (2.5/2.75))
				return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
			return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
		}
		
		public static function bounceInOut(t:Number, b:Number, c:Number, d:Number):Number 
		{
			if (t < d*0.5) return bounceIn(t*2, 0, c, d) * .5 + b;
			return bounceOut(t*2-d, 0, c, d) * .5 + c*.5 + b;
		}
		
		public static function elasticIn(t:Number, b:Number, c:Number, d:Number, a:Number = 0, p:Number = 0):Number
		{
			var s:Number;
			if (t == 0) return b;
			if ((t /= d) == 1) return b + c;
			if (!p) p = d * .3;
			if (!a || (c > 0 && a < c) || (c < 0 && a < -c))
			{
				a=c;
				s = p * 0.25;
			}
			else
			{
				s = p / TWO_PI * Math.asin(c / a);
			}
			return b - (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * TWO_PI / p));
		}
		
		public static function elasticOut(t:Number, b:Number, c:Number, d:Number, a:Number = 0, p:Number = 0):Number
		{
			var s:Number;
			if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
			if (!a || (c > 0 && a < c) || (c < 0 && a < -c)) { a=c; s = p/4; }
			else s = p/TWO_PI * Math.asin (c/a);
			return (a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*TWO_PI/p ) + c + b);
		}
		
		public static function elasticInOut(t:Number, b:Number, c:Number, d:Number, a:Number = 0, p:Number = 0):Number
		{
			var s:Number;
			if (t==0) return b;  if ((t/=d*0.5)==2) return b+c;  if (!p) p=d*(.3*1.5);
			if (!a || (c > 0 && a < c) || (c < 0 && a < -c)) { a=c; s = p * 0.25; }
			else s = p/TWO_PI * Math.asin (c/a);
			if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*TWO_PI/p )) + b;
			return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*TWO_PI/p )*.5 + c + b;
		}
		
		public static function expoIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return (t == 0) ? b : c * Math.pow(2, 10 * (t / d - 1)) + b - c * 0.001;
		}
		
		public static function expoOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return (t == d) ? b + c : c * (-Math.pow(2, -10 * t / d) + 1) + b;
		}
		
		public static function expoInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if (t == 0) return b;
			if (t == d) return b + c;
			if ((t /= d * 0.5) < 1) return c * 0.5 * Math.pow(2, 10 * (t - 1)) + b;
			return c * 0.5 * (-Math.pow(2, -10 * --t) + 2) + b;
		}
		
		public static function sineIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * Math.cos(t / d * HALF_PI) + c + b;
		}
		
		public static function sineOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * Math.sin(t / d * HALF_PI) + b;
		}
		
		public static function sineInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * 0.5 * (Math.cos(Math.PI * t / d) - 1) + b;
		}

	}
	
}
