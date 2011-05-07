/*
Copyright 2005-2006 by the authors of asapframework, http://asapframework.org

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

import org.asapframework.data.Enumerator;

/**
Straightforward enumeration (iterator) class for arrays. ArrayEnumerator has one way of iterating: forward ({@link #getNextObject}). For more options see {@link TraverseArrayEnumerator}.
@author Arthur Clemens
*/

class org.asapframework.data.array.ArrayEnumerator extends Enumerator {

	private var mArray:Array; /**< Pointer to external array. */
	private var mLocation:Number;

	/**
	Creates a new array enumerator. Optionally stores a pointer to array inArray.
	@param inArray : (optional) the array to enumerate
	*/
	public function ArrayEnumerator (inArray:Array) {
		super();
		if (inArray != undefined) {
			mArray = inArray;
			reset();
		}
	}
	
	/**
	Stores a pointer to array inArray.
	@param inArray : the array to enumerate
	*/
	public function setArray (inArray:Array) : Void {
		mArray = inArray;
		reset();
	}
	
	/**
	Retrieves the object from the array at the current pointer location.
	@return (Deliberately untyped) The object from the array at the current pointer location.
	*/
	public function getCurrentObject () {
		if (mLocation == -1) {
			return null;
		}
		return mArray[mLocation];
	}
	
	/**
	Increments the location pointer by one and returns the object from the array at that location.
	@return (Deliberately untyped) The object at the new location. Returns null if the location pointer has moved past the end of the array.
	@implementationNote Calls {@link #update}.
	*/
	public function getNextObject () {
		if (mLocation < mArray.length) {
			return update(mLocation + 1);
		}
		return null;
	}
	
	/**
	Sets the location pointer to a new position.
	@param inLocation : the new pointer location
	@implementationNote Calls {@link #update}.
	*/
	public function setCurrentLocation (inLocation:Number) : Void {
		update(inLocation);
	}
	
	/**
	Sets the location pointer to the location (in the array) of inObject.
	@param inObject : the object whose index the location pointer should point to
	@implementationNote Calls {@link #update}.
	*/
	public function setCurrentObject (inObject:Object) : Void {
		var index:Number = findLocationForObject(inObject);
		if (index != -1) {
			update(index);
		}
	}
	
	/**
	Retrieves all objects.
	@return The array as set in the constructor or in {@link #setArray}.
	*/
	public function getAllObjects () : Array {
		return mArray;
	}
	
	/**
	Puts the enumerator just before the first array item. At this point calling {@link #getCurrentObject} will generate an error; you must first move the enumerator using {@link #getNextObject}.
	@implementationNote Calls {@link #update}.	
	*/
	public function reset () : Void {
		update(-1);
	}
			
	/**
	@exclude
	*/
	public function toString () : String {
		return "ArrayEnumerator; array " + mArray;
	}
	
	// PRIVATE METHODS
	
	/**
	Updates the location pointer to a new index location.
	@param inLocation : the new index location
	@sends TraverseArrayEnumeratorEvent#UPDATE If the delegate validation method exists and only if the delegate method returns true.
	*/
	private function update (inLocation:Number) {
		mLocation = inLocation;
		return getCurrentObject();
	}
	
	/**
	Retrieves the array index location of item inObject.
	@param inObject : the object to be found
	@return The array index location of item inObject. Returns -1 when the object is not found.
	*/
	private function findLocationForObject (inObject:Object) : Number {
		var i:Number = mArray.length;
		while (i--) {
			if (mArray[i] == inObject) {
				return i;
			}
		}
		return -1;
	}
	
}