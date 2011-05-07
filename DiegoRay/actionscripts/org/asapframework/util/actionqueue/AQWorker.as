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

import org.asapframework.util.actionqueue.ActionQueuePerformData;
import org.asapframework.util.framepulse.*;

/**
This class is used by ActionQueue and various AQxxx classes; you should not instantiate this class yourself.
@author Arthur Clemens
*/

dynamic class org.asapframework.util.actionqueue.AQWorker {

	private var mFramePulse:FramePulse;
	private var mName:String;
	private var mEndTime:Number;
	private var mStoredOnEnterFrame:Function;
	private var mDurationLeft:Number;

	/**
	@exclude
	@param inName : ActionQueue's identifier, to make debugging easier.
	*/
	function AQWorker (inName:String) {
		mName = (inName != undefined) ? inName : "anonymous AQWorker";
		mFramePulse = FramePulse.getInstance();
	}
	
	/**
	@exclude
	Pauses the current onEnterFrame. Called by {@link ActionQueue#pause}.
	@param inTimerShouldContinue : (optional) if true, the timer continues counting to mEndTime; default value is false: the time left is stored and added to the current time in {@link #resume}
	*/
	public function pause (inTimerShouldContinue:Boolean) : Void {
		if (!inTimerShouldContinue) {
			mDurationLeft = mEndTime - getTimer();
		} else {
			mDurationLeft = undefined; // remove old value
		}
		mStoredOnEnterFrame = this.onEnterFrame;
		idle();
	}
	
	/**
	@exclude
	Resumes the paused onEnterFrame. Called by {@link ActionQueue#play}.
	*/
	public function resume () : Void {
		if (mDurationLeft != undefined) {
			mEndTime = getTimer() + mDurationLeft;
		}
		this.onEnterFrame = mStoredOnEnterFrame;
	}
	
	/**
	@exclude
	*/
	public function start () : Void {
		mFramePulse.addEventListener(FramePulseEvent.ON_ENTERFRAME, this);
	}
	
	/**
	@exclude
	*/
	public function stop () : Void {
		stopOnEnterFrame();
		mFramePulse.removeEventListener(FramePulseEvent.ON_ENTERFRAME, this);
	}
	
	/**
	@exclude
	*/
	public function idle () : Void {
		this.onEnterFrame = function () {};
	}
	
	/**
	The worker is busy when its onEnterFrame is not undefined.
	@exclude
	*/
	public function isBusy () : Boolean {
		return this.onEnterFrame != undefined;
	}
	
	/**
	@exclude
	*/
	public function stopOnEnterFrame () : Void {
		this.onEnterFrame = undefined;
		delete this.onEnterFrame;
	}
	
	/**
	@exclude
	The end time of the animation. Used by AQxxx classes.
	*/
	public function get endTime () : Number {
		return mEndTime;
	}
	public function set endTime (t:Number) : Void {
		mEndTime = t;
	}
	
	/**
	@exclude
	*/
	public function toString () : String {
		return "; AQWorker " + mName;
	}
	
	/**
	@exclude
	Lets the inWorker (thus the queue) pause between actions. Do not call this method directly, but use ActionQueue.addPause().
	@param inDuration : length of wait in seconds; if 0, waiting is infinite
	@return A new ActionQueuePerformData object.
	@implementationNote This method is called by ActionQueue.addPause().
	*/
	public function wait (inDuration:Number) : ActionQueuePerformData {
		var waitFunction:Function = function () {
			if (inDuration == 0) return; // infinite: do not end
		};
		return new ActionQueuePerformData(waitFunction, inDuration);
	}

	/**
	Do not call this method directly, but use {@link AQReturnValue#returnValue}.
	@param inPerformData : data object with perform instructions
	@implementationNote This method is called by virtually all AQxxx classes.
	*/	
	public function returnValue (inPerformData:ActionQueuePerformData) : Void {

		var effect:Function = inPerformData.effect;
		var hasEffectParams:Boolean = (inPerformData.effectParams != undefined) && (inPerformData.effectParams.length > 0);
		
		var duration:Number = inPerformData.duration * 1000; // translate to milliseconds
		var dur_f = 1 / duration; // use a multiply factor for speed
		mEndTime = getTimer() + duration;

		var startValue:Number = (inPerformData.start != null) ? inPerformData.start : 0;
		var endValue:Number = (inPerformData.end != null) ? inPerformData.end : 1000;

		var perc:Number, value:Number, now:Number;
		var range:Number = endValue - startValue;

		var params:Array;
		var ref:AQWorker = this;

		if (duration == 0) {
			this.onEnterFrame = function () {
				if (inPerformData.method() == false) {
					this.stopOnEnterFrame();
				}
			};
			return;
		}
				
		this.onEnterFrame = function () {
			now = getTimer();
			if (mEndTime > now) {
				perc = (mEndTime - now) * dur_f; // multiply is faster than division
				if (effect) {
					if (hasEffectParams) {
						params = [1 - perc, startValue, range, 1].concat(inPerformData.effectParams);
						value = Number(effect.apply(null, params));
					} else {
						value = Number(effect.call(null, 1 - perc, startValue, range, 1));
					}
				} else {
					value = endValue - (perc * range);
				}
				if (inPerformData.method.call(inPerformData.methodOwner, value) == false) {
					// the performing method has returned false, so end this action
					this.stopOnEnterFrame();
				}
			} else {
				// end of loop
				if (inPerformData.loop) {
					ref.returnValue(inPerformData);
				} else {
					value = endValue;
					this.stopOnEnterFrame();
					if (inPerformData.method.call(inPerformData.methodOwner, value) != false) {
						// only call the afterMethod function if this action has not been aborted
						if (inPerformData.afterMethod != undefined) {
							inPerformData.afterMethod.apply();
						}
					}
				}
			}
		};
	}
	
}
