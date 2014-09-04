package orichalcum.animation
{
	import flash.display.Sprite;
	import rolypoly.model.Cube;
	import rolypoly.view.CubeView;

	public class AnimationDemo extends Sprite
	{
		
		//private var animation:Animation = new Animation()
			//.onComplete(function():void { trace('complete'); })
		
		public function AnimationDemo() 
		{
			const cubeView:CubeView = new CubeView(new Cube());
			
			const animation:Animation = new Animation()
				.target(cubeView)
				//.from( { x: 100, y: 100 } )
				.to( { x: 100, y:200 } )
				.onComplete(function():void { trace(' on complete '); } )
				.duration(0.0000)
				//.delay(2)
				//.yoyo(true)
				//.postDelay(1)
			
			addChild(cubeView);
		}
		
	}

}