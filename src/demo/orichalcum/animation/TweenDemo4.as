package orichalcum.animation
{
	import flash.display.Sprite;
	import orichalcum.animation.factory.animate;
	import orichalcum.animation.factory.call;
	import orichalcum.animation.factory.wait;

	public class TweenDemo4 extends Sprite
	{
		
		public function TweenDemo4() 
		{
			var tracer:Function = function():void { trace('poop'); };
			var a2:Animation = animate(
				call(tracer)
				,wait(1)
				,call(tracer)
				,wait(1)
				,call(tracer)
				,wait(1)
			)
			.play();
		}
		
	}

}
