package orichalcum.signals
{
	
	import orichalcum.lifecycle.IDisposable;

	/**
	 * Drawbacks:
	 * Cannot stop immediate propogation without removing listeners
	 */
	public interface ISignal extends IDisposable
	{
		
		function get listenerArgumentClasses():Vector.<Class>;
		
		function get totalListeners():int;
		
		function get hasListeners():Boolean;
		
		function has(callback:Function):Boolean;
		
		function add(callback:Function):void;
		
		function remove(callback:Function):void;
		
		function removeAll():void;
		
		function dispatch(...values):void;
		
	}
	
}
