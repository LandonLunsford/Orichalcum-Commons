package orichalcum.utility 
{
	public class ObjectUtil
	{
		
		/**
		 * @param	child Object to which the parents attributes will be given
		 * @param	parent Object from which the child will inherit attributes
		 * @return	the modified child object
		 */
		static public function extend(child:Object, parent:Object):Object
		{
			var attribute:String;
			if (isDynamic(child))
			{
				for (attribute in parent)
					if (child[attribute] == undefined)
						child[attribute] = parent[attribute];
			}
			else
			{
				for (attribute in parent)
					if (attribute in child && child[attribute] == undefined)
						child[attribute] = parent[attribute];
			}
			return child;
		}
		
		/**
		 * @param	child Object to which the parents attributes will be given
		 * @param	parent Object from which the child will inherit attributes
		 * @return	the modified child object
		 */
		static public function inherit(child:Object, parent:Object):Object
		{
			var attribute:String;
			if (isDynamic(child))
			{
				for (attribute in parent)
					child[attribute] = parent[attribute];
			}
			else
			{
				for (attribute in parent)
					if (attribute in child)
						child[attribute] = parent[attribute];
			}
			return child;
		}
		
		
		static public function swap(object1:Object, object2:Object):Object
		{
			/**
			 * If proxy is not used the properties of object1 will be iterated over twice
			 * this is due to the set operation of the property
			 */
			const proxy:Object = clone(object1);
			for (var property:String in proxy)
			{
				
				if (property in object2)
				{
					var temp:* = object1[property];
					object1[property] = object2[property];
					object2[property] = temp;
				}
			}
			return object1;
		}
		
		/**
		 * @param	object The target for property removal
		 * @return	object The modified object
		 */
		static public function empty(object:Object):Object
		{
			for (var property:String in object)
				delete object[property];
			return object;
		}
		
		/**
		 * @param	object The target for reference removal
		 * @return	object The modified object
		 */
		static public function clean(object:Object):Object
		{
			for (var property:String in object)
				object[property] = undefined;
			return object;
		}
		
		/**
		 * @param	object The target to test
		 * @return	true if object is an instance of a dynamic class
		 */
		static public function isDynamic(object:Object):Boolean
		{
			try
			{
				object.poop;
			}
			catch (error:Error)
			{
				return false;
			}
			return true;
		}
		
		/**
		 * Creates a new object of the specified class
		 * @param	type Class to be instantiated
		 * @param	parameters Dependencies to passed into the objects constructor
		 * @param	properties Map of properties and values which will be set in the new object
		 * @return	New object of indicated type
		 */
		static public function create(type:Class, parameters:Array = null):Object
		{
			if (!type) throw new ArgumentError('Parameter "type" must not be null');

			if (parameters)
			{
				switch(parameters.length)
				{
					case 1:	return new type(parameters[0]);
					case 2: return new type(parameters[0], parameters[1]);
					case 3: return new type(parameters[0], parameters[1], parameters[2]);
					case 4: return new type(parameters[0], parameters[1], parameters[2], parameters[3]);
					case 5: return new type(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]);
					case 6: return new type(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5]);
					case 7: return new type(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6]);
					case 8: return new type(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7]);
					case 9:	return new type(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8]);
					case 10:return new type(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8], parameters[9]);
				}
			}
			return new type();
		}
		
		static public function clone(object:Object):Object
		{
			const clone:Object = {};
			for (var property:String in object)
				clone[property] = object[property];
			return clone;
		}
		
		/**
		 * Sets the object's properties to the corresponding value found in the properties param
		 * @param	object The object whose properties will be modified
		 * @param	properties The property:value map used whose values are placed in the object
		 * @return	The param 'object' whose properties were modified
		 */
		static public function initialize(object:Object, properties:Object):Object
		{
			if (isDynamic(object))
			{
				for (var property:String in properties)
				{
					object[property] = properties[property];
				}
			}
			else
			{
				for (property in properties)
				{
					if (property in object)
					{
						object[property] = properties[property];
					}
				}
			}
			
			return object;
		}
		
	}

}