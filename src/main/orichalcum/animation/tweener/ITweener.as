package orichalcum.animation.tweener 
{

	public interface ITweener 
	{
		//function init(target:Object, property:String, parameters:Object):void;
		
		function init(start:*, end:*):void;
		function tween(target:Object, property:String, progress:Number, isStart:Boolean, isEnd:Boolean):void;
	}

}
