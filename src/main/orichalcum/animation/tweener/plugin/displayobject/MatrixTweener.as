package orichalcum.animation.tweener.plugin.displayobject 
{
	import flash.geom.Matrix;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;

	public class MatrixTweener extends NumberTweener implements ITweener
	{
		
		static public const properties:Array = ['a', 'b', 'c', 'd', 'tx', 'ty'];
		
		override public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			super.initialize(
				target
				,property
				,from
				,to
				,fromValueIfAny is Number ? fromValueIfAny : target.transform.matrix[property]
				,toValueIfAny is Number ? toValueIfAny : target.transform.matrix[property]
			);
		}
		
		override public function tween(target:Object, property:String, progress:Number):* 
		{
			const m:Matrix = target.transform.matrix;
			m[property] = interpolate(progress);
			target.transform.matrix = m;
		}
		
	}

}
