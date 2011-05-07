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

import org.asapframework.events.EventDelegate;

/**
The standard <code>Object.watch()</code> function in Flash cannot watch getter/setter properties. From the help text: 
<blockquote>
Generally, ActionScript predefined properties, such as _x, _y, _width and _height, are getter/setter properties, and thus cannot be watched with Object.watch().
</blockquote>

The current Watcher class can be used to watch any variable or method return value. But the mechanism used is less efficient than <code>Object.watch()</code>, as it is based on <code>setInterval</code> calls to evaluate the variables. The interval frequency is passed in the constructor to allow a slower evaluation (thus better performance) where possible. But you will see real performance problems only with a fast frequency interval.

Watcher tries to match a variable or a function return value to a given property value. For instance, Watcher may be used to call a callback function when the mouse is over a certain screen region.

Watching may be a one-time hit, or perpetuously until the value is met or the Watcher is stopped.
@author Arthur Clemens
@use
The following example shows how to check for value of the MovieClip's <code>_alpha</code> variable; when <code>_alpha</code> has gone to 0, the method 'afterZero' is called. Checking is done each 12th of a second and perpetuously until the clips' _alpha has turned to 0.
<code>
var watcher:Watcher = new Watcher(my_mc, "_alpha", 0, 1/12);
watcher.setAfterMethod(this, "afterZero");
watcher.start();
</code>
A test to make the clip fade out:
<code>
var queue:ActionQueue = new ActionQueue();
queue.addAQMethod (AQFade.fade, my_mc, 1, null, 0 );
queue.run();
</code>
@todo For the conditional value add logic such as "<= 50" or "!= 0".
*/

class org.asapframework.util.watch.Watcher {
	
	private var mIval:Number;
	private var mIntervalDuration:Number;
	
	private var mWatchedObject:Object;
	private var mWatchedMethodOrVar:Object;
	private var mCallbackObject:Object;
	private var mCallbackMethod:Object;
	private var mCallbackParams:Array;
	private var mAfterObject:Object;
	private var mAfterMethod:Object;
	private var mAfterParams:Array;
	private var mConditionalValue:Object;
	private var mShouldRepeat:Boolean;
	
	/**
	Sets up the Watcher.
	Pass a variable to watch the value of, or a function to watch its return value.	After the given interval duration, the variable is evaluated; if the checked variable is equal to the passed 'inConditionalValue' value, a callback function is called and the watcher stopped.
	Pass additional arguments to the callback method as a comma-separated list.
	@param inWatchedObject : object that owns the variable to watch
	@param inWatchedMethodOrVar : method name or function reference of function that returns a variable or variable name 
	@param inConditionalValue : value that the variable to watch is tested against
	@param inIntervalDuration : time duration between each check; duration in seconds
	@param inShouldRepeat : (optional) the variable should be checked only once (false) or repeatedly (true); default true
	<ul>
		<li>value false: check only once; if the checked variable is not equal to the passed inConditionalValue value, nothing happens</li>
		<li>value true: check repeatedly until the checked variable is equal to the passed inConditionalValue value, or until {@link #stop} is called</li>
	</ul>
	@example
	First set up our test environment:
	<code>
	var family:Object = new Object();
	family.memberCount = 2;
	family.birth = function () {
		family.memberCount++;
	}
	family.getMemberCount = function () { 
		return family.memberCount;
	}

	var birthControl:Object = new Object();
	birthControl.act = function () {
		trace("act");
	}
	</code>
	The watcher that is created in the next line will watch for the value returned from 'getMemberCount' from object 'family'. When getMemberCount returns 5, method 'act' of object 'birthControl' is called. Checking is done 31 times per second, until the value is found.
	<code>
	var watcher:Watcher = new Watcher(family, "getMemberCount", 5, 1/31);
	watcher.setAfterMethod(birthControl, "act");
	watcher.start();
	
	family.birth();
	family.birth();
	family.birth();
	</code>
	*/
	function Watcher (inWatchedObject:Object,
					  inWatchedMethodOrVar:Object,
					  inConditionalValue:Object,
					  inIntervalDuration:Number,
					  inShouldRepeat:Boolean) {
			
		mWatchedObject = inWatchedObject;
		mWatchedMethodOrVar = inWatchedMethodOrVar;
		mConditionalValue = inConditionalValue;
		mIntervalDuration = inIntervalDuration * 1000; // translate to milliseconds;
		mShouldRepeat = (inShouldRepeat != undefined) ? inShouldRepeat : true;
        mCallbackParams = arguments.splice(5, arguments.length - 5);
	}
	
	/**
	Starts the Watcher timer. The timer can be stopped with {@link #stop}.
	*/
	public function start () : Void {
		WAStartTimer();
	}
	
	/**
	Stops the Watcher timer. The timer can be restarted with {@link #restart}.
	*/
	public function stop () : Void {
		WAStopTimer();
	}

	/**
	Restarts the Watcher timer. The timer can be stopped with {@link #stop}.
	*/
	public function restart () : Void {
		WAStopTimer();
		WAStartTimer();
	}
	
	/**
	Sets the Watcher timer frequency interval.
	@param inIntervalDuration : time duration between each check; duration in seconds
	@example
	<code>
	var watcher:Watcher = new Watcher();
	watcher.setIntervalDuration(1/12);
	</code>
	*/
	public function setIntervalDuration (inIntervalDuration:Number) : Void {
		mIntervalDuration = inIntervalDuration * 1000; // translate to milliseconds;
	}
	
	/**
	Sets a function (object and function) that should be called during watching. The function will be passed the current value of variable that is being watched.
	@param inCallbackObject : object of the method that should be called during watching
	@param inCallbackMethod : Method (name or function reference) to be called during watching. Parameters that should be passed to the callback method can be appended as a comma separated list.
	*/
	public function setCallback (inCallbackObject:Object,
								 inCallbackMethod:Object) : Void {
		mCallbackObject = inCallbackObject;
		mCallbackMethod = inCallbackMethod;
        mCallbackParams = arguments.splice(2, arguments.length - 2);
	}
	
	/**
	Sets a function (object and function) that should be called if the variable to watch has met the condition as set in <code>inConditionalValue</code> in the {@link #Watcher Watcher constructor}.
	@param inAfterObject: object of the method that should be called
	@param inAfterMethod: Method (name or function reference) to be called. Parameters that should be passed to the 'after' method can be appended as a comma separated list.
	*/
	public function setAfterMethod (inAfterObject:Object,
									inAfterMethod:Object) : Void {
		mAfterObject = inAfterObject;
		mAfterMethod = inAfterMethod;
        mAfterParams = arguments.splice(2, arguments.length - 2);
	}
	
	/**
	Stores the variable to watch.
	@param inWatchedMethodOrVar : method name or function reference of function that returns a variable or variable name 
	*/
	public function setVariableToWatch (inWatchedMethodOrVar:Object) : Void {
		mWatchedMethodOrVar = inWatchedMethodOrVar;
	}
	
	/**
	Cleans up the Watcher object by calling clearInterval.
	*/
	public function die () : Void {
		WAStopTimer();
		delete this;
	}
	
	/**
	Returns if the Watcher is still running the interval function.
	@return True: the Watcher is still running; false: the Watcher has stopped.
	*/
	public function isBusy () : Boolean {
		return mIval != null;
	}
	
	/**
	
	*/
	public function toString () : String {
		return "; org.asapframework.util.watch.Watcher";
	}
	
	// PRIVATE METHODS
	
	/**
	
	*/
	private function WAStartTimer () : Void {
		WACheck();
		clearInterval(mIval);
		mIval = setInterval(EventDelegate.create(this, WACheck), mIntervalDuration) ;
	}

	/**
	
	*/
	private function WAStopTimer () : Void {
		clearInterval(mIval);
		mIval = null;
	}

	/**
	
	*/
	private function WAUpdateTimer () : Void {
		WAStopTimer();
		WAStartTimer();
	}

	/**
	
	*/
	public function WACheck () : Void {
		if (!mShouldRepeat) {
			WAStopTimer();
		}
		var value:Object;
		
		// if mWatchedMethodOrVar is a function
		if (typeof mWatchedMethodOrVar == "function") {
			value = mWatchedMethodOrVar.apply(mWatchedObject, mCallbackParams);
		} else if (typeof(mWatchedObject[mWatchedMethodOrVar]) == "function") {
			// get the value that the function returns
			value = mWatchedObject[mWatchedMethodOrVar].apply(mWatchedObject, mCallbackParams);
		} else {
			// if mWatchedMethodOrVar is a variable
			// get the value of that variable
			value = mWatchedObject[mWatchedMethodOrVar];
		}
		
		// call the callback function with the value
		if (mCallbackObject != undefined) {
			if (typeof mCallbackMethod == "function") {
				mCallbackMethod.apply(mCallbackObject, [value]);
			} else if (typeof(mCallbackObject[mCallbackMethod]) == "function") {
				mCallbackObject[mCallbackMethod].apply(mCallbackObject, [value]);
			}
		}
		
		// Check the retrieved value (from the watched object). If this matches the conditional value, the 'after object' is called.
		if (value == mConditionalValue) {
			if (mAfterObject != undefined) {
				if (typeof mAfterMethod == "function") {
					mAfterMethod.apply(mAfterObject, [value]);
				} else if (typeof(mAfterObject[mAfterMethod]) == "function") {
					mAfterObject[mAfterMethod].apply(mAfterObject, [value]);
				}
			}
			WAStopTimer();
		}
	}

}