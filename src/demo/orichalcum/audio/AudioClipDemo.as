package orichalcum.audio 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import orichalcum.animation.Ease;
	import orichalcum.animation.factory.animate;
	import orichalcum.audio.AudioClip;

	public class AudioClipDemo extends Sprite
	{
		private var _sound:Sound = new Sound(new URLRequest('C:/Users/landon/Desktop/Roly Poly Puzzled Music.mp3'));
		private var _audio:AudioClip;
		
		
		public function AudioClipDemo() 
		{
			_audio = new AudioClip(
				//_sound
			);
			
			stage.addEventListener(MouseEvent.CLICK, _onMouseClick);
		}
		
		private function _onMouseClick(event:MouseEvent):void 
		{
			
			_audio.volume = 0.1;
			//_audio.pan = -1;
			_audio.sound = _sound;
			_audio.play();
			
			animate(_audio)
				.from( { pan: -2 } )
				.to( { pan: 2 } )
				.yoyo(true)
				.repeat( -1)
				.seconds(5)
				.ease(Ease.linear)
				.play()
				
			//_sound.toggle();
			//_sound.isPaused ? _sound.play() : _sound.toggleMute();
		}
		
	}

}