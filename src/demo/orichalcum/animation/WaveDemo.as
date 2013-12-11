package orichalcum.animation
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import orichalcum.animation.factory.animate;
	import orichalcum.animation.factory.wait;
	import orichalcum.animation.tweener.plugin.displayobject.ScaleTweener;

	public class WaveDemo extends Sprite
	{
		
		public function WaveDemo() 
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
				shape.y = stage.stageHeight * 0.5;
				shape.name = 'shape_' + i;
				shapes.push(shape);
				addChild(shape);
			}
			i = 0;
			
			var a:Animation = (new Animation(shapes))
				//.to( { rotationX:360 } )
				.to( { y:80 } )
				.seconds(1)
				.stagger(2 / totalShapes)
				.yoyo(true)
				
				//.yoyo(true)
				//.forEach(function(child:Animation):void { child.yoyo(true); })
				
			var a2:Animation = animate(
				wait(0.5)
				,a.onComplete(function():void {trace('done')})
				,wait()
				,wait(0.5)
			).onComplete(function():void {trace('done')})
			//.yoyo(true)
			//.forEach(function(child:Animation):void { child.yoyo(true); })
			
			stage.addEventListener(MouseEvent.CLICK, function(event:Event):void {
				//var progress:Number = stage.mouseX / stage.stageWidth;
				a2.isPlaying ? a2.reverse() : a2.play();
			});
		}
		
	}

}
