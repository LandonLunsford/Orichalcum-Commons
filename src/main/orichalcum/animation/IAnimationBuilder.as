package orichalcum.animation 
{

	/**
	 * animate([target])
	 * 	.target(this)
	 * 	.delay(1)
	 * 	.duration(2)
	 * 	.to({}) // dynamic start
	 * 	.from({}) // dynamic end
	 * 	.from({}).to({}) // set start and end
	 * 	.in(100)
	 * 	.yoyo() // set yoyo true
	 * 	.useFrames() // set use frames true
	 * 	.timeScale(2) // set 2x playspeed
	 * 	.
	 */
	public interface IAnimation //extends IAnimation
	{
		/**
		 * 
		 * @param	value Object|Array.<Object>|Vector.<Object> of targets whose properties you wish to animate
		 * @return
		 */
		function target(value:Object):IAnimation;
		
		/**
		 * 
		 * @param	time duration in seconds or frames that the animation will wait before starting after play() is called
		 * @return
		 */
		function delay(time:Number):IAnimation;
		
		/**
		 * 
		 * @param	time duration of one animation iteration, or if animation "yoyos" then the duration of one forward and backward revolution
		 * @return
		 */
		function duration(time:Number):IAnimation;
		
		/**
		 * 
		 * @param	value A function of , which dictates the value of the target properties over the tweens duration. The default is Ease.quadOut.
		 * @return
		 */
		function ease(value:Function):IAnimation;
		
		/**
		 * @TODO set _initialized = false
		 * @param	values a map of property names and target property values to tween the target to
		 * @return
		 */
		function to(values:Object):IAnimation;
		
		/**
		 * @TODO set _initialized = false
		 * @param	values a map of property names and target property values to tween the target from
		 * @return
		 */
		function from(values:Object):IAnimation;
		
		/**
		 * 
		 * @param	value the number of times the animation will repeat before finishing, the default is one. If set to -1 the animation will loop forever
		 * @return
		 */
		function times(value:int):IAnimation;
		
		/**
		 * Configures the animation to flip direction once it reaches the end and return to the beginning in one iteration
		 * @return
		 */
		function yoyo():IAnimation;
		
		/**
		 * Configures the animation to use frames instead of seconds for delay and duration
		 * @return
		 */
		function useFrames():IAnimation;
		
		/**
		 * Sets the timeScale of the tween. If the duration is 2 and the timeScale is 2 the animation will complete in 1 second. Likewise, if the timeScale is 0.5 the animation will complete in 4 seconds.
		 * @param	value Time step multiplier
		 * @return
		 */
		function timeScale(value:Number):IAnimation;
		
		/**
		 * 
		 * @param	value
		 * @return
		 */
		function onInit(value:Function):IAnimation;
		
		/**
		 * 
		 * @param	value
		 * @return
		 */
		function onChange(value:Function):IAnimation;
		
		/**
		 * 
		 * @param	value
		 * @return
		 */
		function onYoyo(value:Function):IAnimation;
		
		/**
		 * 
		 * @param	value
		 * @return
		 */
		function onComplete(value:Function):IAnimation;
		
		/**
		 * Creates a clone of the current animation for extension
		 * @return clone of the animation
		 */
		function clone():IAnimation;
		
		// weakness because I need both getter and setter
		function get position():Number;
		function set position(value:Number):void;
		function get progress():Number;
		function set progress(value:Number):void;
		
		function get isPlayingForward():Boolean;
		function get isPlayingBackward():Boolean;
		function get isPlaying():Boolean;
		function get isPaused():Boolean;
		
		function goto(position:Number, supressCallbacks:Boolean = false):IAnimation;
		function gotoAndPlay(position:Number, supressCallbacks:Boolean = false):IAnimation;
		function gotoAndStop(position:Number, supressCallbacks:Boolean = false):IAnimation;
		function play():IAnimation;
		function stop():IAnimation;
		function toggle():IAnimation;
		function reset(supressCallbacks:Boolean = false):IAnimation;
		function replay(supressCallbacks:Boolean = false):IAnimation;
		function end(supressCallbacks:Boolean = false):IAnimation;
		function reverse():IAnimation;
		function playBackwards(supressCallbacks:Boolean = false):IAnimation;
		
		
	}

}