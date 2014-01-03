package orichalcum.animation
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import orichalcum.animation.factory.animate;
	import orichalcum.animation.tweener.plugin.displayobject.ColorMatrixFilterTweener;

	public class ColorMatrixFilterDemo extends Sprite
	{
		
		public function ColorMatrixFilterDemo() 
		{
			Animation.install(ColorMatrixFilterTweener, 'colorMatrix');
			
			var shape:Shape = new Shape;
			shape.graphics.beginFill(0x999999)
			shape.graphics.drawCircle(0, 0, 25 + 25 * Math.random());
			shape.graphics.endFill();
			shape.x = stage.stageWidth *0.5;
			shape.y = stage.stageHeight * 0.5;
			addChild(shape);
			
			var a2:Animation = animate(shape)
				//.from({colorMatrix:[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] } )
				.to({ colorMatrix:[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] } )
				.seconds(5)
				.play()
			
			//trace((new ColorMatrixFilter).matrix)
			
			//stage.addEventListener(MouseEvent.CLICK, function(event:Event):void {
				//var progress:Number = stage.mouseX / stage.stageWidth;
				//a2.isPlaying ? a2.reverse() : a2.play();
			//});
			
		}
		
	}

}
