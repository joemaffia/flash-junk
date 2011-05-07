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

import org.asapframework.util.actionqueue.ActionQueuePerformData;
import org.asapframework.util.types.I3DObject;
import org.asapframework.util.types.Vector3D;

/**
Class for simple (linear) animation of objects in 3D space
 */
 
class org.asapframework.util.actionqueue.AQ3D {
	/**-----------------------------------------------------------------------
	*	Animate a 3D vector 
	*	@param inDestVector: the vector to be updated
	*	@param duration: the duration in seconds of the animation
	*	@param from: the start value of the vector
	*	@param to: the end value of the vector
	*	@param effect: the effect to be applied
	*	@param effecttype: a list of effect parameters
	*	@return a value to be used by ActionQueue
	-------------------------------------------------------------------------*/
	public static function offset (inDestVector:Vector3D,
								 duration:Number,
								 from:Vector3D,
								 to:Vector3D,
								 effect:Function,
								 effectParams:Array) : ActionQueuePerformData
	{
		var performFunction:Function = function (inPerc:Number) : Boolean {
			var diff:Vector3D = to.copy();
			diff.subtract(from);
			diff.mulScalar(-inPerc);
			diff.addVector(to);
			diff.copyTo(inDestVector);
			return true;
		};
		
	    return new ActionQueuePerformData( performFunction, duration, 1, 0, effect, effectParams);
	}
	
	/**-----------------------------------------------------------------------
	*	Animate a 3D object 
	*	@param inDestObject: the object to be animated; its 3D-location is set directly
	*	@param duration: the duration in seconds of the animation
	*	@param from: the start value of the vector
	*	@param to: the end value of the vector
	*	@param effect: the effect to be applied
	*	@param effecttype: the type of effect to be applied
	*	@return a value to be used by ActionQueue
	-------------------------------------------------------------------------*/
	public static function location (inDestObject:I3DObject,
								 duration:Number,
								 inFrom:Vector3D,
								 inTo:Vector3D,
								 effect:Function,
								 effectParams:Array) : ActionQueuePerformData
	{
		var from:Vector3D = (inFrom == undefined) ? inDestObject.get3DLocation().copy() : inFrom;
		
		var performFunction:Function = function (inPerc:Number) : Boolean {
			var diff:Vector3D = inTo.copy();
			diff.subtract(from);
			diff.mulScalar(-inPerc);
			diff.addVector(inTo);
			inDestObject.set3DLocation(diff);
	        return true;
	    };
	
	    // Set up the data so ActionQueue will perform the function performFunction:
	    return new ActionQueuePerformData( performFunction, duration, 1, 0, effect, effectParams);
	}
}
