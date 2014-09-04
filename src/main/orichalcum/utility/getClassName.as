package orichalcum.utility 
{
	import flash.utils.getQualifiedClassName;

	public function getClassName(value:*):String
	{
		const qualifiedClassNameParts:Array = getQualifiedClassName(value).split('::');
		return qualifiedClassNameParts[qualifiedClassNameParts.length - 1];
	}

}