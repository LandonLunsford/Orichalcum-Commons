package orichalcum.signals
{
	
	import orichalcum.lifecycle.IDisposable;

	public interface ISignal extends IDisposable
	{
	
		function hasListeners():Boolean
		function hasListener(callback:Function):Boolean
		function addListener(callback:Function):ISignalListener
		function removeListener(callback:Function):void
		function removeListeners():void
		function dispatch():void
		
	}
	
}
