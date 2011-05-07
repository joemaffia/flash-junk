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
ActionQueue method that controls the relative position of a movieclip.
Lets a movieclip or button move a specified number of pixels added to its current location, without specifying its end location.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQAddMove {

	private static var START_VALUE:Number = 0; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 1; /**< End animation value to be returned to the perform function. */
	
	/**
	@param inMC : movieclip or button to move
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inAddX : the horizontal distance in pixels to move the clip
	@param inAddY : the vertical distance in pixels to move the clip
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return The return value of <code>AQWorker.returnValue</code>.
	@implementationNote This method calls AQWorker's returnValue.
	@example
	This example lets a movieclip travel (-40, 15) pixels over a timeframe of 2 seconds, with an ease in effect.
	<code>
	queue.addAction( AQAddMove.addMove, my_mc, 2, -40, 15, Regular.easeIn );
	</code>
	*/
	public static function addMove (inMC:MovieClip,
									inDuration:Number,
									inAddX:Number,
									inAddY:Number,
									inEffect:Function) : ActionQueuePerformData {
		
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(5, arguments.length - 5);

		var targetx:Number; // relative location where the clip should be
		var targety:Number;
		var travx:Number = 0; // relative distance what the clip has travelled
		var travy:Number = 0;
		
		var performFunction:Function = function (inPerc:Number) {
			// inPerc = percentage counting down from {@link #END_VALUE} to {@link #START_VALUE}
			targetx = inPerc * inAddX;
			targety = inPerc * inAddY;
			inMC._x += (targetx - travx);
			inMC._y += (targety - travy);
			travx = targetx;
			travy = targety;
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}
}