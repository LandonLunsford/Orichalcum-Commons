package orichalcum.animation
{

	public interface IAnimation
	{
	
		///////////////////////////////////////////////
		// Repurposing
		///////////////////////////////////////////////
		
		// can be null and delegated to sub tweens
		function get target():Object;
		function set target(value:Object):void;
		
		///////////////////////////////////////////////
		// Information
		///////////////////////////////////////////////
		
		/**
		 * for parent child timelines to work each IAnimation needs the following	
		 */
		
		// where duration will be the sum of sub durations for timeline
		// to set you would find the ratio change and modify all durations accordingly
		
		function get duration():Number;
		function set duration(value:Number):void;
		
		function get position():Number;
		function set position(value:Number):void;
		
		function get progress():Number;
		function set progress(value:Number):void;
		
		function get useFrames():Boolean;
		function set useFrames(value:Boolean):void;
		
		function get isPlaying():Boolean;
		
		function get isPaused():Boolean;
		
		// function get ease():Function // I could have an overarching ease that defaults linear ( : J
		
		///////////////////////////////////////////////
		// Creation
		///////////////////////////////////////////////
		
		function add(animation:IAnimation):IAnimation;
		function animate(target:Object):IAnimation;
		function to(...args):IAnimation;
		function from(...args):IAnimation;
		function delay(duration:Number, useFrames:Boolean = false):IAnimation;
		function call(callback:Function, ...args):IAnimation;
		//function init(callback:Function, ...args):IAnimation;
		//function change(callback:Function, ...args):IAnimation;
		//function yoyo(callback:Function, ...args):IAnimation;
		function complete(callback:Function, ...args):IAnimation;
		//function clone():IAnimation; // out of scope for now
		
		///////////////////////////////////////////////
		// Control
		///////////////////////////////////////////////
		
		function play():IAnimation;
		function pause():IAnimation;
		function toggle(flag:Boolean):IAnimation;
		function stop():IAnimation;
		function replay():IAnimation;
		function goto(position:Number):IAnimation;
		function rewind():IAnimation;
		function end(triggerCallbacks:Boolean = true):IAnimation;
	
	}

}
