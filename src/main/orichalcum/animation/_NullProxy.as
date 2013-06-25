package orichalcum.animation 
{

	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
 
	dynamic public class _NullProxy extends Proxy
	{
		
		override flash_proxy function setProperty(name:*, value:*):void {  }
		
		override flash_proxy function getProperty(name:*):* { return undefined; }
		
		override flash_proxy function callProperty(name:*, ...rest):* { return this[name].apply(null, rest); }
		
		override flash_proxy function hasProperty(name:*):Boolean { return false; }
		
		override flash_proxy function deleteProperty(name:*):Boolean { return false; }
		
		override flash_proxy function nextNameIndex(index:int):int { return int.MIN_VALUE }
		
		override flash_proxy function nextName(index:int):String { return null; }
		
		override flash_proxy function nextValue(index:int):* { return undefined; }
		
		override flash_proxy function getDescendants(name:*):* { return undefined; }
		
		override flash_proxy function isAttribute(name:*):Boolean { return false; }
		
	}

}