package orichalcum.core 
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;

	final public class Core 
	{
		static public const eventDispatcher:IEventDispatcher = new Shape;
		static private var _currentTime:Number;
		static private var _deltaTime:Number;
		static private var _timeScale:Number = 1;
		static private var _pauseAll:Boolean;
		
		static public function get currentTime():Number
		{
			return _currentTime;
		}

		static public function get deltaTime():Number
		{
			return _deltaTime;
		}

		static public function get timeScale():Number
		{
			return _timeScale;
		}

		static public function set timeScale(value:Number):void
		{
			_timeScale = value;
		}

		static public function get pauseAll():Boolean 
		{
			return _pauseAll;
		}

		static public function set pauseAll(value:Boolean):void 
		{
			_pauseAll = value;
		}
		
		//////////////////////////////////////////////////////////////////////////////////////////////
		// STATIC INIT
		//////////////////////////////////////////////////////////////////////////////////////////////
		
		{
			_currentTime = getTimer();
			eventDispatcher.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
				const previousTime:Number = _currentTime;
				_currentTime = getTimer();
				_deltaTime = _pauseAll ? 0 : (_currentTime - previousTime) * _timeScale;
			});
		}
		
	}

}