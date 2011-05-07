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

// Adobe classes
//import flash.geom.*;
// Still support Flash 7:
import org.asapframework.util.types.*;

import org.asapframework.util.actionqueue.*;
import org.asapframework.util.transitions.tween.Bezier;


/**
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQCurve {

	private static var START_VALUE:Number = 1; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 0; /**< End animation value to be returned to the perform function. */

	/**
	Moves a movieclip over a cubic bezier curve, defined by the start and end positions and 2 control points.
	@param inMC : movieclip to move
	@param inDuration : length of movement in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inStartX : x value to start moving from; if null then inMC's current _x value is used
	@param inStartY : y value to start moving from; if null then inMC's current _y value is used
	@param inEndX : x value to start moving to; if null then inMC's current (dynamic) _x value is used
	@param inEndY : y value to start moving to; if null then inMC's current (dynamic) _y value is used
	@param inControlPoint1 : the first control point on the Bezier curve
	@param inControlPoint2 : the second control point on the Bezier curve
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	See Wikipedia on <a href="http://en.wikipedia.org/wiki/Bezier_curve#Cubic_B.C3.A9zier_curves">Cubic Bezier curves</a>
	@example
	The following example moves a movieclip along a cubic bezier path during 4 seconds, from position (0,0) to (300,300). The path is defined by 2 control points. The animation has an easing effect.
	<code>
	queue.addAction( AQCurve.moveCubicBezier, my_mc, 4, 0, 0, 300, 300, new Point(100,400), new Point(400,100), Strong.easeOut );
	</code>
	*/
	public static function moveCubicBezier (inMC:MovieClip,
											inDuration:Number,
											inStartX:Number,
											inStartY:Number,
											inEndX:Number,
											inEndY:Number,
											inControlPoint1:Point,
											inControlPoint2:Point,
									 		inEffect:Function) : ActionQueuePerformData {
		
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(9, arguments.length - 9);

		var startX:Number = (inStartX != undefined) ? inStartX : inMC._x;
		var startY:Number = (inStartY != undefined) ? inStartY : inMC._y;
		var endX:Number = (inEndX != undefined) ? inEndX : inMC._x;
		var endY:Number = (inEndY != undefined) ? inEndY : inMC._y;
		var rangeX:Number = endX - startX;
		var rangeY:Number = endY - startY;
		
		var x:Number = 0;
		var y:Number = 0;
		
		var performFunction:Function = function (inPerc:Number) : Boolean {
			// inPerc = percentage counting down from {@link #END_VALUE} to {@link #START_VALUE}
			x = Bezier.cubic( (1-inPerc) * inDuration, startX, rangeX, inDuration, inControlPoint1.x, inControlPoint2.x );
			y = Bezier.cubic( (1-inPerc) * inDuration, startY, rangeY, inDuration, inControlPoint1.y, inControlPoint2.y );
			inMC._x = x;
			inMC._y = y;
			return true;
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}
}