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

/**
Class that contains a location in 3D space.
 */
 
class org.asapframework.util.types.Vector3D {
	public var x:Number;
	public var y:Number;
	public var z:Number;
	
	public function Vector3D (inX:Number, inY:Number, inZ:Number) {
		x = inX;
		y = inY;
		z = inZ;
	}
	
	/**-----------------------------------------------------------------------
	*	
	-------------------------------------------------------------------------*/
	public function equals (inV:Vector3D) : Boolean {
		return (inV.x == x) && (inV.y == y) && (inV.z == z);
	}
	
	/**-----------------------------------------------------------------------
	*	@return a new vector that is a copy of the vector this function is called on
	-------------------------------------------------------------------------*/
	public function copy () : Vector3D {
		return new Vector3D(x, y, z);
	}
	
	/**-----------------------------------------------------------------------
	*	Copies the current vector to the input vector
	-------------------------------------------------------------------------*/
	public function copyTo (inVec:Vector3D) : Void {
		inVec.x = x;
		inVec.y = y;
		inVec.z = z;
	}
	
	/**-----------------------------------------------------------------------
	*	
	-------------------------------------------------------------------------*/
	public function addVector (inVector:Vector3D) : Void {
		x += inVector.x;
		y += inVector.y;
		z += inVector.z;
	}
	
	/**-----------------------------------------------------------------------
	*	
	-------------------------------------------------------------------------*/
	public function subtract (inVector:Vector3D) : Void {
		x -= inVector.x;
		y -= inVector.y;
		z -= inVector.z;
	}
	
	/**-----------------------------------------------------------------------
	*	
	-------------------------------------------------------------------------*/
	public function mulScalar (inNum:Number) : Void {
		x *= inNum;
		y *= inNum;
		z *= inNum;
	}
	
	/**-----------------------------------------------------------------------
	*	
	-------------------------------------------------------------------------*/
	public function multiply (inVec:Vector3D) : Void {
		x *= inVec.x;
		y *= inVec.y;
		z *= inVec.z;
	}

	/**
	 * static function to add two vectors and return the value of the sum
	 * @return a new vector that is the sum of the two input vectors
	 */	
	public static function addVectors (inV1:Vector3D, inV2:Vector3D) : Vector3D {
		return new Vector3D(inV1.x + inV2.x, inV1.y + inV2.y, inV1.z + inV2.z);
	}
	
	public function toString() : String {
		return "[" + x + "," + y + "," + z + "]";
	}
}