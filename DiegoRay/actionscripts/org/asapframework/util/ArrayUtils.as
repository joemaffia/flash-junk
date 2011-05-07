/*
Copyright 2005-2006 by the authors of asapframework

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


/**
A collection of Array utility functions.
@author Martijn de Visser
@author Arthur Clemens
*/

class org.asapframework.util.ArrayUtils {

	/**
	Searches array for an element with a specific value.
	@param inList: array to perform search on.
	@param inValue: (generically typed) value to search for in List elements.
	@return The index of the found element; -1 if not found.
	*/
	public static function findElement( inList:Array, inValue:Object ) : Number {

		for (var i:Number=0; i<inList.length; ++i) {

			if (inList[i] == inValue) {

				return i;
				break;
			}
		}
		return -1;
	}

	/**
	Searches array for an element with a specific value.
	@param inList: array to perform search on.
	@param inValue: (generically typed) value to search for in List elements.
	@return Boolean indicating successfull removal.
	*/
	public static function removeElement( inList:Array, inValue:Object ) : Boolean {

		for (var i:Number=0; i<inList.length; ++i) {

			if (inList[i] == inValue) {

				inList.splice(i, 1);
				return true;
				break;
			}
		}
		return false;
	}

	/**
	Inserts an element in an array at the specified position. Fails if position is out of bounds.
	@param inList: array to perform insertion on.
	@param inPosition: the position to insert element at (zero-based).
	@param inValue: (generically typed) element to insert.
	@return Boolean indicating successfull insertion.
	*/
	public static function insertElementAt( inList:Array, inPosition:Number, inValue:Object ) : Boolean {

		// valid position?
		if (inPosition > inList.length || inPosition < 0) {

			return false;

		} else {

			if (inPosition == inList.length) {

				// position is same as length, push it
				inList.push(inValue);

			} else if (inPosition == 0) {

				if (inList.length == 0) {

					// add at start
					inList.push(inValue);

				} else {

					// add at end
					inList.unshift(inValue);
				}

			} else {

				// add at position specified
				inList.splice(inPosition,0,inValue);
			}

			return true;
		}
	}

	/**
	Searches array of objects for an object with a specific property, also checks if the property has the correct value (if specified in "value"). Pass the start value if you want this function to begin searching at a specific index
	@param inList: array to perform search on.
	@param inProp: the object property to search for
	@param inValue: (generically typed) value to test the contents of found Prop against.
	@param inStart: index position to start the search from
	@return Index position of the found element; -1 if not found.
	*/
	public static function findProperty (inList:Array,
										 inProp:String,
										 inValue:Object,
										 inStart:Number) : Number {

		var start:Number = (inStart != undefined) ? inStart : 0;
		if (start > inList.length-1) return -1;

		// loop array
		for (var i:Number=start; i<inList.length; ++i) {

			if (inValue != undefined) {

				if ( inList[i][inProp] == inValue ) {

					return i;
					break;
				}

			} else {

				if ( inList[i] == inProp ) {

					return i;
					break;
				}
			}
		}
		return -1;
	}
	
	/**
	Randomizes an array. Performs the operation directly on the passed array, so does not return a new array.
	@param inList: the array to randomize
	@implementationNote See http://proto.layer51.com/d.aspx?f=147
	@example
	<code>
	ArrayUtils.randomize(myList);
	var o:Object = myList[0];
	// etcetera
	</code>
	*/
	public static function randomize (inList:Array) : Void {
	
		var len:Number = inList.length;
		var i:Number = len;
		var p:Number;
		var o:Object;
		while (i--) {
			p = random(len); // more correct, but slower: Math.floor(Math.random() * len);
			o = inList[i];
			inList[i] = inList[p];
			inList[p] = o;
		}
	}
	
	/**
	Copies an array.
	@param inList: the array to copy
	@example
	<code>
	var myCopyList:Array = ArrayUtils.copy(myOriginalList);
	</code>
	*/
	public static function copy (inList:Array) : Array {
		var newArray:Array = new Array();
		var i:Number = inList.length;
		while (i--) {
			newArray[i] = inList[i];
		}
		return newArray;
	}
}
