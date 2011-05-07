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
ActionQueue method to change an object's property over time.
@author Arthur Clemens
*/

class org.asapframework.util.actionqueue.AQProperty {

	/**
	@param inObject : object to change; this may be a movieclip or any other object
	@param inProperty : name of property (in inObject) that will be affected; for instance "_x" for the x position of a movieclip
	@param inDuration : length of change in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inStartValue : the starting value of inProperty; if null the current object value will be used
	@param inEndValue : the end value of inProperty; if null the current object value will be used
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	*/
	public static function change (inObject:Object,
								   inProperty:String,
								   inDuration:Number,
								   inStartValue:Number,
								   inEndValue:Number,
								   inEffect:Function) : ActionQueuePerformData {
		
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(6, arguments.length - 6);
		
		var startValue:Number = (inStartValue != undefined) ? inStartValue : inObject[inProperty];
		var endValue:Number = (inEndValue != undefined) ? inEndValue : inObject[inProperty];		
		
		var performFunction:Function = function (inValue:Number) {
			inObject[inProperty] = inValue;
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, startValue, endValue, inEffect, effectParams);
	}
}