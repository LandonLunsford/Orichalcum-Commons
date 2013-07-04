package orichalcum.animation.tweener.plugin.displayobject 
{
	import orichalcum.animation.tweener.NumberTweener;

	public class RotationTweener extends NumberTweener
	{
		
		static public const properties:Array = ['rotation', 'rotationX', 'rotationY', 'rotationZ'];
		
		override public function tween(target:Object, property:String, progress:Number):* 
		{
			const value:Number = super.tween(target, property, progress, isStart, isEnd) % 360;
			if (value > 180)
			{
				value -= 360;
			}
			else if (value < -180)
			{
				value += 360;
			}
			return value;
		}
		
		
	}

}