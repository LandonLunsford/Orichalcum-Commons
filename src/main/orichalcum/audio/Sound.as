package orichalcum.audio 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	public class Sound extends EventDispatcher
	{
		protected var _sound:flash.media.Sound;
		protected var _soundClass:Class;
		protected var _soundChannel:SoundChannel;
		protected var _progress:Number = 0;
		protected var _loops:int;
		
		public function Sound(soundClass:Class)
		{
			_soundClass = soundClass;
		}
		
		public function play(startTime:Number = NaN, loops:int = -1, soundTransform:SoundTransform = null):SoundChannel
		{
			_soundChannel = sound.play(isNaN(startTime) ? _progress : startTime, loops < 0 ? _loops : loops, soundTransform);
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
			return _soundChannel;
		}
		
		public function pause():int
		{
			_progress = _soundChannel.position;
			_soundChannel.stop();
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			return _progress;
		}
		
		public function stop():void
		{
			_progress = 0;
			_soundChannel.stop();
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}

		public function get progress():Number
		{
			return _soundChannel ? _soundChannel.position : 0;
		}
		
		public function set progress(value:Number):void 
		{
			_soundChannel.position = _progress = value;
		}
		
		public function get volume():Number
		{
			return _soundChannel ? _soundChannel.soundTransform.volume : 0;
		}
		
		public function set volume(value:Number):void
		{
			if (_soundChannel)
			{
				const soundTransform:SoundTransform = _soundChannel.soundTransform;
				soundTransform.volume = value;
				_soundChannel.soundTransform = soundTransform;
			}
		}
		
		public function get pan():Number
		{
			return _soundChannel ? _soundChannel.soundTransform.pan : 0;
		}
		
		public function set pan(value:Number):void
		{
			if (_soundChannel)
			{
				const soundTransform:SoundTransform = _soundChannel.soundTransform;
				soundTransform.pan = value;
				_soundChannel.soundTransform = soundTransform;
			}
		}
		
		private function get sound():flash.media.Sound
		{
			return _sound ||= new _soundClass;
		}
		
		private function onSoundComplete(event:Event):void
		{
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			dispatchEvent(event);
		}
		
	}

}