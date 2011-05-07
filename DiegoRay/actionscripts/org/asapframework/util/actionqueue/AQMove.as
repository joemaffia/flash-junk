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
ActionQueue method to control the position of a movieclip over time.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQMove {

	private static var START_VALUE:Number = 1; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 0; /**< End animation value to be returned to the perform function. */
	
	/**
	@param inMC : movieclip to move
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inStartX : x value to start moving from; if null then inMC's current _x value is used
	@param inStartY : y value to start moving from; if null then inMC's current _y value is used
	@param inEndX : x value to start moving to; if null then inMC's current (dynamic) _x value is used
	@param inEndY : y value to start moving to; if null then inMC's current (dynamic) _y value is used
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	@example
	The movieclip in this example will move a movieclip in 4 seconds from its current position to position (100,200) with an easing effect:
	<code>
	queue.addAction( AQMove.move, my_mc, 4, null, null, 100, 200, Regular.easeInOut );
	</code>
	*/
	public static function move (inMC:MovieClip,
								 inDuration:Number,
								 inStartX:Number,
								 inStartY:Number,
								 inEndX:Number,
								 inEndY:Number,
								 inEffect:Function) : ActionQueuePerformData {
		
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(7, arguments.length - 7);

		var startX:Number = (inStartX != undefined) ? inStartX : inMC._x;
		var startY:Number = (inStartY != undefined) ? inStartY : inMC._y;
		// don't use endX and endY here, but use a relative end position,
		// to make it possible that another function changes the end value in the meantime
		
		var rendx:Number, rendy:Number, changex:Number, changey:Number;

		var performFunction:Function = function (inPerc:Number) {
			// inPerc = percentage counting down from {@link #END_VALUE} to {@link #START_VALUE}
			rendx = (inEndX != null ? inEndX : inMC._x); 
			rendy = (inEndY != null ? inEndY : inMC._y);
			changex = rendx - startX;
			changey = rendy - startY;
			inMC._x = rendx - (inPerc * changex);
			inMC._y = rendy - (inPerc * changey);
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}
	
}