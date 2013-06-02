package orichalcum.animation 
{
	import adobe.utils.CustomActions;
	import orichalcum.utility.StringUtil;

	internal class BooleanTweener implements ITweener
	{
		public var name:String
		public var start:Number;
		public var end:Number;
		
		public function BooleanTweener(name:String, start:Number, end:Number) 
		{
			this.name = name;
			this.start = start;
			this.end = end;
			
			trace(this);
		}
		
		/**
		 * For a boolean tween this is easy just return the setter value when
		 */
		public function tween(progress:Number, target:Object):void
		{
			target[name] = progress < 1 ? target[name] : end;
		}
		
		public function toString():String
		{
			return StringUtil.substitute('<boolean-tweener name="{0}" start="{1}" end="{2}">', name, start, end);
		}
	}

}