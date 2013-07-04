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
	import orichalcum.animation.factory.wait;
	import orichalcum.animation.tweener.plugin.displayobject.ScaleTweener;
	import orichalcum.core.Core;

	public class TweenDemo3 extends Sprite
	{
		
		public function TweenDemo3() 
		{
			const totalShapes:int = 10;
			const shapes:Array = [];
			for (var i:int = 0; i < totalShapes; i++)
			{
				var shape:Shape = new Shape;
				shape.graphics.beginFill(0xffffff * Math.random())
				shape.graphics.drawCircle(0, 0, 25 + 25 * Math.random());
				shape.graphics.endFill();
				shape.x = (stage.stageWidth / totalShapes) * i;
				shape.y = (stage.stageHeight / totalShapes) * i;
				shape.name = 'shape_' + i;
				shapes.push(shape);
				addChild(shape);
			}
			i = 0;
			
			Animation.install(ScaleTweener, 'scale');
			
			var a:Animation = (new Animation(shapes))
				//.to( { rotationX:360 } )
				.to( { x:stage.stageWidth, visible:false, scale:3 } )
				.seconds(2)
				.onInit(function():void { trace(Animation.currentTime); })
				.onComplete(function():void { trace(Animation.currentTime); })
				.stagger(4 / totalShapes)
				//.yoyo(true)
				
			var a2:Animation = animate(
				wait(1)
				,a
				,wait()
				,wait(1)
			)
			.yoyo(true)
			.onYoyo(function():void { trace('there'); })
			.onComplete(function():void { trace('and back'); })
			
			
			//var a3:Animation =
			
			stage.addEventListener(MouseEvent.CLICK, function(event:Event):void {
				//var progress:Number = stage.mouseX / stage.stageWidth;
				a2.isPlaying ? a2.reverse() : a2.play();
			});
		}
		
	}

}
