package orichalcum.animation.sequence 
{
	import flash.events.Event;
	import orichalcum.animation.IPlayable;
	import orichalcum.core.Core;
	import orichalcum.utility.FunctionUtil;

	internal class WaitCommand extends BaseCommand
	{
		
		private var _position:Number = 0;
		private var _duration:Number;
		private var _useFrames:Boolean;
		private var _callback:Function;
		private var _callbackArguments:Array;
		private var _isPlaying:Boolean;
		
		
		public function WaitCommand(duration:Number, useFrames:Boolean = false) 
		{
			_duration = duration;
			_useFrames = useFrames;
		}
		
		private function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		private function set isPlaying(value:Boolean):void
		{
			if (_isPlaying == value) return;
			_isPlaying = value;
			
			if (value)
			{
				Core.eventDispatcher.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			}
			else
			{
				Core.eventDispatcher.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			}
		}
		
		override public function play(callback:Function = null, ...args):IPlayable
		{
			isPlaying = true;
			_callback = callback != null ? callback : _callback;
			_callbackArguments = args.length ? args : _callbackArguments;
			return this;
		}
		
		override public function replay():IPlayable
		{
			_position = 0;
			return play();
		}
		
		override public function pause():IPlayable
		{
			isPlaying = false;
			return this;
		}
		
		override public function stop():IPlayable
		{
			_position = 0;
			return pause();
		}
		
		override public function toggle():IPlayable
		{
			isPlaying = !isPlaying;
			return this;
		}
		
		override public function end(supressCallbackes:Boolean = false):IPlayable
		{
			_position = _duration;
			supressCallbackes || FunctionUtil.callWith(_callback, null, _callbackArguments);
			return pause();
		}
		
		//////////////////////////////////////////////////////////////////////////////////////////
		// INTERNAL
		//////////////////////////////////////////////////////////////////////////////////////////
		
		private function _onEnterFrame(event:Event):void 
		{
			_position += _useFrames ? 1 : Core.deltaTime;
			_position >= _duration && end();
		}
		
	}

}