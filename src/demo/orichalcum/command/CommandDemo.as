package orichalcum.command 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import orichalcum.animation.IPlayable;
	import orichalcum.animation.sequence.ISequence;
	import orichalcum.animation.sequence.Sequence;
	import orichalcum.core.Core;


	public class CommandDemo extends Sprite
	{

		private var _frameCount:int;
		
		public function CommandDemo() 
		{
			//addEventListener(Event.ENTER_FRAME, function(event:*):void { trace(_frameCount++); } );
			const c:IPlayable = Sequence
				.wait(1)
				.call(this, function(a:*, b:*):void { trace(this, a, b); }, 5, 6)
				.wait(1)
				.call(this, function():void { trace(Core.currentTime); })
				.play()
				
				
				
			
		}
		
	}

}