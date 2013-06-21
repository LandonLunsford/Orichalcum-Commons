package orichalcum.animation 
{
	
	public interface ITween extends IAnimation
	{
		// special use to invalidate isInitialized
		//function reset():ITween;
		
		function get from():*;
		function set from(value:*):void;
		
		function get target():Object;
		function set target(value:Object):void;
		
		function get delay():Number;
		function set delay(value:Number):void;
		
		function get duration():Number;
		function set duration(value:Number):void;
		
		function get repeats():Number;
		function set repeats(value:Number):void;
		
		function get iterations():Number;
		
		function get timeScale():Number;
		function set timeScale(value:Number):void;
		
		function get useFrames():Boolean;
		function set useFrames(value:Boolean):void;
		
		function get yoyo():Boolean;
		function set yoyo(value:Boolean):void;
		
		function get onInit():Function;
		function set onInit(value:Function):void;
		
		function get onChange():Function;
		function set onChange(value:Function):void;
		
		function get onComplete():Function;
		function set onComplete(value:Function):void;
		
		function get isPlayingForward():Boolean;
		function get isPlayingBackward():Boolean;
		function get isPlaying():Boolean;
		function get isPaused():Boolean;

		function to(...args):ITween;
	}

}