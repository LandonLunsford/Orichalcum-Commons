package orichalcum.animation 
{
	import orichalcum.utility.FunctionUtil;

	public class AnimationCall extends AnimationBase
	{
		private var _previousProgress:Number = -0.0001;
		private var _progress:Number = 0;
		private var _thisObject:Object;
		private var _callback:Function = FunctionUtil.NULL;
		private var _callbackArguments:Array;
		
		public function AnimationCall(args:Array) 
		{
			if (args.length == 0) return;
			
			const arg0:* = args[0];
			
			if (arg0 is Function)
			{
				_callback = arg0
				_callbackArguments = args.slice(1);
			}
			else
			{
				_thisObject = arg0;
				if (args.length > 1)
				{
					_callback = args[1];
					_callbackArguments = args.slice(1);
				}
			}
		}
		
		override internal function _render(position:Number, isGoto:Boolean = false, triggerCallbacks:Boolean = true, progress:Number = NaN):void
		{
			_progress = progress;
			_previousProgress < 0 && _progress >= 0 && _callback.apply(_thisObject, _callbackArguments);
			_previousProgress = _progress;
		}
		
	}

}
