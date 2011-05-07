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


/**
Data storage class to pass UIAction <em>perform actions</em>. Used by {@link ActionQueue}.
@author Arthur Clemens
*/

class org.asapframework.util.actionqueue.ActionQueuePerformData {

	/**
	The (object's) function to call. This function receives a percentage value between {@link #start} and {@link #end}.
	@use
	<code>
	private static var START_VALUE:Number = 1;
	private static var END_VALUE:Number = 0;
	
	var performFunction:Function = function (inPerc:Number) {
		// inPerc = percentage counting down from END_VALUE to START_VALUE
		// do something with inPerc value
	};
	...
	return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	</code>
	*/
	public var method:Function;
	
	/**
	The function owner. Set to run the performing method within the scope of this object.
	@example
	<code>
	var performData:ActionQueuePerformData = new ActionQueuePerformData(performFunction, inDuration, inStartValue, inEndValue, inEffect, effectParams);
	performData.methodOwner = this;
	return performData;
	</code>
	*/
	public var methodOwner:Object;
	
	public var duration:Number;			/**< Duration of the animation in seconds. */
	public var start:Number;			/**< Percentage start value to get returned to {@link #method}. */
	public var end:Number;				/**< Percentage end value to get returned to {@link #method}. */
	public var effect:Function;			/**< An effect function, for instance one of the mx.transitions.easing methods. */ 
	public var effectParams:Array;		/**< Arguments to pass the effect function. */
	public var loop:Boolean = false;	/**< True if {@link #method} should be called repeatedly; default value is false. */
	public var afterMethod:Function;	/**< Method to be called after the animation. After this method is called, the ActionQueue will continue to its next action. */
	
	/**
	Creates a new ActionQueuePerformData object, with optionally the most frequent used parameters.
	@param inPerformFunction : the (object's) function to call
	@param inDuration : duration of the animation in seconds; if 0, inPerformFunction will be performed perpetually
	@param inStartValue : (optional) percentage start value to get returned to {@link #method}
	@param inEndValue : (optional) percentage end value to get returned to {@link #method}
	@param inEffect : (optional) an effect function, for instance one of the mx.transitions.easing methods
	@param inEffectParams : (optional) arguments to pass the effect function
	@example
	The first example is from {@link AQFade}, and illustrates conventional use:
	<code>
	private static var START_VALUE:Number = 1;
	private static var END_VALUE:Number = 0;

	var performFunction:Function = function (inPerc:Number) {
		// inPerc = percentage counting down from END_VALUE to START_VALUE
		//  do something with inPerc...
	};
	
	return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	</code>
	When the ActionQueue hits the next fade action, <code>performFunction</code> will be called during <code>inDuration</code>, passing a value of inPerc between <code>START_VALUE</code> and <code>END_VALUE</code>. 
	<hr />
	The following example is from {@link AQSpring}, and illustrates how the perform function <code>springFunction</code> is passed with a duration of 0, making it the ActionQueue's performing function as long as the function does not return <code>false</code>. When the method returns false, the ActionQueue moves on to the next action.
	<code>
	var springFunction:Function = function() : Boolean {
		
		// spring calculations
		
		if ( inShouldHalt && Math.abs(xp) < inHaltSpeed) {
			return false;
		}
		return true;
	};
		
	return new ActionQueuePerformData(springFunction, 0);
	</code>
	*/
	public function ActionQueuePerformData (inPerformFunction:Function,
										    inDuration:Number,
										    inStartValue:Number,
										    inEndValue:Number,
										    inEffect:Function,
										    inEffectParams:Array) {
	
		method = inPerformFunction;
		duration = inDuration;
		start = inStartValue;
		end = inEndValue;
		effect = inEffect;
		if (inEffectParams != undefined && inEffectParams.length > 0) {
			effectParams = inEffectParams;
		}
	}
	
	public function toString () : String {
		return "; ActionQueuePerformData; duration=" + duration + "; start=" + start + "; end = " + end;
	}

}