package orichalcum.animation.tweener 
{

	public interface ITweener 
	{
		//function init(target:Object, property:String, parameters:Object):ITweener;
		function tween(target:Object, property:String, progress:Number):void;
	}

}
