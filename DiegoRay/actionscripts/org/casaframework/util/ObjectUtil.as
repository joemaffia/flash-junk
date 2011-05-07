/*
	CASA Framework for ActionScript 2.0
	Copyright (C) 2007  CASA Framework
	http://casaframework.org
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

import org.casaframework.util.TypeUtil;

/**
	@author Aaron Clinger
	@author David Nelson
	@version 04/04/07
*/

class org.casaframework.util.ObjectUtil {
	
	/**
		Searches the first level properties of an object for a another object.
		
		@param obj: Object to search in.
		@param member: Object to search for.
		@return Returns <code>true</code> if object was found; otherwise <code>false</code>.
	*/
	public static function contains(obj:Object, member:Object):Boolean {
		for (var prop:String in obj)
			if (obj[prop] == member)
				return true;
		
		return false;
	}
	
	/**
		Makes a clone of the original Object.
		
		@param obj: Object to make the clone of.
		@return Returns a duplicate Object.
	*/
	public static function clone(obj:Object):Object {
		var cloneObj:Object = new (Function(obj.__proto__.constructor))();
		
		for (var prop:String in obj) {
			switch (TypeUtil.getTypeOf(obj[prop])) {
				case 'array' :
					cloneObj[prop] = obj[prop].slice();
					break;
				case 'object' :
					cloneObj[prop] = ObjectUtil.clone(obj[prop]);
					break;
				default :
					cloneObj[prop] = obj[prop];
					break;
			}
		}
		
		return cloneObj;
	}
	
	/**
		Uses the strict equality operator to determine if object is <code>undefined</code>.
		
		@param obj: Object to determine if <code>undefined</code>.
		@return Returns <code>true</code> if object is <code>undefined</code>; otherwise <code>false</code>.
	*/
	public static function isUndefined(obj:Object):Boolean {
		return obj === undefined;
	}
	
	/**
		Uses the strict equality operator to determine if object is <code>null</code>.
		
		@param obj: Object to determine if <code>null</code>.
		@return Returns <code>true</code> if object is <code>null</code>; otherwise <code>false</code>.
	*/
	public static function isNull(obj:Object):Boolean {
		return obj === null;
	}
	
	/**
		Determines if object contains no value(s).
		
		@param obj: Object to derimine if empty.
		@return Returns <code>true</code> if object is empty; otherwise <code>false</code>.
		@usage
			<code>
				var testArray:Array   = new Array();
				var testString:String = '';
				var testObject:Object = new Object();
				
				trace(ObjectUtil.isEmpty(testArray));  // traces "true"
				trace(ObjectUtil.isEmpty(testObject)); // traces "true"
				trace(ObjectUtil.isEmpty(testString)); // traces "true"
			</code>
	*/
	public static function isEmpty(obj:Object):Boolean {
		if (obj == undefined)
			return true;
		
		switch (TypeUtil.getTypeOf(obj)) {
			case 'string' :
			case 'array' :
				return (obj.length == 0) ? true : false;
				break;
			case 'object' :
				for (var prop:String in obj)
					return true;
				break;
		}
		
		return false;
	}
	
	private function ObjectUtil() {} // Prevents instance creation
}