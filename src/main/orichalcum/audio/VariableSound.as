package orichalcum.audio 
{
	import orichalcum.utility.Random;
	import flash.media.SoundChannel;
	import flash.media.Sound;
	import flash.media.SoundTransform;

	public class VariableSound extends com.orichalcum.audio.Sound
	{
		private static const NULL_SOUND_CHANNEL:SoundChannel = new SoundChannel;
		private var _soundClasses:Vector.<Class>;
		private var _sounds:Vector.<flash.media.Sound>;
		private var _previousSound:int = -1;
		
		
		public function VariableSound(soundClasses:Vector.<Class>)
		{
			super(null);
			_soundClasses = soundClasses;
			_sounds = new Vector.<flash.media.Sound>;
			_sounds.length = _soundClasses.length;
		}
		
		override public function play(startTime:Number = 0, loops:int = 0, soundTransform:SoundTransform = null):SoundChannel 
		{
			if (!_soundClasses || !_soundClasses.length)
				return NULL_SOUND_CHANNEL;
				
			_sound = _soundClasses.length == 1 ? getSample(0) : getRandomSample();
			return super.play(startTime, loops, soundTransform);
		}
		
		private function getSample(index:int):flash.media.Sound
		{
			return _sounds[index] ||= new _soundClasses[index]();
		}
		
		private function getRandomSample():flash.media.Sound
		{
			return getSample(_previousSound = Random.nonRepeatingInteger(0, _soundClasses.length - 1, _previousSound));
		}

	}

}