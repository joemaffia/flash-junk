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

// ASAP classes
import org.asapframework.util.actionqueue.*;


/**
ActionQueue method to let a movieclip follow the mouse, with location and time parameters for precise control.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQFollowMouse {

	/**
	Lets a movieclip follow mouse movements. Control parameters:
	<ul>
		<li>a time variable for delay effect</li>
		<li>location variable for multiply effect</li>
		<li>offset variable for setting a fixed distance to the mouse</li>
		<li>callback method variable to get location feedback</li>
	</ul>
	@param inMC : movieclip to move
	@param inDuration : (optional) the number of seconds that the movieclip should move; default is 0 (infinite); use -1 for instant change
	@param inTimeDiv : (optional) the reaction speed to mouse changes. Use 1.0 to set the inMC at the mouse location without delay. Use anything between 1.0 and 0 for a slowed down effect; default is 1.0.
	@param inLocDiv : (optional) the translation factor of the mouse movements, relative to its parent's center point; an inLocDiv of 2 multiplies all x and y (difference) locations by 2. The visual effect works best if the parent has its (0,0) location at its center. The value should not be smaller than inTimeDiv (and is set automatically to the value of inTimeDiv if it is smaller); default (when nothing is set) is 1.0.
	@param inOffset : (optional) the number of pixels to offset the clip from the mouse, defined as a Point object
	@param inCallbackObject : (optional) object to return the calculated value to; if defined, the drawing is not performed by <code>followMouse</code> and should be done in the object's callback method inCallBackMethod
	@param inCallBackMethod : (optional) method name or function reference of function to which the calculated value should be returned; the variable that is passed to this object is a {@link Point}
	@return A new ActionQueuePerformData object.
	@example
	The most simple way to let a movieclip move infinitely to the mouse is:
	<code>
	queue.addAction( AQFollowMouse.followMouse, follow_mc );
	</code>
	But the effect is probably a bit flickering. A smoother effect can be reached by adding a 'smooth factor' by passing a value to inTimeDiv:
	<code>
	queue.addAction( AQFollowMouse.followMouse, follow_mc, 0, 0.5 );
	</code>
	Use an inTimeDiv value close to zero to get a really long lag.
	To move the movieclip at some distance from the mouse pointer, use an offset. The following code sets the movieclip to a value of (10, -10) from the mouse:
	<code>
	queue.addAction( AQFollowMouse.followMouse, my_mc, 0, null, null, new Point(10, -10) );
	</code>
	The following example lets a movieclip follow the mouse and passes its position to callback method "followMouseLoc". The positioning of the movieclip is done in the callback method.
	<code>
	queue.addAction( AQFollowMouse.followMouse, my_mc, 0, .09, .26, null, this, "followMouseLoc");
	// ...
	function followMouseLoc (inPos:Point) {
		my_mc._x = (STAGE_CENTER.x - inPos.x) * 0.25;
		my_mc._y = (STAGE_CENTER.y - inPos.y) * 0.25;
	}
	</code>
	To keep the MovieClip oriented to the mouse position, you can use this function:
	<code>
	private function followMouseLoc (inPos:Point) : Void {

		var dx:Number = inPos.x - graphic_mc._x;
		var dy:Number = inPos.y - graphic_mc._y;
		var d:Point = new Point(dx, dy);
		
		var startRotation:Number = graphic_mc._rotation;
		var endRotation:Number = NumberUtils.angle(d.x, d.y);
		var changeRotation:Number = endRotation - startRotation;

		if ((360 - changeRotation) < changeRotation) {
			changeRotation = changeRotation - 360;
		}
		if (360 - Math.abs(changeRotation) < Math.abs(changeRotation)) {
			changeRotation = 360 - Math.abs(changeRotation);
		}
		// do not rotate if the rotation will not be visible:
		if (Math.abs(changeRotation) > .5 ) {
			graphic_mc._rotation = endRotation - ((1 - ROTATION_EASE_FACTOR) * changeRotation);
		}
		
		// position clip
		graphic_mc._x = inPos.x;
		graphic_mc._y = inPos.y;
	}
	</code>
	Where <code>ROTATION_EASE_FACTOR</code> is 0 < n <= 1.
	*/
	
	public static function followMouse (inMC:MovieClip,
										inDuration:Number,
										inTimeDiv:Number,
										inLocDiv:Number,
										inOffset:Point,
										inCallbackObject:Object,
										inCallBackMethod:Object) : ActionQueuePerformData {

		var duration:Number = (inDuration != undefined) ? inDuration * 1000 : 0;
		var endTime:Number = getTimer() + duration;
		var timeDiv:Number = (inTimeDiv != undefined) ? inTimeDiv : 1.0;
		var locDiv:Number = (inLocDiv != undefined) ? inLocDiv : 1.0;
		// correction against artifacts (x, y flipflopping to negative values):
		if (locDiv < timeDiv) locDiv = timeDiv;
		var locdiv_f:Number = 1 / locDiv; // use a multiply factor for speed

		var offsetX:Number = (inOffset != undefined) ? inOffset.x : 0;
		var offsetY:Number = (inOffset != undefined) ? inOffset.y : 0;
		
		var callbackMethod:Function = null;
		if (typeof inCallBackMethod == "string") {
			callbackMethod = inCallbackObject[inCallBackMethod];
		}
		if (typeof inCallBackMethod == "function") {
			callbackMethod = Function(inCallBackMethod);
		}
		var draw:Function;
		var parent:MovieClip = inMC._parent;
		var point:Point = new Point(inMC._x, inMC._y);
		if (callbackMethod != undefined) {
			draw = function () {
				point.x -= ( locdiv_f * (point.x - offsetX) - parent._xmouse) * timeDiv;
				point.y -= ( locdiv_f * (point.y - offsetY) - parent._ymouse) * timeDiv;
				callbackMethod.call( inCallbackObject, point );
			};
		} else {
			draw = function () {
				point.x -= ( locdiv_f * (point.x - offsetX) - parent._xmouse) * timeDiv;
				point.y -= ( locdiv_f * (point.y - offsetY) - parent._ymouse) * timeDiv;
				inMC._x = point.x;
				inMC._y = point.y;
			};
		}
		return new ActionQueuePerformData(draw, duration);
	}
	
}