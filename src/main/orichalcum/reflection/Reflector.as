package orichalcum.reflection
{
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import orichalcum.lifecycle.IDisposable;
	import orichalcum.system.FlashPlayer;
	import orichalcum.utility.StringUtil;

	public class Reflector implements IDisposable, IReflector
	{
		static private var _instance:Reflector;
		private var _applicationDomain:ApplicationDomain;
		private var _typeDescriptions:Dictionary;
		private var _describeTypeRequiresSacrifice:Boolean;
		private var _nativeTypes:RegExp = /^air\.|^fl\.|^flash\.|^flashx\.|^spark\.|^mx\.|^Object$|^Class$|^String$|^Function$|^Array$|^Boolean$|^Number$|^uint$|^int$/;
		private var _primitiveTypes:RegExp = /^Object$|^Class$|^String$|^Function$|^Array$|^Boolean$|^Number$|^uint$|^int/;
		
		static public function getInstance(applicationDomain:ApplicationDomain = null):IReflector
		{
			return _instance ||= new Reflector(applicationDomain);
		}
		
		public function Reflector(applicationDomain:ApplicationDomain = null)
		{
			_applicationDomain = applicationDomain || ApplicationDomain.currentDomain;
			_typeDescriptions = new Dictionary;
			_describeTypeRequiresSacrifice = FlashPlayer.getInstance().version < 10.1;
		}
		
		/* INTERFACE orichalcum.lifecycle.IDisposable */
		
		public function dispose():void
		{
			_applicationDomain = null;
			_typeDescriptions = null;
			_nativeTypes = null;
			_primitiveTypes = null;
			this === _instance && (_instance = null);
		}
		
		/* INTERFACE orichalcum.reflection.IReflector */
		
		public function isNativeType(qualifiedClassName:String):Boolean
		{
			return _nativeTypes.test(qualifiedClassName);
		}
		
		public function isPrimitiveType(qualifiedClassName:String):Boolean
		{
			return _primitiveTypes.test(qualifiedClassName);
		}
		
		public function isComplexType(qualifiedClassName:String):Boolean
		{
			return !isPrimitiveType(qualifiedClassName);
		}
		
		public function isType(qualifiedClassName:String):Boolean
		{
			return _applicationDomain.hasDefinition(qualifiedClassName);
		}
		
		public function getType(qualifiedClassName:String):Class
		{
			return _applicationDomain.getDefinition(qualifiedClassName) as Class;
		}
		
		public function getTypeName(classOrInstance:*):String
		{
			return getQualifiedClassName(classOrInstance);
		}
		
		public function getTypeDescription(classOrInstance:*):XML
		{
			const qualifiedClassName:String = getQualifiedClassName(classOrInstance);
			return _typeDescriptions[qualifiedClassName] ||= safelyDescribeType(classOrInstance, qualifiedClassName);
		}
		
		public function isPrimitive(value:*):Boolean
		{
			return value is int || value is uint || value is Number || value is Boolean || value is String;
		}
		
		/**
		 * In FlashPlayers before 10.1 wildcard (*) constructor parameters
		 * Are not correctly described before an instance is first instantiated
		 * This method is a means of avoiding the bug.
		 */
		private function safelyDescribeType(classOrInstance:*, qualifiedClassName:String):XML
		{
			_describeTypeRequiresSacrifice && create(getType(qualifiedClassName));
			return describeType(classOrInstance);
		}
		
		private function create(type:Class):void
		{
			if (type == null)
				throw new ArgumentError('Argument "type" passed to method "create" must not be null.');
			
			try
			{
				switch(describeType(type).factory.constructor.parameter.length())
				{
					case 0: new type; break;
					case 1: new type(null); break;
					case 2: new type(null, null); break;
					case 3: new type(null, null, null); break;
					case 4: new type(null, null, null, null); break;
					case 5: new type(null, null, null, null, null); break;
					case 6: new type(null, null, null, null, null, null); break;
					case 7: new type(null, null, null, null, null, null, null); break;
					case 8: new type(null, null, null, null, null, null, null, null); break;
					case 9: new type(null, null, null, null, null, null, null, null, null); break;
					case 10: new type(null, null, null, null, null, null, null, null, null, null); break;
					case 11: new type(null, null, null, null, null, null, null, null, null, null, null); break;
					case 12: new type(null, null, null, null, null, null, null, null, null, null, null, null); break;
					case 13: new type(null, null, null, null, null, null, null, null, null, null, null, null, null); break;
					case 14: new type(null, null, null, null, null, null, null, null, null, null, null, null, null, null); break;
					case 15: new type(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null); break;
					throw new ArgumentError(StringUtil.substitute('Type "{0}" requires over {1} constructor arguments. Consider refactoring.', getTypeName(type), 16));
				}
			}
			catch (error:Error)
			{
				
			}
		}
		
	}

}
