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
import org.asapframework.events.EventDelegate;
import org.asapframework.util.framepulse.FramePulse;

/**
Class that provides one or more frames delay. 
Use this when initializing a swf or a bunch of movieclips, to enable the player to do its thing.
Usually a single frame delay will do the job, since the next enterFrame will come when all other jobs are finished.
This class will catch that next onEnterFrame and fire the function in the object passed as parameters.

A parameter is available if the delay has to be more than one frame.

@usage
<code>
	class myClass {
	
	private var mFrameDelay:FrameDelay;
	
		function init () : Void {
			 ... do a bunch of inits
			
			// wait one enterFrame
			mFrameDelay = new FrameDelay(this, initDone);
		}

		private function initDone () : Void {
			...
		}
		
		private function goAway () {
			mFrameDelay.die();
	}
</code>

When starting a swf:

<code>
	var lc:LocalController = new MyLocalController(this);
	// wait one enterFrame before notifying the MovieManager that this movie is done initializing
	var fd:FrameDelay = new FrameDelay(lc, lc.notifyMovieInitialized);
</code>
*/

class org.asapframework.util.FrameDelay {
	
	private var mIsDone:Boolean = false;
	private var mCurrentFrame:Number;
	private var mSender:Object;
	private var mCallback:Function;
	private var mParams:Array;
	private var mFramePulseListener:Function;

	/**
	Constructor; starts the waiting immediately.
	@param inSender:Object, the class that contains the function to be called when done waiting
	@param inCallback:Function, the callback function to be called when done waiting
	@param inParams:Array, list of paramters to pass to callback function
	@param inFrameCount:Number, the number of frames to wait; when left out, or set to 1 or 0, one frame is waited
	*/
	public function FrameDelay (inSender:Object, inCallback:Function, inFrameCount:Number, inParams:Array) {		

		// create handler for enterFrame events
		mFramePulseListener = EventDelegate.create(this, onEnterFrame);
	
		wait(inSender, inCallback, inFrameCount, inParams);
	}

	/**
	*	Release reference to creating object
	*	Use this to remove a FrameDelay object that is still running when the creating object will be removed
	*/
	public function die () : Void {
		if (!mIsDone) {
			FramePulse.removeEnterFrameListener(mFramePulseListener);
		}
	}

	// PRIVATE METHODS
	
	/**
	Stores input parameters (see {@link #FrameDelay constructor} parameters), start waiting.
	*/
	private function wait (inSender:Object, inCallback:Function, inFrameCount:Number, inParams:Array) : Void {
		mCurrentFrame = inFrameCount;
		mSender = inSender;
		mCallback = inCallback;
		mParams = inParams;

		mIsDone = ((inFrameCount == undefined) || (inFrameCount <= 1));

		// listen to framepulse events
		FramePulse.addEnterFrameListener(mFramePulseListener);
	}

	/**
	Handle the onEnterFrame event.
	Checks if still waiting - when true: calls callback function.
	*/
	private function onEnterFrame () : Void {
		
		if (mIsDone) {
			FramePulse.removeEnterFrameListener(mFramePulseListener);
			mCallback.apply(mSender,mParams);
		} else {
			mCurrentFrame--;
			mIsDone = (mCurrentFrame <= 1);
		}
	}
}
