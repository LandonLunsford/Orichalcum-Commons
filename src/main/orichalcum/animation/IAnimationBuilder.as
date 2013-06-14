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
		
		/**
		 * AnimationBuilder implements IAnimationBuilder,
		 * All IAnimationMethods will invoke .create() and delegate call to creation
		 * Because create() locks out modification after that point I can cache all the final duration
		 * values etc for high performing animations that are not modifiable maybe
		 */
	}

}
