package orichalcum.animation
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import orichalcum.utility.Mathematics;
	import rolypoly.model.Cube;
	import rolypoly.view.CubeView;

	public class AnimationPlayMeterDemo extends Sprite
	{
		
		public function AnimationPlayMeterDemo() 
		{
			const cubeView:CubeView = new CubeView(new Cube());
			
			const animation:Animation = new Animation()
				.target(cubeView)
				.from( { x: 100, y: 100 } )
				.to( { x: 100, y:200 } )
				.delay(0.5)
				.duration(1)
				.postDelay(1.5)
				.onComplete(function():void { trace(' on complete '); } )
				.ease(Ease.linear)
				.yoyo(true)
				.repeat(1)
				.pause()
				
			addChild(cubeView);
			
			const meter:Sprite = new Sprite;
			meter.graphics.beginFill(0x666666);
			meter.graphics.drawRect(0, 0, stage.stageWidth * 0.75, stage.stageHeight * 0.02);
			meter.graphics.endFill();
			meter.x = stage.stageWidth * 0.25 * 0.5;
			meter.y = meter.x;
			
			addChild(meter);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
				const progress:Number = Mathematics.limit(meter.mouseX, 0, meter.width) / meter.width;
				//trace('sent progress', progress)
				animation.progress(progress);
			})
		}
		
	}

}