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

// ASAP classes
import org.asapframework.util.framepulse.FramePulse;
import org.asapframework.util.framepulse.FramePulseEvent;

/**
Checks the mouse location for movement. If the mouse has not moved in the set time period, a fallback function is called, allowing for instance a buttonclip to perform a rollout.
This class is useful to 'catch' the mouse if it has disappeared from the edge of the Flash stage. If this happens fast, or if the Flash movie is occupied, the movieclips don't receive any more mouse events, and stick to their current state. A RollOverWatcher object equals a out-of-stage mouse to a still mouse.
@author Arthur Clemens
*/

class org.asapframework.util.watch.RollOverWatcher {

	private var mLoc:Object;
	private var mInterval:Number;
	private var mIntervalDuration:Number;
	private var mFallbackFunctionOwner:Object;
	private var mFallbackFunctionName:String;
	private var mFallbackFunctionParams:Array;
	private var mFPulse:FramePulse;
	
	/**
	*	Calls method 'inCallerFallbackFunctionName' of object 'inCaller' when mouse
	*	inIntervalDuration in seconds
	*	Parameters that should be passed to the fallbackFunction can be added as a
	*	comma separated list after the 3 constructor parameters.
	*/	
	function RollOverWatcher (inFallbackFunctionOwner:Object,
							  inFallbackFunctionName:String,
							  inIntervalDuration:Number)
	{
		mFallbackFunctionOwner = inFallbackFunctionOwner;
		mFallbackFunctionName = inFallbackFunctionName;
		mIntervalDuration = inIntervalDuration * 1000;
		arguments.splice(0,3);
		mFallbackFunctionParams = arguments;
		mLoc = {x:_root._xmouse, y:_root._ymouse};
		
		// setup FramePulse events
		mFPulse = FramePulse.getInstance();
		
		startOnEnterFrame();
		setLocInterval();
	}
	
	/**
	*	
	*/
	public function stop () : Void
	{
		clearInterval(mInterval);
		stopOnEnterFrame();
	}
	
	/**
	*	
	*/
	private function setLocInterval () : Void
	{
		clearInterval(mInterval);
		mInterval = setInterval(this, "timerRing", mIntervalDuration);
	}

	/**
	*	
	*/
	private function timerRing () : Void
	{
		//trace("ROW timerRing");
		clearInterval(mInterval);
		stopOnEnterFrame();
		mFallbackFunctionOwner[mFallbackFunctionName].call(mFallbackFunctionOwner, mFallbackFunctionParams);
	}

	/**
	
	*/
	private function startOnEnterFrame () : Void
	{
		// listen to framepulse events
		mFPulse.addEventListener(FramePulseEvent.ON_ENTERFRAME, this);
	}
	
	/**
	
	*/
	private function stopOnEnterFrame () : Void
	{
		// stop listening to framepulse events
		mFPulse.removeEventListener(FramePulseEvent.ON_ENTERFRAME, this);
	}
	
	/**
	*	Updates mLoc and resets the time interval if the mouse has moved.
	*/
	private function onEnterFrame () : Void
	{
		if (mLoc.x == _root._xmouse && mLoc.y == _root._ymouse) {
			//
		} else {
			setLocInterval();
			mLoc = {x:_root._xmouse, y:_root._ymouse};
		}
	}
}