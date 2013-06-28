package orichalcum.animation.tweener 
{

	public interface ITweener 
	{
		/**
		 * Initialize the flyweight target property tweener
		 * This function is called at tween creation and modification time
		 * @param	start The initial value of the target's property
		 * @param	end	The final value desired for the target's property
		 */
		function init(start:*, end:*):void;
		
		/**
		 * Interpolates the targets property based on the following parameters
		 * This function is called every frame in which the tween is playing
		 * @param	target The object whose property is being tweened
		 * @param	property The property name of the target object
		 * @param	progress A number between 0 and 1 representing the current progress along one iteration of the tween
		 * @param	isStart Flag indicating that the current tween iteration has begun
		 * @param	isEnd Flag indicating that the current tween iteration has is complete
		 * @return the tweened value of the target's property
		 */
		function tween(target:Object, property:String, progress:Number):*;
		
	}

}
