package orichalcum.animation
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import orichalcum.animation.tweener.plugin.displayobject.MotionBlurTweener;
	import orichalcum.utility.Mathematics;
	import rolypoly.model.Cube;
	import rolypoly.view.CubeView;

	public class MultiTargetAnimationDemo extends Sprite
	{
		
		public function MultiTargetAnimationDemo() 
		{
			Animation.install(MotionBlurTweener);
			
			const cube1:CubeView = new CubeView(new Cube());
			const cube2:CubeView = new CubeView(new Cube());
			const cube3:CubeView = new CubeView(new Cube());
			
			const animation:Animation = new Animation()
				.target(cube1, cube2, cube3)
				.to( { x: 300, y:300, motionBlur: { scale: 2} } )
				//.to( { x: 300, y:300 } )
				.delay(0.5)
				.duration(1)
				.postDelay(1.5)
				.started(function():void { trace('started'); } )
				.completed(function():void { trace('completed'); } )
				//.ease(Ease.linear)
				.yoyo(true)
				//.repeat(1)
				.pause()
				
				
			cube1.x = 200;
			cube1.y = 200;
			cube2.x = 500;
			cube2.y = 400;
			cube3.x = 300;
			cube3.y = 600;
				
			addChild(cube1);
			addChild(cube2);
			addChild(cube3);
			
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
				animation.pause().progress(progress);
			})
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
				animation.toggle();
				//animation.next();
			})
		}
		
	}

}