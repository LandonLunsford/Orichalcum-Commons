package orichalcum.animation
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import orichalcum.animation.factory.animate;
	import orichalcum.animation.factory.wait;
	import orichalcum.animation.tweener.plugin.displayobject.ScaleTweener;

	public class AnimationDemo_0 extends Sprite
	{
		
		public function AnimationDemo_0() 
		{
			const totalShapes:int = 1;
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
				.to( { x:stage.stageWidth, scale:3 } )
				.seconds(2)
				.iterations(2)
				//.onInit(function():void { trace(Animation.currentTime); })
				//.onComplete(function():void { trace(Animation.currentTime); } )
				.onYoyo(function():void { trace('yoyo', Animation.currentTime); })
				.onIteration(function():void { trace('iter', Animation.currentTime); })
				.yoyo(true)
				//.stagger(1) // stagger ruins it
				.timeScale(0.5)
				
			
			stage.addEventListener(MouseEvent.CLICK, function(event:Event):void {
				//var progress:Number = stage.mouseX / stage.stageWidth;
				a.isPlaying ? a.reverse() : a.play();
			});
		}
		
	}

}
