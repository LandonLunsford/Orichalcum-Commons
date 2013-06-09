package orichalcum.animation 
{

	public interface IPlayable 
	{
		
		//////////////////////////////////////////////////////////////////
		// CONTROL METHODS
		//////////////////////////////////////////////////////////////////
		
		// need to save these to fire on end()
		function play(onComplete:Function = null, ...args):IPlayable;
		
		function replay():IPlayable;
		
		function pause():IPlayable;
		
		function stop():IPlayable;
		
		function toggle():IPlayable;
		
		function end(supressCallbacks:Boolean = false):IPlayable;
	}

}