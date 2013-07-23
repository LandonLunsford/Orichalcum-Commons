package orichalcum.animation
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import orichalcum.animation.factory.animate;
	import orichalcum.animation.factory.wait;
	import orichalcum.animation.tweener.plugin.displayobject.ScaleTweener;

	public class TweenDemo5 extends Sprite
	{
		
		public function TweenDemo5() 
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
				.to( { x:stage.stageWidth, scale:3 } )
				.stagger(4 / totalShapes)
				.delay(2)
				.seconds(1)
				.postDelay(2)
				.yoyo(true) // no yoyo first
				.repeat(1)
				.onInit(function():void { trace('init', Animation.currentTime); })
				.onYoyo(function():void { trace('yoyo', Animation.currentTime); })
				.onComplete(function():void { trace('complete', Animation.currentTime); })
				
				//.forEach(function(child:AnimationBase):void { child.yoyo(true); })
			
			stage.addEventListener(MouseEvent.CLICK, function(event:Event):void {
				a.isPlaying ? a.reverse() : a.play();
			});
		}
		
	}

}
