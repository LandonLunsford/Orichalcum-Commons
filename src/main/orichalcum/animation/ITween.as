package orichalcum.animation 
{
	import flash.events.IEventDispatcher;
	
	public interface ITween extends IEventDispatcher
	{
		
		function get position():Number;
		function set position(value:Number):void;
		
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
		
		function get autoPlay():Boolean;
		function set autoPlay(value:Boolean):void;
		
		function get useFrames():Boolean;
		function set useFrames(value:Boolean):void;
		
		function get yoyo():Boolean;
		function set yoyo(value:Boolean):void;
		
		function get ease():Function;
		function set ease(value:Function):void;
		
		function get onInit():Function;
		function set onInit(value:Function):void;
		
		function get onChange():Function;
		function set onChange(value:Function):void;
		
		function get onComplete():Function;
		function set onComplete(value:Function):void;
		
		function get isPlaying():Boolean;
		function set isPlaying(value:Boolean):void;
		
		function get isPaused():Boolean;
		function set isPaused(value:Boolean):void;
		
		/**
		 * Create a new tween to play at the end of this tween
		 * @param	...args
		 * 		to:Object
		 * 		target:Object, to:Object
		 * 		target:Object, duration:Number, to:Object
		 * @return new tween
		 */
		function next(...args):ITween;
		
		/**
		 * Modify the existing tween properties and continue to the new end properties
		 * @param	...args
		 * 		to:Object
		 * 		target:Object, to:Object
		 * 		target:Object, duration:Number, to:Object
		 * @return this tween
		 */
		function to(...args):ITween;
		
		/**
		 * Create a new tween to play at the end of this delay duration
		 * @param	...args
		 * 		to:Object
		 * 		target:Object, to:Object
		 * 		target:Object, duration:Number, to:Object
		 * @return new tween
		 */
		//function delay(duration:Number):ITween;
		
		function setPosition(position:Number, supressCallbacks:Boolean = false):void;
		function gotoAndPlay(position:Number, supressCallbacks:Boolean = false):void;
		function gotoAndStop(position:Number, supressCallbacks:Boolean = false):void;
		function play():void;
		function stop():void;
		function toggle():void;
		function reset(supressCallbacks:Boolean = false):void;
		function replay(supressCallbacks:Boolean = false):void;
		function end(supressCallbacks:Boolean = false):void;
		function playReverse(supressCallbacks:Boolean = false):void;
	}

}