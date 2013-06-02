package orichalcum.animation
{
	import com.orichalcum.core.coreEventDispatcher;
	import flash.display.Bitmap;
	import flash.events.Event;

	/**
	 * @TODO Frame scripts should be in the Animation (ie implement addFrameScript(frameNumber, function);
	 * @BUG Though animation would be good to decouple from its container
	 * 	this causes problems when its onEnterFrame doesn't line up with its
	 * 	container's
	 * @BUG stop() on frameData with null cellData doesn't work
	 * 
	 * @author Landon Lunsford
	 */
	
	public class Animation extends Bitmap
	{
		
		/******************************************************************
		 * Private members
		 *****************************************************************/
		
		private var _timeline:AnimationTimeline;
		
		private var _currentFrame:int;
		
		private var _currentLabel:String;
		
		private var _cells:Array;
		
		private var _frameRate:Number;
		
		private var _frameCount:Number = 0;
		
		/******************************************************************
		 * Accessors
		 *****************************************************************/
		
		public function get timeline():AnimationTimeline { return _timeline; }
		
		public function get cells():Array { return _cells; }
		
		public function get frameRate():Number { return _frameRate; }
		
		public function get currentFrame():int { return _timeline ? _currentFrame : 0; }
		
		public function get totalFrames():int { return _timeline ? _timeline.totalFrames : 0; }
		
		public function get currentLabel():String { return _timeline ? _currentLabel : null; }
		
		/******************************************************************
		 * Modifiers
		 *****************************************************************/
		
		public function set timeline(timeline:AnimationTimeline):void
		{
			_timeline = timeline;
			updateCurrentFrame(_currentFrame);
		}
		
		public function set cells(cells:Array):void
		{
			_cells = cells;
			updateCurrentFrame(_currentFrame);
		}
		
		public function set frameRate(value:Number):void
		{
			if (value > 0) _frameRate = value;
		}
		
		/******************************************************************
		 * Public interface
		 *****************************************************************/
		
		public function play():void
		{
			_enterFrameEventDispatcher.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}
		
		public function stop():void
		{
			_enterFrameEventDispatcher.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function nextFrame():void
		{
			updateCurrentFrame(_currentFrame + 1);
		}
		
		public function prevFrame():void
		{
			updateCurrentFrame(_currentFrame - 1);
		}
		
		public function gotoAndPlay(frame:*):void
		{
			updateCurrentFrame(frame);
			play();
		}
		
		public function gotoAndStop(frame:*):void
		{
			stop();
			updateCurrentFrame(frame);
		}
		
		public function dispose():void
		{
			_cells = null;
			_timeline = null;
		}
		
		/******************************************************************
		 * Private methods
		 *****************************************************************/

		private function onEnterFrame(event:Event):void
		{
			// Feature disabled for efficiency
			//if (isNaN(_frameRate))
			//{
				nextFrame();
			//}
			//else
			//{
				//_frameCount += isNaN(_frameRate) ? 1 : _frameRate / stage.frameRate;
				//updateCurrentFrame(_currentFrame + int(_frameCount));
				//if (_frameCount >= 1) _frameCount = 0;
			//}
		}
		
		private function updateCurrentFrame(frame:*):void
		{
			if (!_timeline) return;
			
			if (frame is Number)
			{
				_currentFrame = frame > totalFrames || frame < 1 ? 1 : frame;
			}
			else if (frame is String)
			{
				_currentFrame = _timeline.getFrameNumber(frame);
			}
				
			updateView(_timeline.getFrame(_currentFrame));
			executeScript(_timeline.getFrameScript(_currentFrame));
		}
		
		private function executeScript(script:Function):void
		{
			if (script != null) script(this);
		}
		
		private function updateView(frameData:Object):void
		{
			if (!_cells) return;
			
			for (var property:String in frameData)
				this[property] = frameData[property];
		}
		
		private function set cell(cellNumber:int):void
		{
			bitmapData = cellNumber < 0 ? null : cells[cellNumber];
		}
		
		private function set label(value:String):void
		{
			_currentLabel = value;
		}
		
		/******************************************************************
		 * Overriden members
		 *****************************************************************/

		override public function set scaleX(value:Number):void 
		{
			if (scaleX == value) return;
			x += width * scaleX;
			super.scaleX = value;
		}
		
		override public function set scaleY(value:Number):void 
		{
			if (scaleY == value) return;
			y += height * scaleY;
			super.scaleY = value;
		}
		
	}

}