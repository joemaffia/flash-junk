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
import org.asapframework.util.watch.Watcher;

/**
Extends {@link ActionQueue} with the following functions:
<ul>
	<li><b>Looping:</b> set a start and end point in a list of actions and loop through them</li>
	<li><b>Wait for a message:</b> the queue becomes a listener that pauses until a message is received; or continue a paused queue as soon as a message is received</li>
	<li><b>Wait for a condition:</b> the queue will pause until a condition is met, or continue as soon as the condition is met</li>
</ul>
@use
Create the queue as you would with {@link ActionQueue}:
<code>
var extendedQueue:ExtendedActionQueue = new ExtendedActionQueue();
</code>
Add advanced actions:
<code>
extendedQueue.setLoopStart();
extendedQueue.addAction( AQMove.move, loop_mc, 1, null, null, endx, null, Regular.easeOut );
extendedQueue.addAction( AQMove.move, loop_mc, 0.5, null, null, endx, endy, Regular.easeOut );
extendedQueue.setLoopEnd();
</code>
Add 'normal' actions:
<code>
extendedQueue.addAction( AQFade.fade, loop_mc, 1, null, 0 );
extendedQueue.run();
</code>
@author Arthur Clemens
@todo Check if addContinueOnMessage still works with quirky setInterval in AS2.0.
*/

class org.asapframework.util.actionqueue.ExtendedActionQueue extends ActionQueue {
	
	private var mWatcher:Watcher;
	private var mMessageInterval:Number;
	private var mIsLooping:Boolean;
	private var mActionsCopy:Array; // copy of looped actions

	// types
	private var START_LOOP_TYPE:Number = 1;
	private var END_LOOP_TYPE:Number = 2;
	private var MESSAGE_TYPE:Number = 3;
	private var CONDITION_TYPE:Number = 4;


	/**
	@param inName: {@inheritDoc}
	*/
	public function ExtendedActionQueue (inName:String) {
		super(inName);
	}
	
	/**
	Marks the beginning of a loop.
	@example
	<code>
	var queue:ExtendedActionQueue = new ExtendedActionQueue("loop queue");
	queue.setLoopStart();
	// add methods
	queue.setLoopEnd();
	queue.run();
	</code>
	*/
	public function setLoopStart () : Void {
		mActionsCopy = new Array();
		var o:ExtendedActionQueueData = new ExtendedActionQueueData();
		o.type = START_LOOP_TYPE;
		mActions.push(o);
	}
	
	/**
	Marks the end of a loop.
	@example
	<code>
	var queue:ExtendedActionQueue = new ExtendedActionQueue("loop queue");
	queue.setLoopStart();
	// add methods
	queue.setLoopEnd();
	queue.run();
	</code>
	*/
	public function setLoopEnd () : Void {
		var o:ExtendedActionQueueData = new ExtendedActionQueueData();
		o.type = END_LOOP_TYPE;
		mActions.push(o);
	}
	
	/**
	Stop looping the queue.
	@param inShouldSkipToAfterLoop : (optional) true: don't finish current loop, but go directly to the first action after <code>setLoopEnd</code>; default false is assumed: the actions in the current loop are finished first before calling the actions after <code>setLoopEnd</code>
	*/
	public function endLoop (inShouldSkipToAfterLoop:Boolean) : Void {
		mIsLooping = false;

		if (inShouldSkipToAfterLoop) {
			AQNextAction();
			var i:Number, len:Number = mActions.length;
			var endLoopTypeIndex:Number = -1;
			for (i=0; i<len; ++i) {
				if (mActions[i].type == END_LOOP_TYPE) {
					endLoopTypeIndex = i;
					break;
				}
			}
			if (endLoopTypeIndex != -1) {
				mActions.splice(0, endLoopTypeIndex);
			}
		}
	}
	
	/**
	Continues a halted queue when a message is received. Use this method to break in on a continuous action, such as AQMethods with a duration of 0 (eternally).
	You can set a timeout function that should be called in case the message is not sent in the given time period. If you want to pause the action queue until the message is received, use {@link #addPauseUntilMessage}. 
	@param inSender : object that will send the message
	@param inMessage : name of message
	@param inTimeOutDuration : in case of error, the time in seconds that a timeout function will be called
	@param inTimedOutObject : object owner of timeout function
	@param inTimedOutFunctionName : method name of timeout function
	@usageNote Be careful not to attach an object that does not listen to removeListener, like common movieclips, or the listener will persist and keep on sending messages.
	@implementationNote This action is inserted into array 1 position before the last action, so this action will be evaluated before the (currently) last action is called. After the message has been received, the queue removes itself as listener.
	*/
	public function addContinueOnMessage (inSender:Object,
										  inMessage:String,
										  inTimeOutDuration:Number,
										  inTimedOutObject:Object,
										  inTimedOutFunctionName:String) : Void {
		var o:ExtendedActionQueueData = new ExtendedActionQueueData();
		o.type = MESSAGE_TYPE;
		o.sender = inSender;
		o.message = inMessage;
		o.timeOutDuration = inTimeOutDuration * 1000; // translate to milliseconds
		o.timedOutObject = inTimedOutObject;
		o.timedOutFunctionName = inTimedOutFunctionName;
		arguments.splice(0,5);
		o.timedOutArgs = arguments;
		mActions.splice(mActions.length - 1, 0, o);
	}

	/**
	Subscribes to an object (sender), then pauses the queue until the sender's message is received.
	@param inSender : object that will send the message
	@param inMessage : name of message
	@param inTimeOutDuration : in case of error, the time in seconds that a timeout function will be called
	@param inTimedOutObject : object owner of timeout function
	@param inTimedOutFunctionName : method name of timeout function
	@usageNote : the object that sends the message must be known.
	@implementationNote : This action is inserted into array 1 position before the last action, so this action will be evaluated before the (currently) last action is called.
	@todo : Test if the queue removes itself as listener.
	*/
	public function addPauseUntilMessage(inSender:Object,
										 inMessage:String,
										 inTimeOutDuration:Number,
										 inTimedOutObject:Object,
										 inTimedOutFunctionName:String) : Void {
		var o:ExtendedActionQueueData = new ExtendedActionQueueData();
		o.type = MESSAGE_TYPE;
		o.sender = inSender;
		o.message = inMessage;
		o.timeOutDuration = inTimeOutDuration * 1000; // translate to milliseconds
		o.timedOutObject = inTimedOutObject;
		o.timedOutFunctionName = inTimedOutFunctionName;
		arguments.splice(0,5);
		o.timedOutArgs = arguments;
		mActions.splice(mActions.length - 1, 0, o);
		
		/*-----------------------------------------------------------------------------
		Note with this implementation:
		1)	This action MUST be evaluated BEFORE the action that can trigger the message. Therefore this action is inserted one position before the last action in the queue.
		2)	But to pause the queue, we cannot tell the queue to pause, or the next action (that will trigger the message eventually) is never run.
		I've chosen to set a variable 'willPause', that will be checked by every message action. The next action to run will find the willPause is set to true, and will pause the action queue.
		
		In short:
		1)	The current message action will be run first, setting up the message handler.
		2)	The former last action will be run next. This action will possibly cause a message to be sent. For example, the object method
			'loadXML' will cause the message 'onXMLLoaded' to be sent.
			When the action queue runs this action, and finds willPause == true, the action queue will be set to paused.
			Therefore:
		*/
		
		var lastAction:Object = mActions[mActions.length - 1];
		lastAction.willPause = true;
	}
	
	/**
	Makes the queue pause until a condition is met.
	This method makes use of {@link Watcher}.
	@param inVariableToWatchOwner : object that owns the variableToWatch variable; this can be _root for instance or some object
	@param inVariableToWatchName : variable or function that returns a variable; for a function you must pass its name
	@param inCheckForValue : value that the variableToWatch is measured against
	@param inIntervalDuration : time duration between each check; duration in seconds
	@usageNote : Watcher's shouldRepeat is automatically set to true: the variable is checked indefinitely until variableToWatch is equal to checkForValue, or until {@link ActionQueue#skip} is called.
	@implementationNote : This action is inserted into array 1 position before the last action, so this action will be evaluated before the (currently) last action is called.
	@implementationNote : The queue will be paused automatically.
	*/
	public function addPauseUntilCondition(inVariableToWatchOwner:Object,
										   inVariableToWatchName:String,
										   inCheckForValue:Object,
										   inIntervalDuration:Number) : Void {
		var o:ExtendedActionQueueData = new ExtendedActionQueueData();
		o.type = CONDITION_TYPE;
		o.isPaused = true; // <---
		o.variableToWatchOwner = inVariableToWatchOwner;
		o.variableToWatch = inVariableToWatchName;
		o.checkForValue = inCheckForValue;
		o.intervalDuration = inIntervalDuration;
		mActions.splice(mActions.length - 1, 0, o);
	}
	
	/**
	Continues the (paused) queue when a condition is met.
	Use this method when the queue is paused or occupied indefinitely.
	This method makes use of {@link Watcher}.
	@param inVariableToWatchOwner : object that owns the variableToWatch variable; this can be _root for instance or some object
	@param inVariableToWatchName : variable or function that returns a variable
	@param inCheckForValue : value that the variableToWatch is measured against; a number or string for example
	@param inIntervalDuration : time duration between each check; duration in seconds
	@usageNote : Watcher's shouldRepeat is automatically set to true: the variable is checked indefinitely until variableToWatch is equal to checkForValue, or until {@link ActionQueue#skip} is called.
	@implementationNote : This action is inserted into the array 1 position before the last action, so this action will be evaluated before the (currently) last action is called.
	@example
	This example halts the queue until 6 characters are typed into an InputField:
	<code>
	// Wait indefinitely ...
	queue.addPause( 0 );	
	// Until 6 characters are typed into the name field
	// Check each tenth of a second
	queue.addContinueOnCondition( _root.namefield, "length", 6, 0.1 );
	</code>
	*/
	public function addContinueOnCondition(inVariableToWatchOwner:Object,
										   inVariableToWatchName:String,
										   inCheckForValue:Object,
										   inIntervalDuration:Number) : Void {
		var o:ExtendedActionQueueData = new ExtendedActionQueueData();
		o.type = CONDITION_TYPE;
		o.isPaused = false; // <---
		o.variableToWatchOwner = inVariableToWatchOwner;
		o.variableToWatch = inVariableToWatchName;
		o.checkForValue = inCheckForValue;
		o.intervalDuration = inIntervalDuration;
		mActions.splice(mActions.length - 1, 0, o);
	}
	
	/**
	
	*/
	public function toString () : String {
		return "; ExtendedActionQueue " + mName;
	}
	
	// -------------------------------------------------------------------------
	//	PRIVATE METHODS
	// -------------------------------------------------------------------------
	
	/**

	*/
	private function AQstop () : Void {
		mWatcher.die();
		delete mWatcher;
		clearInterval(mMessageInterval);
		super.AQstop();
	}
	
	/**
	
	*/
	private function AQstopWatcher () : Void {
		mWatcher.die();
		delete mWatcher;
	}
	
	/**
	
	*/
	private function AQexecuteTimedOutFunction (inObject:Object,
												inFunctionName:String) : Void {
		if (_global.DEBUG) {
			trace("AQexecuteTimedOutFunction");
		}
		arguments.splice(0,2);
		var storedIvalContainer:Object = arguments[0];
		clearInterval(storedIvalContainer.ival);
		delete storedIvalContainer;
		arguments.splice(0,1);
		inObject[inFunctionName].apply(inObject, arguments);
		updateAfterEvent(); // necessary after a setInterval
		mWorker.stopOnEnterFrame();
	}
	
	/**
	Copies the elements of mActionsCopy at the beginning of mActions
	*/
	private function AQcopyLoopActions () : Void {
		mActions = mActionsCopy.concat(mActions);
		mActionsCopy = new Array();
	}
	
	/**

	*/
	private function AQnext (o:ExtendedActionQueueData) : Void {
		super.AQnext(o);
	}
	
	/**
	Sets various state variables according to the action type.
	@sends ActionQueueEvent#QUEUE_LOOP_STARTED
	@sends ActionQueueEvent#QUEUE_LOOP_REWOUND
	@sends ActionQueueEvent#QUEUE_LOOP_FINISHED
	*/
	private function AQhandleState (o:ExtendedActionQueueData) : Void {
	
		switch(o.type) {
		
			case MESSAGE_TYPE:
				var ref:ActionQueue = this;
				// Time out
				var timeOut_ival:Number;
				if (o.timeOutDuration > 0) {
					var timedOut:Function = function() {
						clearInterval(timeOut_ival);
						ref.skip();
					};
					if (o.timedOutFunctionName != undefined) {							
						// Timeout function is specified: ActionQueue will execute it and call skip()
						var storedIvalContainer:Object = new Object(); // storage object for interval id
						timeOut_ival = setInterval(this,
												   "AQexecuteTimedOutFunction",
												   o.timeOutDuration,
												   o.timedOutObject,
												   o.timedOutFunctionName,
												   storedIvalContainer,
												   o.timedOutArgs);
						// store interval id for retrieval in AQexecuteTimedOutFunction
						storedIvalContainer.ival = timeOut_ival;
					} else {
						// Use default timeout function
						timeOut_ival = setInterval(timedOut, o.timeOutDuration);
					}
				}
				mWorker[o.message] = function() {
					var result:Boolean = o.sender.removeEventListener(this);
					if (_global.DEBUG) {
						trace("ActionQueue - removeListener from " + o.sender);
					}
					clearInterval(timeOut_ival);
					this.stopOnEnterFrame();
				};
				o.sender.addEventListener(o.message, mWorker);
				if (o.willPause == true) {
					// keep the mWorker occupied, so the action queue will stop here until the message is received
					// or the timeout is called:
					mWorker.idle();
				}
				break;
				
			case CONDITION_TYPE:
				if (o.isPaused == true) {
					// keep the mWorker occupied, so the action queue will stop here until the message is received
					// or the timeout is called:
					mWorker.idle();
				}
				mWatcher.die();
				delete mWatcher;
				mWatcher = new Watcher(o.variableToWatchOwner,
									   o.variableToWatch,
									   o.checkForValue,
									   o.intervalDuration,
									   true);
				mWatcher.setAfterMethod(this, "AQstopWatcher");
				mWatcher.start();
				break;
				
			case START_LOOP_TYPE:
				mIsLooping = true;
				mLoopCount = 0;
				dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_LOOP_STARTED, mName));
				break;
				
			case END_LOOP_TYPE:
				mLoopCount++;
				if (mIsLooping) {
					AQcopyLoopActions();
					dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_LOOP_REWOUND, mName, mLoopCount));
				} else {
					dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_LOOP_FINISHED, mName, mLoopCount));
				}
				break;
			// case ACTION_TYPE: nothing
		}
	}
	
	/**
	
	*/
	private function AQapplyAction (o:ExtendedActionQueueData) : Boolean {
		
		if (mIsLooping) {
			mActionsCopy.push(o);
		}
		
		AQhandleState(o);
		
		var result:Boolean = super.AQapplyAction(ActionQueueData(o));
		if (o.willPause) {
			// keep the mWorker occupied, so the action queue will stop here
			// until the message is received or the timeout is called
			mWorker.idle();
			result = false;
		}
		return result;
	}
	
}
