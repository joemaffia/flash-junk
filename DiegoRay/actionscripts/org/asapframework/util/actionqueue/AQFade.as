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
ActionQueue method that controls the alpha blend of a movieclip.
See also {@link AQPulse} to fade a movieclip in a pulsating manner.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQFade {

	private static var START_VALUE:Number = 1; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 0; /**< End animation value to be returned to the perform function. */

	/**
	@param inMC : movieclip to fade
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inStartAlpha : value to start fading from; if null then inMC's current _alpha value is used
	@param inEndAlpha : value to start fading to; if null then inMC's current _alpha value is used
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	@example
	This example fades in a movieclip from its current alpha to 100 in 2 seconds:
	<code>
	queue.addAction( AQFade.fade, my_mc, 2, null, 100, Regular.easeIn );
	</code>
	*/
	public static function fade (inMC:MovieClip,
								 inDuration:Number,
								 inStartAlpha:Number,
								 inEndAlpha:Number,
								 inEffect:Function) : ActionQueuePerformData {
								 
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(5, arguments.length - 5);
		
		var startAlpha:Number = (inStartAlpha != undefined) ? inStartAlpha : inMC._alpha;
		var endAlpha:Number = (inEndAlpha != undefined) ? inEndAlpha : inMC._alpha;

		var renda:Number, changea:Number;

		var performFunction:Function = function (inPerc:Number) {
			// inPerc = percentage counting down from {@link #END_VALUE} to {@link #START_VALUE}
			renda = (endAlpha == null ? inMC._alpha : endAlpha); 
			changea = endAlpha - startAlpha;
			inMC._alpha = renda - (inPerc * changea);
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}
}