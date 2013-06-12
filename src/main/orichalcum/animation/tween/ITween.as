package orichalcum.animation.tween
{

	import orichalcum.animation.IAnimation;

	public interface ITween extends IAnimation
	{
		// special use to invalidate isInitialized
		function reset():ITween;
	
		function get from():*;
		function set from(value:*):void;
	
		function get repeats():Number;
		function set repeats(value:Number):void;
		
		function get iterations():Number;
		function set iterations(value:Number):void;
		
		function get yoyo():Boolean;
		function set yoyo(value:Boolean):void;
		
		function get ease():Function;
		function get ease(value:Function):void;
		
		function get timeScale():Number;
		function get timeScale(value:Number):void;
				
		function get onInit():Function;
		function set onInit(value:Function):void;
		
		function get onChange():Function;
		function set onChange(value:Function):void;
		
		function get onYoyo():Function;
		function set onYoyo(value:Function):void;
		
		function get onComplete():Function;
		function set onComplete(value:Function):void;
	
	}


}
