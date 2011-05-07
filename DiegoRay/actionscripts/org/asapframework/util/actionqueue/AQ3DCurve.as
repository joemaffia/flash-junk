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
import org.asapframework.util.transitions.tween.Bezier;
import org.asapframework.util.types.I3DObject;
import org.asapframework.util.types.Vector3D;

/**
A class for animating objects in 3D space along a Bezier curve
 */
 
class org.asapframework.util.actionqueue.AQ3DCurve {
	/**
	Move a 3D object over a Bezier curve defined by start point, end point and 2 control points
	@param in3DObject: the 3D object to be moved
	@param inDuration: duration of the animation
	@param inStart: start point of the animation; can be null to start at the current location
	@param inEnd: end point of the animation; can be null to end at the current location
	@param inControlPoint1: first control point
	@param inControlPoint2: second control point
	@param inEffect: the effect function to be applied
	@param inEffectParams: parameters for the effect
	 */
	public static function moveCubicBezier (in3DObject:I3DObject,
											inDuration:Number,
											inStart:Vector3D,
											inEnd:Vector3D,
											inControlPoint1:Vector3D,
											inControlPoint2:Vector3D,
									 		inEffect:Function, inEffectParams:Array) : ActionQueuePerformData 
	{
		var curLoc:Vector3D = in3DObject.get3DLocation();
		
		var startX:Number = (inStart != undefined) ? inStart.x : curLoc.x;
		var startY:Number = (inStart != undefined) ? inStart.y : curLoc.y;
		var startZ:Number = (inStart != undefined) ? inStart.z : curLoc.z;

		var endX:Number = (inEnd != undefined) ? inEnd.x : curLoc.x;
		var endY:Number = (inEnd != undefined) ? inEnd.y : curLoc.y;
		var endZ:Number = (inEnd != undefined) ? inEnd.z : curLoc.z;
		
		var rangeX:Number = endX - startX;
		var rangeY:Number = endY - startY;
		var rangeZ:Number = endZ - startZ;
		
		var performFunction:Function = function (inPerc:Number) : Boolean {
			var d:Number = (1-inPerc) * inDuration;

			var x:Number = Bezier.cubic(d, startX, rangeX, inDuration, inControlPoint1.x, inControlPoint2.x );
			var y:Number = Bezier.cubic(d, startY, rangeY, inDuration, inControlPoint1.y, inControlPoint2.y );
			var z:Number = Bezier.cubic(d, startZ, rangeZ, inDuration, inControlPoint1.z, inControlPoint2.z );

			in3DObject.set3DLocation(new Vector3D(x, y, z));
			
			return true;
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, 1, 0, inEffect, inEffectParams);
	}
	
	/**
	Move a 3D vector over a Bezier curve defined by start point, end point and 2 control points
	@param in3DObject: the 3D object to be moved
	@param inDuration: duration of the animation
	@param inStart: start point of the animation; can be null to start at the current location
	@param inEnd: end point of the animation; can be null to end at the current location
	@param inControlPoint1: first control point
	@param inControlPoint2: second control point
	@param inEffect: the effect function to be applied
	@param inEffectParams: parameters for the effect
	 */
	public static function moveOffsetCubicBezier (inOffset:Vector3D,
											inDuration:Number,
											inStart:Vector3D,
											inEnd:Vector3D,
											inControlPoint1:Vector3D,
											inControlPoint2:Vector3D,
									 		inEffect:Function, inEffectParams:Array) : ActionQueuePerformData 
	{
		var curLoc:Vector3D = inOffset.copy();
		
		var startX:Number = (inStart != undefined) ? inStart.x : curLoc.x;
		var startY:Number = (inStart != undefined) ? inStart.y : curLoc.y;
		var startZ:Number = (inStart != undefined) ? inStart.z : curLoc.z;

		var endX:Number = (inEnd != undefined) ? inEnd.x : curLoc.x;
		var endY:Number = (inEnd != undefined) ? inEnd.y : curLoc.y;
		var endZ:Number = (inEnd != undefined) ? inEnd.z : curLoc.z;
		
		var rangeX:Number = endX - startX;
		var rangeY:Number = endY - startY;
		var rangeZ:Number = endZ - startZ;
		
		var performFunction:Function = function (inPerc:Number) : Boolean {
			var d:Number = (1-inPerc) * inDuration;

			inOffset.x = Bezier.cubic(d, startX, rangeX, inDuration, inControlPoint1.x, inControlPoint2.x );
			inOffset.y = Bezier.cubic(d, startY, rangeY, inDuration, inControlPoint1.y, inControlPoint2.y );
			inOffset.z = Bezier.cubic(d, startZ, rangeZ, inDuration, inControlPoint1.z, inControlPoint2.z );
			
			return true;
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, 1, 0, inEffect, inEffectParams);
	}
	
}