package orichalcum.animation.sequence 
{
	import orichalcum.animation.Tween;


	internal class FromCommand extends CallCommand
	{
		
		public function FromCommand(...args) 
		{
			super(function() {
				Tween.from.apply(null, args);
			});
		}
	}

}