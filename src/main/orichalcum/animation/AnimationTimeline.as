package orichalcum.animation
{
	public class AnimationTimeline
	{
		/**
		 * Indexes at 1
		 */
		private var _frames:Array;
		
		/**
		 * Label : FrameIndex map
		 */
		private var _frameMap:Object;
		
		/**
		 * FrameNumber : script map
		 */
		private var _scriptMap:Object;
		
		public function AnimationTimeline(data:Object)
		{
			_frames = [];
			_frameMap = {};
			_scriptMap = {};
			fillMaps(data);
			fillFrames(data);
		}
		
		private function fillMaps(data:Object):void
		{
			for (var frameNumber:String in data)
			{
				var frame:Object = data[frameNumber];
				if (frame.label)
				{
					_frameMap[frame.label] = frameNumber;
				}
				if (frame.script)
				{
					_scriptMap[frameNumber] = frame.script;
					delete frame.script;
				}
				_frames[int(frameNumber)] = frame;
			}
		}
		
		private function fillFrames(data:Object):void
		{
			for (var i:int = 1; i < _frames.length; i++)
			{
				if (_frames[i])
				{
					var frame:Object = _frames[i];
				}
				else
				{
					_frames[i] = frame;
				}
			}
		}
		
		public function get totalFrames():int
		{
			return _frames.length;
		}

		public function getFrame(frameNumber:int):Object
		{
			return _frames[frameNumber];
		}
		
		public function getFrameNumber(label:String):int
		{
			return _frameMap[label];
		}
		
		public function getFrameScript(frameNumber:int):Function
		{
			return _scriptMap[frameNumber];
		}
		
		public function addFrameScript(frameNumber:int, script:Function):void
		{
			_scriptMap[frameNumber] = script;
		}
		
		public function dispose():void
		{
			_frames.length = 0;
			_frames = null;
			_frameMap = null;
			_scriptMap = null;
		}
		
	}

}