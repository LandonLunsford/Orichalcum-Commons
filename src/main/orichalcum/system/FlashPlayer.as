package orichalcum.system
{
	import flash.system.Capabilities;

	public class FlashPlayer
	{
		static private var _flashPlayer:FlashPlayer;
		
		static public function getInstance():FlashPlayer
		{
			return _flashPlayer ||= new FlashPlayer;
		}
		
		private var _version:Number;
		
		public function FlashPlayer()
		{
			const flashPlayerVersionData:Array = Capabilities.version.split(' ')[1].split(',');
			_version = Number(flashPlayerVersionData[0] + '.' + flashPlayerVersionData[1]);
		}
		
		public function get version():Number
		{
			return _version;
		}
		
	}

}
