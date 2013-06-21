package orichalcum.animation.sequence 
{
	import orichalcum.animation.IPlayable;
	import orichalcum.animation.ITween;
	import orichalcum.animation.Tween;


	internal class ToCommand extends WaitCommand
	{
		private var _tweenArguments:Array;
		private var _tween:ITween;
		
		public function ToCommand(...args) 
		{
			_tweenArguments = args;
		}
		
		override public function play(onComplete:Function = null, ...args):IPlayable 
		{
			(_tween ||= new Tween).to.apply(_tween, _tweenArguments);
			_duration = _tween.duration;
			_useFrames = _tween.useFrames;
			return super._play(onComplete, args);
		}
		
		override public function replay():IPlayable 
		{
			_tween.replay();
			return super.replay();
		}
		
		override public function pause():IPlayable 
		{
			_tween.pause();
			return super.pause();
		}
		
		override public function stop():IPlayable 
		{
			_tween.stop();
			return super.stop();
		}
		
		override public function toggle():IPlayable 
		{
			_tween.toggle();
			return super.toggle();
		}
		
		override public function end(supressCallbacks:Boolean = false):IPlayable 
		{
			_tween.end(supressCallbacks);
			return super.end(supressCallbacks);
		}
	}

}