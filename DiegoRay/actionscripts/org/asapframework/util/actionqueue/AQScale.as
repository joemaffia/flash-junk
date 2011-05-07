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
ActionQueue method to control the scaling of a movieclip.
See also {@link AQPulse} to scale a movieclip in a pulsating manner.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQScale {

	private static var START_VALUE:Number = 1; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 0; /**< End animation value to be returned to the perform function. */
	
	/**
	@param inMC : movieclip to scale
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inStartScaleX : x value to start scaling from; if null then inMC's current _xscale value is used
	@param inStartScaleY : y value to start scaling from; if null then inMC's current _yscale value is used
	@param inEndScaleX : x value to end scaling to; if null then inMC's current (dynamic) _xscale value is used
	@param inEndScaleY : y value to end scaling to; if null then inMC's current (dynamic) _yscale value is used
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	@example
	This example scales a movieclip from scale 100 to scale 200 in 2 seconds:
	<code>
	queue.addAction( AQScale.scale, my_mc, 2, 100, 100, 200, 200, Elastic.easeOut );
	</code>
	To scale back to normal scale from an arbitrary bigger or smaller scale:
	<code>
	queue.addAction( AQScale.scale, my_mc, 2, null, null, 100, 100, Elastic.easeOut );
	</code>
	*/
	public static function scale (inMC:MovieClip,
								  inDuration:Number,
								  inStartScaleX:Number,
								  inStartScaleY:Number,
								  inEndScaleX:Number,
								  inEndScaleY:Number,
								  inEffect:Function) : ActionQueuePerformData {
								  
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(7, arguments.length - 7);
		
		var startScaleX:Number = (inStartScaleX != undefined) ? inStartScaleX : inMC._xscale;
		var startScaleY:Number = (inStartScaleY != undefined) ? inStartScaleY : inMC._yscale;
		// don't use endScaleX and endScaleY here, but use relative end values,
		// to make it possible that another function changes the end values in the meantime
		
		var rendx:Number, rendy:Number, changex:Number, changey:Number;
		
		var performFunction:Function = function (inPerc:Number) {
			// inPerc = percentage counting down from {@link #END_VALUE} to {@link #START_VALUE}
			rendx = (inEndScaleX != null) ? inEndScaleX : inMC._xscale;
			rendy = (inEndScaleY != null) ? inEndScaleY : inMC._yscale;
			changex = rendx - startScaleX;
			changey = rendy - startScaleY;
			inMC._xscale = rendx - (inPerc * changex);
			inMC._yscale = rendy - (inPerc * changey);
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}

}