package orichalcum.signals
{
	
	import orichalcum.lifecycle.IDisposable;

	/**
	 * Cannot stop immediate propogation without removing listeners
	 */
	public interface ISignal extends IDisposable
	{
		function get totalListeners():int;
		function get hasListeners():Boolean
		function hasListener(callback:Function):Boolean
		function addListener(callback:Function):ISignalListener
		function removeListener(callback:Function):void
		function removeListeners():void
		function dispatch(...values):void
	}
	
}
