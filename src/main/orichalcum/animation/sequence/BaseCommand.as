package orichalcum.animation.sequence 
{
	import orichalcum.animation.IPlayable;

	internal class BaseCommand implements IPlayable
	{

		/* INTERFACE orichalcum.animation.IPlayable */
		
		public function play(onComplete:Function = null, ...args):IPlayable 
		{
			return this;
		}
		
		public function replay():IPlayable 
		{
			return this;
		}
		
		public function pause():IPlayable 
		{
			return this;
		}
		
		public function stop():IPlayable 
		{
			return this;
		}
		
		public function toggle():IPlayable 
		{
			return this;
		}
		
		public function end(supressCallbacks:Boolean = false):IPlayable 
		{
			return this;
		}
		
	}

}