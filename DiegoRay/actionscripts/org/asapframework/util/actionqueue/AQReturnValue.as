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
ActionQueue method that returns a calculated (percentage) value of an animation in time.
Use this method to keep track of a (animated/calculated) value without directly manipulating a movieclip - to store the value or use it to update multiple other clips or values.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQReturnValue {
		
	/**
	Calls a callback method with a calculated (percentage) value of an animation. You need to pass a callback object and method to pass the animated value to. The value that is passed is the percentage value calculated over time, between inStartValue and inEndValue.
	@param inPerformingObject : callback object
	@param inPerformingMethod : callback (object's) method (name or function reference): method to pass the calculated value
	@param inDuration : length of the animation in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inStartValue : (optional) start value: the value that is returned when no time has passed; this may be any number, including numbers larger than the end value, or negative numbers; default 0 is assumed
	@param inEndValue : (optional) end value: the value that is returned when _duration_ time has passed; this may be any number, including numbers smaller than the start value, or negative numbers; default 1000 is assumed
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return True (this method has an onEnterFrame) (to flag optimization for ActionQueue).
	@example
	This example calls the method "setPercentage" during 0.5 seconds, and sets its argument value during this time from 0 to 100:
	<code>
	queue.addAction( AQReturnValue.returnValue, this, "setPercentage", 0.5, 0, 100 );
	// ...
	public function setPercentage (inPercentage:Number) : Void
	{
		updateVisualStatus(inPercentage);
		if (inPercentage == 100) {
			// stop
		}
	}
	</code>
	<hr />
	To create simultaneous movieclip effects, let the called method set multiple variables or methods. For example:
	<code>
	queue.addAction( AQReturnValue.returnValue, this, "setScale", 0.2, 0, 1 );
	// ...
	private function setScale (inPercentage:Number) : Void
	{
		label_mc.setLabelBackgroundBlend( LABEL_BG_MIN_ALPHA + (LABEL_BG_MAX_ALPHA - LABEL_BG_MIN_ALPHA) * inPercentage );
		_xscale = _yscale = 100 + ((MAX_SCALE - 100) * inPercentage);
		if (mColTransformDuringAnimation != undefined) {
			ColorUtils.setMixTransform( image_mc, mColTransformDuringAnimation, mColTransformNormal, inPercentage);
		}
	}
	</code>
	ActionQueue has the utility function {@link ActionQueue#relativeValue} to make the calculation of the changing value a bit easier. For example:
	<code>
	public function moveToActualPosition () : Void {
		mStartIntroPosition = new Point(_x, _y);
		mStartIntroScale = _xscale;
		var duration:Number = 2.0;
		var queue:ActionQueue = new ActionQueue();
		queue.addAction( AQReturnValue.returnValue, this, "performMoveToActualPosition", duration, 0, 1);
		queue.run();
	}
	
	private function performMoveToActualPosition (inPercentage:Number) : Void {
		_x = ActionQueue.relativeValue( mStartIntroPosition.x, mPosition.x, inPercentage );
		_y = ActionQueue.relativeValue( mStartIntroPosition.y, mPosition.y, inPercentage );
		_xscale = _yscale = ActionQueue.relativeValue( mStartIntroScale, mScale, inPercentage );
	}
	</code>
	*/
	public static function returnValue (inPerformingObject:Object,
										inPerformingMethod:Object,
										inDuration:Number,
										inStartValue:Number,
										inEndValue:Number,
										inEffect:Function) : ActionQueuePerformData {

		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(6, arguments.length - 6);
		var performFunction:Function;
		if (typeof inPerformingMethod == "string") {
			// method name
			performFunction = inPerformingObject[inPerformingMethod];
		}
		if (typeof inPerformingMethod == "function") {
			performFunction = Function(inPerformingMethod);
		}
		var performData:ActionQueuePerformData = new ActionQueuePerformData(performFunction, inDuration, inStartValue, inEndValue, inEffect, effectParams);
		performData.methodOwner = inPerformingObject;
		return performData;
	}
}