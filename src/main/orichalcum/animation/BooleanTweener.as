package orichalcum.animation 
{
	import adobe.utils.CustomActions;
	import orichalcum.utility.StringUtil;

	internal class BooleanTweener implements ITweener
	{
		public var end:Boolean;
		private var _previousValue:Boolean;
		
		public function BooleanTweener(end:Boolean = false) 
		{
			this.end = end;
			trace(this);
		}
		
		/**
		 * For a boolean tween this is easy just return the setter value when
		 */
		public function tween(target:Object, property:String, progress:Number):void
		{
			target[property] = progress < 1 ? target[property] : end;
			
			trace(progress, target[property], end);
		}
		
		public function toString():String
		{
			return StringUtil.substitute('<boolean-tweener name="{0}" start="{1}" end="{2}">', '?', '?', end);
		}
	}

}