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
ActionQueue methods to let a movieclip (or any objectys' property) pulsate.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQPulse {

	private static var START_VALUE:Number = 0; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 1; /**< End animation value to be returned to the perform function. */
	private static var PI2:Number = 2 * Math.PI;
	
	/**
	Fades a movieclip in and out, in a pulsating manner.
	@param inMC : movieclip to fade in and out
	@param inCount : the number of times the clip should pulse (the number of cycles, where each cycle is a full sine curve)
	@param inFrequency : number of pulsations per second
	@param inMinAlpha : the lowest alpha when pulsating; when no value is passed the current inMC's _alpha is used
	@param inMaxAlpha : the highest alpha when pulsating; when no value is passed the current inMC's _alpha is used
	@param inStartAlpha : (optional) the starting alpha; if not given, the average of the max alpha and min alpha is used
	@param inDuration : (optional: pass either inDuration or inCount - if inDuration is given, inCount will be ignored) length of pulsating in seconds; when 0, pulsing is infinite, otherwise the movement will be stopped as soon as the duration has passed; in seconds
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return True (this method has an onEnterFrame) (to flag optimization for ActionQueue).
	@example This example lets a clip pulsate 2 times, with a frequency of 0.6 pulses per second:
	<code>
	queue.addAction( AQPulse.fade, pulse_mc, 2, 0.6, 100, 40, 100);
	</code>
	The following line will let the clip pulse for one second (count of 2 is ignored):
	<code>
	queue.addAction( AQPulse.fade, pulse_mc, 2, 0.6, 100, 40, 100, 1);
	</code>
	And the following line will let the clip pulse indefinitely, with a visual effect:
	<code>
	queue.addAction( AQPulse.fade, pulse_mc, 2, 0.6, 100, 40, 100, 0, "regular", "easeinout");
	</code>
	@implementationNote This method calls {@link #change}.
	*/
	public static function fade (inMC:MovieClip,
								 inCount:Number,
								 inFrequency:Number,
								 inMaxAlpha:Number,
								 inMinAlpha:Number,
								 inStartAlpha:Number,
								 inDuration:Number,
								 inEffect:Function) : ActionQueuePerformData {
								 
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(8, arguments.length - 8);
		
		var args:Array = [inMC, "_alpha", inCount, inFrequency, inMaxAlpha, inMinAlpha, inStartAlpha, inDuration, inEffect];
		if (effectParams != undefined) {
			args.concat(effectParams);
		}
		return AQPulse.change.apply(null, args);
	}
	
	
	/**
	Scales a movieclip larger and smaller in a pulsating manner.
	@param inMC : movieclip to scale
	@param inCount : the number of times the clip should pulse (the number of cycles, where each cycle is a full sine curve)
	@param inFrequency : number of pulsations per second
	@param inMaxScale : the largest scale (both x and y) when pulsating; when no value is passed the current inMC's _xscale is used
	@param inMinScale : the smallest scale (both x and y) when pulsating; when no value is passed the current inMC's _xscale is used
	@param inStartScale : (optional) the starting scale; if not given, the average of the max scale and min scale is used
	@param inDuration : (optional: pass either inDuration or inCount - if inDuration is given, inCount will be ignored) length of pulsating in seconds; when 0, pulsing is infinite, otherwise the movement will be stopped as soon as the duration has passed; in seconds
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return True (this method has an onEnterFrame) (to flag optimization for ActionQueue).
	@example
	The following code lets a movieclip pulsate once, with a frequency of 0.3 pulses per second, maximum scale of 150 percent and a minimum scale of 50. The clip starts at scale 100.
	<code>
	queue.addAction( AQPulse.scale, scale_mc, 1, 0.3, 150, 50, 100 );
	</code>
	The next line will let the movieclip pulse indefinitely (the count of 1 is ignored), with a random frequency, giving it a lifelike 'breathing' effect:
	<code>
	queue.addAction( AQPulse.scale, scale_mc, 1, 0.2 + Math.random() * 0.4, 150, 100, 100, 0, Regular.easeOut );
	</code>
	@implementationNote This method calls {@link #change}.
	*/
	public static function scale (inMC:MovieClip,
								  inCount:Number,
								  inFrequency:Number,
								  inMaxScale:Number,
								  inMinScale:Number,
								  inStartScale:Number,
								  inDuration:Number,
								  inEffect:Function) : ActionQueuePerformData {
								  
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(8, arguments.length - 8);
		
		var args:Array = [inMC, ["_xscale", "_yscale"], inCount, inFrequency, inMaxScale, inMinScale, inStartScale, inDuration, inEffect];
		if (effectParams != undefined) {
			args.concat(effectParams);
		}
		return AQPulse.change.apply(null, args);
	}
	
	/**
	ActionQueue method to change an object's property over time using a pulsating animation.
	@param inObject : object to change; this may be a movieclip or any other object
	@param inProperty : name of property (in inObject) that will be affected; for instance "_x" for the x position of a movieclip; multiple properties may be passed as an array, for instance: <code>["_xscale", "_yscale"]</code>
	@param inCount : the number of times the clip should pulse (the number of cycles, where each cycle is a full sine curve)
	@param inFrequency : number of pulsations per second
	@param inMaxValue : the max value of inProperty; if null the current object value will be used
	@param inMinValue : the min value of inProperty; if null the current object value will be used
	@param inStartValue : the start value of inProperty; if null the current object value will be used
	@param inDuration : (optional: pass either inDuration or inCount - if inDuration is given, inCount will be ignored) length of pulsating in seconds; when 0, pulsing is infinite, otherwise the movement will be stopped as soon as the duration has passed; in seconds
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	@example
	This example lets a movieclip pulsate its scale:
	<code>
	var scale:Number = my_mc._xscale;
	var count:Number = 2;
	var frequency:Number = .7;
	var maxScale:Number = scale * 1.5;
	var minScale:Number = scale * .5;
	var startScale:Number = scale;
	queue.addAction( AQPulse.change, my_mc, ["_xscale", "_yscale"], count, frequency, maxScale, minScale, startScale, null );
	</code>
	*/
	public static function change (inObject:Object,
								   inProperty:Object,
								   inCount:Number,
								   inFrequency:Number,
								   inMaxValue:Number,
								   inMinValue:Number,
								   inStartValue:Number,
								   inDuration:Number,
								   inEffect:Function) : ActionQueuePerformData {
								  
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(9, arguments.length - 9);
		
		var maxValue:Number = (inMaxValue != undefined) ? inMaxValue : inObject[inProperty];
		var minValue:Number = (inMinValue != undefined) ? inMinValue : inObject[inProperty];
		
		var middleValue:Number = 0.5 * (maxValue - minValue);
		
		var offset:Number = 0;
		var startValue:Number = (inStartValue != undefined) ? inStartValue : middleValue;
		if (startValue < minValue) startValue = minValue;
		if (startValue > maxValue) startValue = maxValue;
		if (startValue != middleValue) {
			offset = NumberUtils.piOffset(startValue, minValue, maxValue);
		}
		
		var hasMultiProperties:Boolean = inProperty instanceof Array;
		
		var duration:Number;
		var endValue:Number;
		var cycleDuration:Number = 1.0 / inFrequency; // in seconds

		var loopCount:Number = (inCount) ? inCount : 0;
		if (inDuration > 0) {
			loopCount = inDuration / cycleDuration;
			duration = inDuration;
			endValue = inDuration;
		}
		if (inDuration == 0) {
			// loop
			duration = cycleDuration;
			endValue = END_VALUE;
		}
		if (inDuration == undefined) {
			// use count
			duration = loopCount * cycleDuration;
			endValue = loopCount;
		}

		var amp:Number;
		var pi2:Number = AQPulse.PI2;
		var startTime = getTimer();
		var performFunction:Function = function (inPerc:Number) {
			amp = Math.sin( (inPerc * pi2) + offset ) + 1;
			if (!hasMultiProperties) {
				inObject[inProperty] = minValue + (amp * middleValue);
			} else {
				for (var i:String in inProperty) {
					inObject[inProperty[i]] = minValue + (amp * middleValue);
				}
			}
		};
		var performData:ActionQueuePerformData = new ActionQueuePerformData(performFunction, duration, START_VALUE, endValue, inEffect, effectParams);
		if (inDuration == 0) {
			performData.loop = true;
		//	performData.loopCount = loopCount;
		}
		return performData;
	}
	
	
}