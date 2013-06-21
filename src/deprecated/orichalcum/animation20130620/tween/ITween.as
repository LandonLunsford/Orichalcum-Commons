package orichalcum.animation
{

	public interface IAnimation
	{

		function goto(position:Number, supressCallbacks:Boolean = false):void;
		function gotoAndPlay(position:Number, supressCallbacks:Boolean = false):void;
		function gotoAndStop(position:Number, supressCallbacks:Boolean = false):void;
		function play():void;
		function stop():void;
		function toggle():void;
		function reset(supressCallbacks:Boolean = false):void;
		function replay(supressCallbacks:Boolean = false):void;
		function end(supressCallbacks:Boolean = false):void;
		function reverse():void;
		function playBackwards(supressCallbacks:Boolean = false):void;
	}


}
