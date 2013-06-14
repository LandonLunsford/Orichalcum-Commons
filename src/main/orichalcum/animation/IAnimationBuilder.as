package orichalcum.animation 
{

	public interface IAnimationBuilder extends IAnimation
	{
		
		function add(animation:IAnimation):IAnimationBuilder;
		function animate(target:Object):IAnimationBuilder;
		function to(...args):IAnimationBuilder;
		function from(...args):IAnimationBuilder;
		function delay(duration:Number, useFrames:Boolean = false):IAnimationBuilder;
		function call(callback:Function, ...args):IAnimationBuilder;
		
	}

}
