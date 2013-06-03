package orichalcum.animation
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	public class ContinuousTweenDemo extends Sprite
	{
		
		public function ContinuousTweenDemo() 
		{
			const target:Shape = new Shape;
			target.graphics.beginFill(0xffffff * Math.random());
			target.graphics.drawCircle(0, 0, 100);
			target.graphics.endFill();
			addChild(target);
			
			target.x = stage.stageWidth * 0.5;
			target.y = stage.stageHeight * 0.5;
			
			
			//const tween:Tween = new Tween(
			const tween:Tween = Tween.to(
				target,
				0,
				{
					duration: 1
				}
			);
			
			stage.addEventListener(MouseEvent.CLICK, function(event:Event):void { tween.to( {target:target, x:stage.mouseX, y:stage.mouseY } ); } );
			
			
		}
		
	}

}