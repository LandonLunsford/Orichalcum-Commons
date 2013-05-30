package orichalcum.audio
{
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	public interface ISound
	{
		function play(startTime:Number = NaN, loops:int = -1, soundTransform:SoundTransform = null):SoundChannel;
		function pause():int;
		function stop():void;
		function get progress():Number;
		function set progress(value:Number):void;
		function get volume():Number;
		function set volume(value:Number):void;
		function get pan():Number;
		function set pan(value:Number):void;
		
	}

}