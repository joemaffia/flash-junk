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
ActionQueue method that moves a movieclip over a relative distance.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQMoveRel {

	private static var START_VALUE:Number = 0; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 1; /**< End animation value to be returned to the perform function. */
	
	/**
	Moves a movieclip over a relative distance, making it easy to change the direction while moving. The end location is approximated - for precize control over the end location, use {@link AQMove#move}. 
	@param inMC : movieclip to move
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inRelX : the x distance the clip should travel
	@param inRelY : the y distance the clip should travel
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	@example
	This example lets a movieclip travel (-40, 15) pixels over a timeframe of 2 seconds, with an ease in effect:
	<code>
	queue.addAction( AQMoveRel.move, my_mc, 2, -40, 15, Regular.easeIn );
	</code>
	*/
	public static function move (inMC:MovieClip,
								 inDuration:Number,
								 inRelX:Number,
								 inRelY:Number,
								 inEffect:Function) : ActionQueuePerformData {
								 
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(5, arguments.length - 5);
		
		var targetx:Number; // relative location where the clip should be
		var targety:Number;
		var travx:Number = 0; // relative distance that the clip has travelled
		var travy:Number = 0;
		
		var performFunction:Function = function (inPerc:Number) {
			// inPerc = percentage counting down from {@link #END_VALUE} to {@link #START_VALUE}
			targetx = inPerc * inRelX;
			targety = inPerc * inRelY;
			inMC._x += (targetx - travx);
			inMC._y += (targety - travy);
			travx = targetx;
			travy = targety;
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}
}