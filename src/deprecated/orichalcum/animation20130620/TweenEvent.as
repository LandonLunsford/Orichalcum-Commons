package orichalcum.animation 
{
	import flash.events.Event;

	public class TweenEvent extends Event 
	{
		
		static public const YOYO:String = 'yoyo';
		
		public function TweenEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new TweenEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("TweenEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}