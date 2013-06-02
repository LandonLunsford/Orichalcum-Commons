package orichalcum.animation
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	public class TweenDemo extends Sprite
	{
		
		private const isRounded:RegExp = /\[\]/;
		private const isPlus:RegExp = /\+/;
		private const isMinus:RegExp = /\-/;
		private const stripper:RegExp = /(\+|\[|\]|\s)*/mg;
		private const extractor:RegExp = /[-+]?[0-9]*\.?[0-9]+/;
		
		/**
		 * Add and relative are different
		 * add will end up with the final destination correct
		 * relative needs to take in the targets current value and add it to initial to[value]
		 */
		public function TweenDemo() 
		{
			const t:Shape = new Shape;
			t.graphics.beginFill(0xffffff * Math.random())
			t.graphics.drawCircle(0, 0, 200);
			t.graphics.endFill();
			addChild(t);
			
			t.x = stage.stageWidth * 0.5
			t.y = stage.stageHeight * 0.5
			
			const eventTracer:Function = function(event:Event):void { trace(event.type, '\t\t', event.target.target.y); };
			const callbackTracer:Function = function(jump:Boolean):void { trace(jump, '\t\t', this.target.y); };
			
			//const tween:Tween = new Tween(
			const tween:Tween = Tween.to(
				t,
				0,
				{
					delay: 1
					,
					duration: 2
					//,useFrames: true
					,repeats: 2
					,yoyo:true
					,y: '[-200]'
					,dispatchEvents: true
					,onInit: callbackTracer
				}
			);
			tween.addEventListener(Event.INIT, eventTracer)
			//tween.addEventListener(Event.CHANGE, eventTracer)
			tween.addEventListener(Event.COMPLETE, eventTracer)
			tween.addEventListener('yoyo', eventTracer)
			
			
			stage.addEventListener(MouseEvent.CLICK, function(event:Event):void { tween.toggle() } );
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):void
			{
				event.keyCode == Keyboard.LEFT && tween.setPosition(tween.position - 0.1, false);
				event.keyCode == Keyboard.RIGHT && tween.setPosition(tween.position + 0.1, false);
				event.keyCode == Keyboard.DOWN && tween.playReverse(false);
			});
			
			//new Tween(
				//t,
				//0,
				//{
					//delay: 1
					//,duration: 2
					//,y: '[-100]'
				//}
			//);
			
			/**
			 * y: 30
			 * y: '-30' // add or subtract
			 * y: '[40]' or '[-40]'
			 */
			//var test:RegExp = extractor;
			//trace(test.test('[4]'));
			//trace(test.test('[+4]'));
			//trace(test.test('[-4]'));
			//trace(test.test('[4.1]'));
			//trace(test.test('[4.0]'));
			//trace(test.test(' [4.0] '));
			//trace(test.test(' [ 4.0 ] '));
			//
			//trace(('[4]').replace(stripper, ''));
			//trace(('[+4]').replace(stripper, ''));
			//trace(('[-4]').replace(stripper, ''));
			//trace(('[4.1]').replace(stripper, ''));
			//trace(('[4.0]').replace(stripper, ''));
			//trace((' [4.0] ').replace(stripper, ''));
			//trace((' [ 4.0 ] ').replace(stripper, ''));
			//
			//trace(parseFloat(test.exec('[4]')));
			//trace(parseFloat(test.exec('[+4]')));
			//trace(parseFloat(test.exec('[-4]')));
			//trace(parseFloat(test.exec('[4.1]')));
			//trace(parseFloat(test.exec('[4.0]')));
			//trace(parseFloat(test.exec(' [4.0] ')));
			//trace(parseFloat(test.exec(' [ 4.0 ] ')));
		}
		
	}

}