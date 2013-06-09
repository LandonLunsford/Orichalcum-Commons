package orichalcum.animation.sequence 
{
	import orichalcum.animation.IPlayable;

	/**
	 * AKA Command Chain
	 */
	public interface ISequence extends IPlayable
	{
		//////////////////////////////////////////////////////////////////
		// BUILDING METHODS
		//////////////////////////////////////////////////////////////////
		
		function add(playable:IPlayable):ISequence;
		
		function wait(duration:Number, useFrames:Boolean = false):ISequence;
		
		function call(...args):ISequence;
		
		//function to(...args):ISequence;
		
		
	}

}