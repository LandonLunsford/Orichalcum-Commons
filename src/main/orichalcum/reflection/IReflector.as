package orichalcum.reflection 
{
	import orichalcum.lifecycle.IDisposable;
	
	public interface IReflector extends IDisposable
	{
		function isType(qualifiedClassName:String):Boolean;
		function isPrimitiveType(qualifiedClassName:String):Boolean;
		function isComplexType(qualifiedClassName:String):Boolean;
		function isNativeType(qualifiedClassName:String):Boolean;
		
		function getType(qualifiedClassName:String):Class;
		function getTypeName(classOrInstance:*):String;
		function getTypeDescription(type:Class):XML;
		
		//function implementsOrExtends(classOrInstanceA:*, superclassOrInterface:*):Boolean;
		//function getAncestors(type:Class, classNameFilter:RegExp = null):XMLList;
	}

}