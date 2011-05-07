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
import org.asapframework.util.NumberUtils;

/**
ActionQueue methods to make a movieclip blink.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQBlink {
	
	private static var START_VALUE:Number = 0; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 1; /**< End animation value to be returned to the perform function. */
	private static var PI2:Number = 2 * Math.PI;
	public static var MASK_OFFSCREEN_X:Number = -9999;
	
	/**
	@param inMC : movieclip to blink
	@param inCount : the number of times the clip should blink (the number of cycles, where each cycle is a full sine curve)
	@param inFrequency : number of blinks per second
	@param inMinAlpha : the lowest alpha when blinking; when no value is passed the current inMC's _alpha is used
	@param inMaxAlpha : the highest alpha when blinking; when no value is passed the current inMC's _alpha is used
	@param inStartAlpha : (optional) the starting alpha; if not given, max alpha is used
	@param inDuration : (optional: pass either inDuration or inCount - if inDuration is given, inCount will be ignored) length of blinking in seconds; when 0, blinking is infinite, otherwise the movement will be stopped as soon as the duration has passed; in seconds
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return True (this method has an onEnterFrame) (to flag optimization for ActionQueue).
	@example This example lets a clip blink 4 times, with a frequency of 6 blinks per second, with a alpha value of 100 as maximum visibility and and a miminum visibility of alpha 10:
	<code>
	queue.addAction( AQBlink.blink, blink_mc, 2, 6, 100, 10, 100);
	</code>
	@usageNote Note that <code>blink</code> uses _alpha to set the visibility, not _visible.
	@implementationNote When blinking has finished, the movieclip is set to its original (starting) alpha.
	*/
	public static function blink (inMC:MovieClip,
								  inCount:Number,
								  inFrequency:Number,
								  inMaxAlpha:Number,
								  inMinAlpha:Number,
								  inStartAlpha:Number,
								  inDuration:Number,
								  inEffect:Function) : ActionQueuePerformData {
		
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(8, arguments.length - 8);
		
		var orgAlpha:Number = inMC._alpha;
		var minAlpha:Number = (inMinAlpha != undefined) ? inMinAlpha : inMC._alpha;
		var maxAlpha:Number = (inMaxAlpha != undefined) ? inMaxAlpha : inMC._alpha;
		var middleAlpha:Number = 0.5 * (maxAlpha - minAlpha);
		var offset:Number = 0;
		var startAlpha:Number = (inStartAlpha != undefined) ? inStartAlpha : middleAlpha;
		if (startAlpha < minAlpha) startAlpha = minAlpha;
		if (startAlpha > maxAlpha) startAlpha = maxAlpha;
		if (startAlpha != middleAlpha) {
			offset = NumberUtils.piOffset(startAlpha, minAlpha, maxAlpha);
		}
		// make the offset a whole number of PI		
		offset = Math.floor( offset / Math.PI ) * Math.PI;
		
		var cycleDuration:Number = 1.0 / inFrequency; // in seconds
		var count:Number = (inDuration == 0) ? 1 : inCount; // 1: at least once
		
		var amp:Number;
		var pi2:Number = AQBlink.PI2;
		var performFunction:Function = function (inPerc:Number) {
			amp = Math.sin( (inPerc * pi2) + offset );
			if (amp < 0) {
				inMC._alpha = minAlpha;
			} else {
				inMC._alpha = maxAlpha;
			}
		};
		var afterFunction:Function = function () {
			inMC._alpha = orgAlpha;
		};
		
		var performData:ActionQueuePerformData =  new ActionQueuePerformData(performFunction, cycleDuration, START_VALUE, END_VALUE, inEffect, effectParams);
		if (inDuration == 0) {
			performData.loop = true;
		}
		performData.afterMethod = afterFunction;
		return performData;
	}
	
	/**
	When you have multiple objects that should simply be hidden while blinking, a simple solution is to use a mask and put all objects under the mask. Then you only have to control the mask to set the visibility of its contents. But masks cannot be given an alpha value, so you cannot use {@link #blink}. <code>maskBlink</code> moves the mask off screen (x position to MASK_OFFSCREEN_X).
	@param inMC : movieclip to blink
	@param inCount : the number of times the clip should blink (the number of cycles, where each cycle is a full sine curve)
	@param inFrequency : number of blinks per second
	@param inHideAtStart : (optional) if true the blinking starts with the clip set to invisible; if false it starts with the clip set to visible; default is true (visible)
	@param inDuration : (optional: pass either inDuration or inCount - if inDuration is given, inCount will be ignored) length of blinking in seconds; when 0, blinking is infinite, otherwise the movement will be stopped as soon as the duration has passed; in seconds
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return True (this method has an onEnterFrame) (to flag optimization for ActionQueue).
	@example
	This example hides a mask movieclip 10 times with a frequency of 5 blinks a second, starting out visible: 
	<code>
	queue.addAction( AQBlink.maskBlink, mask_mc, 10, 5, true );
	</code>
	@implementationNote When blinking has finished, the movieclip is set to its original (starting) location.
	*/
	public static function maskBlink (inMC:MovieClip,
									  inCount:Number,
									  inFrequency:Number,
									  inHideAtStart:Boolean,
									  inDuration:Number,
									  inEffect:Function) : ActionQueuePerformData {

		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(6, arguments.length - 6);
		
		var orgX:Number = inMC._x;
		var hideAtStart:Boolean = (inHideAtStart != undefined) ? inHideAtStart : false;
		var offset:Number = 0;
		if (hideAtStart) {
			offset = -Math.PI;
		}
		// make the offset a whole number of PI		
		offset = Math.floor( offset / Math.PI ) * Math.PI;
		
		var cycleDuration:Number = 1.0 / inFrequency; // in seconds
		var count:Number = (inDuration == 0) ? 1 : inCount; // 1: at least once
		
		var amp:Number;
		var pi2:Number = AQBlink.PI2;
		var performFunction:Function = function (inPerc:Number) {
			amp = Math.sin( (inPerc * pi2) + offset );
			if (amp < 0) {
				inMC._x = AQBlink.MASK_OFFSCREEN_X;
			} else {
				inMC._x = orgX;
			}
		};
		var afterFunction:Function = function () {
			inMC._x = orgX;
		};
		
		var performData:ActionQueuePerformData =  new ActionQueuePerformData(performFunction, cycleDuration, START_VALUE, END_VALUE, inEffect, effectParams);
		if (inDuration == 0) {
			performData.loop = true;
		}
		performData.afterMethod = afterFunction;
		return performData;
	}
}