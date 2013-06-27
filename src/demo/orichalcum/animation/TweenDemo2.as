package orichalcum.animation
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import orichalcum.animation.factory.animate;
	import orichalcum.animation.factory.call;
	import orichalcum.animation.factory.tween;
	import orichalcum.animation.factory.wait;
	import orichalcum.animation.tweener.plugin.AutoHideTweener;
	import orichalcum.core.Core;

	public class TweenDemo2 extends Sprite
	{
		
		public function TweenDemo2() 
		{
			const shape:Shape = new Shape;
			shape.graphics.beginFill(0xffffff * Math.random())
			shape.graphics.drawCircle(0, 0, 200);
			shape.graphics.endFill();
			addChild(shape);
			
			//Animation.install(AutoHideTweener, 'alpha')
			
			//var a:Tween = tween(shape)
				//.from( { x: 200, y: 200 } )
				//.to( { x: '[+=200]', y: 400} )
				//.to( { x: 300, y: 400} )
				//.to( { x: stage.stageWidth, y: stage.stageHeight} )
				//.yoyo(true)
				//.repeat(2) // odd repeats fail
				//.repeat(1) // odd repeats snap to "to" values
				//.seconds(5)
				//.frames(30)
				//.timeScale(0.2)
				//.play();
				//.onComplete(function(isJump:Boolean):void { trace('complete'); } );
				
			// bug ! yoyo, odd-repeat to-tweens snap to target "to" values on complete
			
			/*
			animate(
				wait(1)
				,tween(a, b, c).to(x).stagger(0.3) // tweengroup ... extends animation
				,animate(a, b, c) anything with tween children can have stagger
			
			).stagger
			*/
			
			var a:Animation = animate(
				wait(1)
				,call(function():void { trace(Core.currentTime, 'call 1'); } )
				,wait(2)
				,tween(shape)
					//.from({x:0,y:0})
					.to( { x: 400, y: 400 } )
					.seconds(1)
					.onComplete(function():void { trace(Core.currentTime, 'tween complete'); } )
				,wait()
				,call(function():void { trace(Core.currentTime, 'call 2'); } )
			);
			
			
			stage.addEventListener(MouseEvent.CLICK, function(event:Event):void {
				var progress:Number = stage.mouseX / stage.stageWidth;
				//a.progress(progress);
				a.toggle()
				//a.replay()
				//a.invalidate().replay()
				//a.reverse();
				//a.play();
				//trace('click')
				//a.end(); // not working
				//a.goto(progress * a.totalDuration);
			});
		}
		
	}

}
