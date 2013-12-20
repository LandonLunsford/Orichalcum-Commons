package orichalcum.signals
{

	public class Signal implements ISignal extends IDisposable
	{
	
		function hasListeners():Boolean
		function hasListener(callback:Function):Boolean
		function addListener(callback:Function):ISignalListener
		function removeListener(callback:Function):void
		function removeListeners():void
		function dispatch():void
		
	}
	
}
