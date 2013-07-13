package orichalcum.audio 
{
	internal class _NullSound
	{
		public function get length():Number { return 0; }
		public function play(...args):Object { return AudioClip.NULL_SOUND_CHANNEL; }
	}
}