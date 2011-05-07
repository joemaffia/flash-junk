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

import org.asapframework.util.actionqueue.*;

/**
ActionQueue method to rotate a movieclip over time.
@author Arthur Clemens
*/

class org.asapframework.util.actionqueue.AQRotate {

	private static var START_VALUE:Number = 1; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 0; /**< End animation value to be returned to the perform function. */
	
	public static var CW:Number = 1; /**< Clockwise rotation. */
	public static var CCW:Number = -1; /**< Counter-clockwise rotation. */
	public static var NEAR:Number = 0; /**< Clockwise or counter-clockwise rotation to nearest rotation. */
	
	/**
	@param inMC : movieclip to rotate
	@param inDuration : length of rotation in seconds; 0 is used for perpetual animations - use -1 for instant rotation
	@param inStartRotation : the starting rotation in degrees; if null the current movieclip rotation will be used
	@param inEndRotation : the end rotation in degrees; if null the current movieclip rotation will be used
	@param inDirection : (optional) the rotation direction; either <code>AQRotate.CW</code> (clockwise) or <code>AQRotate.CCW</code> (counter-clockwise) or <code>AQRotate.NEAR</code> (nearest rotation); default <code>CW</code>
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	@example
	This example rotates a needle in a dial to the location that has been clicked, using the direction of the nearest rotation:
	<code>
	var angle:Number = NumberUtils.angle(_xmouse - needle_mc._x, _ymouse - needle_mc._y);
	queue.addAction( AQRotate.rotate, needle_mc, 1, null, angle, AQRotate.NEAR );	
	@usageNote Bug: passing an inDuration of 0 will result in no rotation at all.
	</code>
	*/
	public static function rotate (inMC:MovieClip,
								   inDuration:Number,
								   inStartRotation:Number,
								   inEndRotation:Number,
								   inDirection:Number,
								   inEffect:Function) : ActionQueuePerformData {
		
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(6, arguments.length - 6);
		
		var startRotation:Number = (inStartRotation != undefined) ? inStartRotation : inMC._rotation;
		startRotation %= 360;
		if (startRotation < 0) startRotation += 360; 
		
		var endRotation:Number = (inEndRotation != undefined) ? inEndRotation : inMC._rotation;
		endRotation %= 360;
		if (endRotation < 0) endRotation += 360;
		
		var changeRotation:Number = endRotation - startRotation;
		var direction:Number = (inDirection != undefined) ? inDirection : AQRotate.CW;
		
		if (endRotation > startRotation && direction == AQRotate.CCW) {
			endRotation -= 360;
		}	
		if (endRotation < startRotation && direction == AQRotate.CW) {
			endRotation += 360;
		}
		
		changeRotation = endRotation - startRotation;

		if (direction == AQRotate.NEAR) {
			if ((360 - changeRotation) < changeRotation) {
				changeRotation = changeRotation - 360;
			}
			if (360 - Math.abs(changeRotation) < Math.abs(changeRotation)) {
				changeRotation = 360 - Math.abs(changeRotation);
			}
		}	
		
		var performFunction:Function = function (inValue:Number) {
			inMC._rotation = endRotation - (inValue * changeRotation);
		};
		
		var performData:ActionQueuePerformData = new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
		if (inDuration == 0) {
			performData.loop = true;
		}
		return performData;
	}
	
}