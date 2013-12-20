package orichalcum.audio 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import orichalcum.utility.FunctionUtil;
	import orichalcum.utility.MathUtil;

	public class AudioClip
	{
		/** @private used to avoid null checks */
		static internal const NULL_SOUND_CHANNEL:Object = new _NullSoundChannel();
		
		/** @private used to avoid null checks */
		static internal const NULL_SOUND:Object = new _NullSound();
		
		/** @private the sound object to decorate */
		protected var _sound:Object = NULL_SOUND;
		
		/** @private the sound channel used to apply a transform and stop the sound */
		protected var _soundChannel:Object = NULL_SOUND_CHANNEL;
		
		/** @private the transform used to control the sound characteristics */
		protected var _soundTransform:SoundTransform = new SoundTransform;
		
		/** @private */
		protected var _isPlaying:Boolean;
		
		/** @private */
		protected var _isMuted:Boolean;
		
		/** @private the location of the playhead */
		protected var _position:Number = 0;
		
		/** @private the number of times the sound will loop */
		protected var _loops:int;
		
		/** @private the volume of the sound */
		protected var _volume:Number = 1;
		
		/** @private the function called when the sound completes */
		protected var _onComplete:Function = FunctionUtil.NULL;
		
		
		public function AudioClip(sound:Sound = null)
		{
			_sound = sound ? sound : NULL_SOUND;
		}
		
		public function mute():AudioClip
		{
			_isMuted = true;
			return _syncSoundTransform();
		}
		
		public function unmute():AudioClip
		{
			_isMuted = false;
			return _syncSoundTransform();
		}
		
		public function toggleMute():AudioClip
		{
			return _isMuted ? unmute() : mute();
		}
		
		public function play():AudioClip
		{
			return _setIsPlaying(true);
		}
		
		public function pause():AudioClip
		{
			return _setIsPlaying(false);
		}
		
		public function toggle(...args):AudioClip
		{
			return _isPlaying ? pause() : play();
		}

		public function stop():AudioClip
		{
			return pause().rewind();
		}
		
		public function rewind():AudioClip
		{
			return goto(0);
		}
		
		public function end():AudioClip
		{
			return goto(_sound.length);
		}
		
		public function goto(position:Number):AudioClip
		{
			_position = MathUtil.limit(position, 0, _sound.length);
			if (_position === _sound.length) _soundCompleteHandler(null);
			return this;
		}
		
		public function onComplete(callback:Function):AudioClip
		{
			_onComplete = FunctionUtil.nullToEmpty(callback);
			return this;
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function get isPaused():Boolean
		{
			return !_isPlaying;
		}
		
		public function get isMuted():Boolean
		{
			return _isMuted;
		}
		
		public function get loops():Number
		{
			return _loops;
		}
		
		public function set loops(value:Number):void
		{
			if (_loops === value) return;
			_loops = value;
			_applyChange();
		}
		
		public function get position():Number
		{
			return _soundChannel ? _soundChannel.position : _position;
		}

		public function set position(value:Number):void 
		{
			if (_position === value) return;
			_position = value;
			_applyChange();
		}

		public function get volume():Number
		{
			return _volume;
		}

		public function set volume(value:Number):void
		{
			if (_volume === value) return;
			_volume = value;
			_syncSoundTransform();
		}

		public function get pan():Number
		{
			return _soundTransform.pan;
		}

		public function set pan(value:Number):void
		{
			if (_soundTransform.pan === value) return;
			_soundTransform.pan = value;
			_syncSoundTransform();
		}
		
		public function get sound():Sound 
		{
			return _sound === NULL_SOUND ? null : _sound as Sound;
		}
		
		public function set sound(value:Sound):void 
		{
			_sound = value ? value : NULL_SOUND;
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE
		///////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function _soundCompleteHandler(event:Event):void
		{
			_onComplete();
		}
		
		private function _syncSoundTransform():AudioClip
		{
			_soundTransform.volume = _isMuted ? 0 : _volume;
			_soundChannel.soundTransform = _soundTransform;
			return this;
		}
		
		private function _applyChange():AudioClip
		{
			return _isPlaying ? _setIsPlaying(false)._setIsPlaying(true) : this;
		}
		
		private function _addListeners():void
		{
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, _soundCompleteHandler, false, 0, true);
		}
		
		private function _removeListeners():void
		{
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, _soundCompleteHandler);
		}
		
		private function _setIsPlaying(value:Boolean):AudioClip
		{
			if (_isPlaying === value) return this;
			if (_isPlaying = value)
			{
				_soundChannel = _sound.play(_position, _loops, _soundTransform);
				_addListeners();
			}
			else
			{
				if (_soundChannel)
				{
					_position = _soundChannel.position;
					_soundChannel.stop();
					_removeListeners();
				}
			}
			return this;
		}

	}

}


