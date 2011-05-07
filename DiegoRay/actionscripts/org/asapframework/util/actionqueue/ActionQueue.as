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

import org.asapframework.events.Dispatcher;
import org.asapframework.util.actionqueue.ActionQueueData;
import org.asapframework.util.actionqueue.ActionQueueEvent;
import org.asapframework.util.actionqueue.ActionQueuePerformData;
import org.asapframework.util.actionqueue.AQWorker;
import org.asapframework.util.debug.Log;
import org.asapframework.util.framepulse.FramePulse;
import org.asapframework.util.framepulse.FramePulseEvent;

/**
Scripted animation and function flow class. ActionQueue stores and runs a series of functions/methods one after the other. You can call local functions, object methods and special movieclip control methods, such as timed "fade", "move" or "pulse" functions.
	ActionQueue is handy when you need timed animation, state transitions, complex button behavior or a series of functions that need to wait for a certain condition before they are run. You can insert waiting for messages or variable conditions (see {@link ExtendedActionQueue}).
	The most common use for ActionQueue is to manipulate movieclips.

	<b>Adding actions to the queue</b>
	{@link #addAction} (<code>myFunction</code>) : Adds a (locally scoped) function or an anonymous function.
	{@link #addAction} (<code>myObj, myMethod</code>) : Adds an object's method.
	{@link #addAction} (<code>myObj, myMethodName</code>) : Adds an object's method by using the method's name. The object's method does not have to be known at the time that it is added to the queue.
	{@link #addAction} (<code>myAQAction</code>) : Adds a custom movieclip action from one of the AQxxx classes; use fade, scale, move, etcetera. See the list of available action methods at addAction, or create your own action method.
	{@link #addInAction}: As addAction, but in a separately spawned thread; this eliminates the need to create separate methods and queues for movieclip actions that should occur at the same time.
	
	See also the method list summary.

	<b>On effects</b>
	ActionQueue 'AQ' methods such as {@link AQScale#scale} may use Flash' easing effects from mx.transitions.easing. You can use the default mx.transitions.easing effects, or define your own.
	
Example with mx.transitions.easing.Elastic:
<code>
import mx.transitions.easing.*;
queue.addAction( AQScale.scale, my_mc, 1, null, null, 100, 100, Elastic.easeIn );
</code>

	<b>Advanced Queue functions</b>
	To use conditional messages, conditions and looping, use {@link ExtendedActionQueue}.
	
	<b>Simultaneous effects</b>
	To control different movieclip aspects at the same time, for instance to move a clip and fade it out, use {@link #addInAction}, or use {@link AQReturnValue} (example given below at {@link #addAction}).

	@author Arthur Clemens
	@use
	This code example demonstrates a combination of ActionQueue methods, to give an idea of how this class can be used in an application.
	<code>
	import org.asapframework.util.actionqueue.*;
	import mx.transitions.easing.*;
	</code>
	Create the ActionQueue instance:
	<code>
	var queue:ActionQueue = new ActionQueue();
	</code>
	With addAction you can use methods from AQSet to set properties of movieclips:
	<code>
	queue.addAction( AQSet.setAlpha, circle_mc, 75 );
	queue.addAction( AQSet.centerOnStage, circle_mc );
	queue.addAction( AQMove.move, circle_mc, 4, null, null, 0, 0, Bounce.easeInOut);
	</code>
	To add a pause, use <code>addPause(number of seconds)</code>, where 0 means wait forever - indefinite pauses can be terminated by {@link #skip}, {@link ExtendedActionQueue#addContinueOnMessage} and {@link ExtendedActionQueue#addContinueOnCondition}.
	<code>
	queue.addPause( 0.5 );
	queue.addAction( AQFade.fade, circle_mc, 2, null, 100, Regular.easeIn );
	</code>
	All actions are added. Now let them perform:
	<code>
	queue.run();
	</code>
	<hr />
	We decide to let the button pulse, to indicate that the button has primary focus.
	We create a pulse queue in the button class:
	<code>
	import org.asapframework.util.actionqueue.*;
	
	class LoadButton extends MovieClip {
	
		private var mQueue:ActionQueue;
		
		public function activate () : Void {
			mQueue = new ActionQueue();
			// pulse with infinite duration:
			var duration:Number = 0;
			mQueue.addAction( AQPulse.pulse, this, null, 0.5, 100, 40, 100, duration );
			mQueue.run();
		}
		
		public function deactivate () : Void {
			mQueue.quit();
		}
	}
	</code>
	
	@see ExtendedActionQueue
	@see AQAddMove
	@see AQBlink
	@see AQColor
	@see AQCurve
	@see AQFade
	@see AQFollowMouse
	@see AQMove
	@see AQMoveRel
	@see AQProperty
	@see AQPulse
	@see AQReturnValue
	@see AQRotate
	@see AQScale
	@see AQSet
	@see AQSpring
	@see AQTimeline
	@see AQZoom
*/

class org.asapframework.util.actionqueue.ActionQueue extends Dispatcher {
	
	private var mFramePulse:FramePulse;
	private var mActions:Array;
	private var mLoopCount:Number;
	private var mName:String;
	private var mWorker:AQWorker;
	private var mIsPaused:Boolean;
	
	// types
	private var ACTION_TYPE:Number = 0;
	
	/**
	Calculates the relative value between start and end of a function at moment inPercentage in time. For instance with a movieclip that is moved by a function from A to B, <code>relativeValue</code> calculates the position of the movieclip at moment inPercentage.
	@param inStart : the start value of the object that is changing, for instance the start _x position
	@param inEnd : the end value of the object that is changing, for instance the end _x position
	@param inPercentage: the current moment in time expressed as a percentage value
	@return The relative value between inStart and inEnd at moment inPercentage.
	@implementationNote: The used calculation is <code>inStart + (inPercentage * (inEnd - inStart))</code>
	@example
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
	public static function relativeValue (inStart:Number, inEnd:Number, inPercentage:Number) : Number {
		return inStart + (inPercentage * (inEnd - inStart));
	}
	
	/**
	Creates and initializes a new ActionQueue object.
	@param inName : (optional) unique identifying name for the queue
	@usageNote When an ActionQueue performs a function on an object or movieclip, the queue will keep on executing when the object is deleted. And because the reference to the queue still exists, the object will stay alive as long as the queue is active. This will lead to a memory leak. So when you delete an object, you are also responsible yourself for deleting the queue.
	@example
	<code>
	public function onActionQueueStarted (e:ActionQueueEvent) : Void {
		Log.debug("queue " + e.name + " has started");
	}
	public function onActionQueueFinished (e:ActionQueueEvent) : Void {
		Log.debug("queue " + e.name + " has finished");
	}
	</code>
	<code>
	var queue:ActionQueue = new ActionQueue( "main queue" );
	queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
	queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);
	</code>
	<hr />
	If you don't need a queue status report you can create a queue in a more simple way:
	<code>
	var queue:ActionQueue = new ActionQueue();
	</code>
	*/
	function ActionQueue (inName:String) {
		super();

		mFramePulse = FramePulse.getInstance();
		mActions = new Array();
		mName = (inName != undefined) ? inName : "anonymous ActionQueue";
		mWorker = new AQWorker(inName);
		mIsPaused = false;
	}
	
	/**
	Overloaded method that accepts a number of argument configurations.

	<b>Adding a function</b>
	Will be called in local scope.
	<code>public function addAction ( inFunction:Function, argument1, argument2, ... ) : ActionQueue</code>

	<b>Adding a object's method</b>
	Will be called in the object's scope.
	<code>public function addAction ( inMethodObject:Object, inMethod:Function, argument1, argument2, ... ) : ActionQueue</code>
	
	<b>Adding a object's method by name</b>
	Will be called in the object's scope.
	<code>public function addAction ( inMethodObject:Object, inMethodName:String, argument1, argument2, ... ) : ActionQueue</code>
	
	<b>Adding an action that will perform a function on an onEnterFrame</b>
	Such as movieclip control methods (like {@link AQMove#move}) (will be called in {@link AQWorker AQWorker's} scope).
	<code>public function addAction ( inFunction:Function, argument1, argument2, ... ) : ActionQueue</code>
	The function inFunction should return a {@link ActionQueuePerformData} object.
	@example
	<b>Add a Custom interface/movieclip control method</b>
	
	Use any function that returns a {@link ActionQueuePerformData}, or use one of the ready made class metods from these classes:
	{@link AQAddMove}
	{@link AQBlink}
	{@link AQColor}
	{@link AQFade}
	{@link AQFollowMouse}
	{@link AQMove}
	{@link AQMoveRel}
	{@link AQPulse}
	{@link AQReturnValue}
	{@link AQScale}
	{@link AQSet}
	{@link AQSpring}
	{@link AQTimeline}
	
	This example will move a movieclip from its current position (null, null) to a new position (500, the current y value), during 1 second:
	<code>
	queue.addAction( AQMove.move, my_mc, 1, null, null, 500, null );
	</code>
	This example sets the alpha property of a movieclip to 50:
	<code>
	queue.addAction( AQSet.setAlpha, my_mc, 50 );
	</code>
	
	<hr />
	
	You can also create a <b>custom function</b> and pass this to the queue. This is especially useful when you need to have more complex interaction with the objects to control.
	
	Follows an example of a function that is very similar to AQxxx class methods, and is in fact copied from {@link AQMove#move} - with the difference that we want to fade out the movieclip while it is moving.
	<code>
	// somewhere in your class
	public function moveAndFade (inMC:MovieClip,
								 inDuration:Number,
								 inStartX:Number,
								 inStartY:Number,
								 inEndX:Number,
								 inEndY:Number,
								 inEffect:Function ) : ActionQueuePerformData {

		// initalize variables here
		
		var performFunction:Function = function (inPerc:Number) : Boolean {
			// do something with the received inPerc
			return true;
		};
		
		// Set up the data so ActionQueue will perform the function performFunction:
		var startValue:Number = 1.0; // counting from 1 down to 0
		var endValue:Number = 0;
		return new ActionQueuePerformData( performFunction, inDuration, startValue, endValue, inEffect );
	}
	</code>
	Note that <code>performFunction</code> returns a Boolean. To abort <code>performFunction</code> let it return false.
	
	Now you add the function to the queue using addAction:
	<code>
	var queue:ActionQueue = new ActionQueue();
	queue.addAction( this, moveAndFade, my_mc, 5, null, null, 500, 200, Regular.easeInOut );
	queue.run();
	</code>
	
	*/
	public function addAction () : ActionQueue {

		var firstParam = arguments[0];
		
		var args:Array = arguments;
		if (firstParam instanceof Array) {
			// when sent from addInAction
			args = firstParam;
			firstParam = args[0];
		}


		if (typeof firstParam == "function") {
			return AQaddFunction(args);
		}
		
		if (firstParam instanceof Object) {
			if (typeof args[1] == "string") {
				// method name
				return AQaddMethod(args);
			}
			// else scoped object with function reference
			args.shift();
			return AQaddObjectMethod(firstParam, args);
		}
	}
	
	/**
	addInAction stands for 'add Instant Action'. This method adds interface control method to the queue that is performed <b>immediately</b> as it processed by the queue (as soon as Flash triggers a new onEnterFrame). In contrast to {@link #addAction}, the queue won't wait for the end of this method. This eliminates the need to create separate methods and queues for movieclip actions that should occur at the same time.
	See for parameters and usage at {@link #addAction}.
	@return <b>The internally created ActionQueue</b> -  this is useful when you need to end an eternal queue.
	@example
	The following code lets the movieclip 'ball_mc' move to a certain point, then simultaneously fades out the clip and clip 'square_mc':
	<code>
	queue.addAction( AQMove.move, ball_mc, 1, null, null, 500, null );
	queue.addInAction( AQFade.fade, square_mc, 2, null, 0 );
	var eternalQueue:ActionQueue = queue.addInAction ( AQPulse.pulse, square_mc, null, 0.5, 100, 40, 100, 0);
	queue.addAction( this, "finishUp" );
	</code>
	Because the fading of the ball clip is part of the normal queue, the method 'finishUp' is called after ball_mc is finished fading out.
	Kill the pulsing of eternalQueue:
	<code>
	eternalQueue.quit();
	</code>
	@implementationNote A separate internal queue is created inside an anonymous function, and this function is added to the external queue. This queue is set to run and cleans up after itself.
	*/
	public function addInAction () : ActionQueue {
	
		return AQaddInAction(arguments);
    }
	
	/**
	Inserts an ActionQueue that is run immediately as it is processed in the queue. <code>insertQueue</code> is similar to {@link #insertQueueActions}, with the difference that param <code>inActionQueue</code> will be run independently of the current queue. 
	@param inActionQueue : the ActionQueue to be inserted an run
	@return The newly inserted queue inActionQueue.
	@example
	<code>
	var queue1:ActionQueue = new ActionQueue();
	queue1.addAction( this, "write", "A" );
	queue1.addAction( this, "write", "B" );
	
	var queue2:ActionQueue = new ActionQueue();
	</code>
	Adding a pause will cause the 'write' actions of queue2 to be ran after the actions of queue1 have been finished:
	<code>
	queue2.addPause(1);
	queue2.addAction( this, "write", "C" );
	queue2.addAction( this, "write", "D" );
	
	queue1.insertQueue( queue2 );
	queue1.addAction( this, "write", "E" );
	queue1.run();
	</code>
	Output: ABE, and somewhat later: CD
	<hr />
	The following example shows a combined effect of fading in and zooming in, where the fading is started exactly halfway the zooming:
	<code>
	var duration:Number = 0.4;
	var queue = new ActionQueue();
	queue.insertQueue( new ActionQueue().addPause(duration/2).addAction( AQFade.fade, my_mc, 1.0, null, 100 ) );
	queue.addAction( AQZoom.zoom, my_mc, duration );
	queue.run();
	</code>
	*/
	public function insertQueue (inActionQueue:ActionQueue) : ActionQueue {		
		var f:Function = function () : Void {
			inActionQueue.run(); // default: clean up after running
		};
		addFunction(f);
		return inActionQueue;
	}
	
	/**
	Inserts the actions of inActionQueue in the current queue. <code>insertQueueActions</code> is similar to {@link #insertQueue}, with the difference that the actions that will be added to the current queue will be performed after the action of param <code>inActionQueue</code> - the order of performed actions will not change.
	@param inActionQueue : the ActionQueue which actions are inserted
	@return The current ActionQueue.
	@example
	<code>
	var queue1:ActionQueue = new ActionQueue();
	queue1.addAction( this, "write", "A" );
	queue1.addAction( this, "write", "B" );
	
	var queue2:ActionQueue = new ActionQueue();
	</code>
	Adding a pause will not make a difference in the output, as the pause will also be added to the actions of queue1:
	<code>
	queue2.addPause(1);
	queue2.addAction( this, "write", "C" );
	queue2.addAction( this, "write", "D" );
	
	queue1.insertQueue( queue2 );
	queue1.addAction( this, "write", "E" );
	queue1.run();
	</code>
	Output: ABCDE
	*/
	public function insertQueueActions (inActionQueue:ActionQueue) : ActionQueue {
		mActions = mActions.concat(inActionQueue.actions());
		return this;
	}
	
	/**
	Adds a pause to the queue. The next action in the queue will be called after the duration of the pause.
	@param inDuration : pause duration in seconds. Use 0 to pause the queue indefinitely.
	@return The current ActionQueue.
	@example
	This example will pause the queue forever (until {@link #skip} or {@link ExtendedActionQueue#addContinueOnMessage} or {@link ExtendedActionQueue#addContinueOnCondition} is called).
	<code>
	queue.addPause( 0 );
	</code>
	*/
	public function addPause (inDuration:Number) : ActionQueue {
		addAction(mWorker, "wait", inDuration);
		return this;
	}
	
	/**
	Starts the queue for the first time.
	@param inKeepAlive : If true, further actions can be appended after running; default false: the thread will clean up after itself automatically, and no more actions can be added.
	@return The current ActionQueue.
	@sends ActionQueueEvent#QUEUE_STARTED
	*/
	public function run (inKeepAlive:Boolean) : ActionQueue {
		if (inKeepAlive != true) {
			addAction(this, "AQQuit");
		}
		AQStartOnEnterFrame();
		mWorker.start();
		dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_STARTED, mName));
		return this;
	}
	
	/**
	Stops and deletes the queue.
	@return The current ActionQueue.
	@sends ActionQueueEvent#QUEUE_QUIT
	*/
	public function quit () : ActionQueue {
		AQstop();
		AQCleanUp();
		dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_QUIT, mName));
		return this;
	}
	
	/**
	Pauses the queue in the middle of an action. The action can be resumed by calling {@link #play}. {@link #pause} breaks in into a queue and must not be confused with {@link #addPause}, that inserts a waiting time in between actions.
	@param inTimerShouldContinue : (optional) if true, the timer continues counting to the set end time; default value is false: the time left is stored and added to the current time when playing is resumed with {@link #play}
	@return The current ActionQueue.
	@sends ActionQueueEvent#QUEUE_PAUSED
	*/
	public function pause (inTimerShouldContinue:Boolean) : ActionQueue {
		mWorker.pause(inTimerShouldContinue);
		mIsPaused = true;
		dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_PAUSED, mName));
		return this;
	}
	
	/**
	Resumes the queue after {@link #pause}. The queue will resume with the stored action where it was left, including animations.
	@return The current ActionQueue.
	@sends ActionQueueEvent#QUEUE_RESUMED
	*/
	public function play () : ActionQueue {
		if (mIsPaused) {
			mWorker.resume();
			mIsPaused = false;
			dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_RESUMED, mName));
		}
		return this;
	}
	
	/**
	Erases the queued actions and stops the queue. New actions can be added and the queue can be restarted with {@link #run}.
	@return The current ActionQueue.
	@example
	In this example a queue belonging to one button (scale_btn) is cleared by pressing another button (clear_btn). After that a new action is added and run.
	<code>
	import mx.transitions.easing.*;
	
	scale_btn.startScale = function () {
		var queue:ActionQueue = new ActionQueue();
		this.queue = queue;
		this.queue.addAction( AQScale.scale, scale_mc, 5, null, null, 400, 400, Regular.easeOut );
		// possibly other actions...
		this.queue.run(true); // note: keepAlive set to true
	}
	clear_btn.onPress = function() {
		scale_btn.queue.clear();
		// add a new method to scale down again
		scale_btn.queue.addAction( AQScale.scale, scale_mc, 1, null, null, 100, 100, Regular.easeOut );
		scale_btn.queue.run(true); // note: keepAlive set to true
	}
	</code>
	*/
	public function clear () : ActionQueue {
		AQstop();
		delete mActions;
		mActions = new Array();
		return this;
	}
	
	/**
	Skips over the current action and calls the next action in the queue.
	@return The current ActionQueue.
	@example
	<code>
	
	var queue:ActionQueue = new ActionQueue();
	queue.addAction( AQFollowMouse.followMouse, square_mc, 0.1, 0.9); // will not end out of itself
	queue.addAction( AQFade.fade, square_mc, 2.0, null, 0 );	
	queue.run();
	
	// Clicking the skip_btn will stop the followMouse and fade out square_mc 
	skip_btn.onRelease = function() {
		queue.skip();
	}
	</code>
	*/
	public function skip () : ActionQueue {
		mWorker.stopOnEnterFrame();
		return this;
	}
	
	/**
	The number of items in the queue; for debugging purposes.
	*/
	public function get count () : Number {
		return mActions.length;
	}
	
	/**
	Queries the active state of the queue.
	@return Whether the ActionQueue is performing any action: true when running or paused, false when the queue is empty.
	@example
	Example of a pause toggle button that uses isBusy to check if the queue should be ordered to run or to pause:
	<code>
	pause_btn.onRelease = function() {
		if (queue.isBusy()) {
			if (queue.isPaused()) {
				queue.play();
			} else {
				queue.pause();
			}
		} else {
			queue.run();
		}
	}
	</code>
	*/
	public function isBusy () : Boolean {
		return mWorker.isBusy();
	}
	
	/**
	@return The array of action objects.
	*/
	public function actions () : Array {
		return mActions;
	}

	/**
	@return The identifier name of the queue; for debugging purposes.   
	*/
	public function name () : String {
		return mName;
	}
	
	/**
	Retrieves the paused state of the queue. The queue can be pause using {@link #pause} and restarted using {@link #play}.
	@return Whether the queue is paused (true) or not (false).
	*/
	public function isPaused () : Boolean {
		return mIsPaused;
	}
	
	/**
	
	*/
	public function toString () : String {
		return "; ActionQueue " + mName;
	}
	
	// DEPRECATED METHODS
	
	/**
	@deprecated As of 3 Feb 2006. Use {@link #addAction}. 
	*/
	public function addAQMethod (inMethod:Object) : ActionQueue {
		return AQaddFunction(arguments);
	}
	
    /**
	@deprecated As of 3 Feb 2006. Use {@link #addInAction}.
    */
	public function addInAQMethod (inFunction:Object) : ActionQueue {
		return AQaddInAction(arguments);
    }
    
	/**
	Adds a (locally scoped) function or reference (or an anonymous function) to a object's method to the queue.
	@deprecated As of 3 Feb 2006. Use {@link #addAction}.
	*/
	public function addFunction (inFunctionRef:Function) : ActionQueue {
		var args:Array = arguments;
		return addAction(args);
	}
	
	/**
	Adds an object's method to the queue, by using the method's name. This way the object's method does not have to be known at the time that it is added to the queue.
	@deprecated As of 3 Feb 2006. Use {@link #addAction}.
	*/
	public function addMethod (inObject:Object,
							   inMethodName:String) : ActionQueue {
		
		// switch inObject and inMethodName
		var args:Array = arguments;
		return AQaddMethod(args);
	}
	
	/**
	Cleans up the ActionQueue object after use, when the queue has been emptied. After this call no more actions can be added. Use this method after the last action.
	@deprecated: Use {@link #run}.
	*/
	public function addCleanup () : ActionQueue {
		addAction(this, "quit");
		return this;
	}
	
	// PRIVATE METHODS
	
	/**
	@sends ActionQueueEvent#QUEUE_STOPPED
	*/
	private function AQstop () : Void {
		AQStopOnEnterFrame();
		mWorker.stop();
		dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_STOPPED, mName));
	}
	
	/**
	Quits the queue.
	@sends ActionQueueEvent#QUEUE_FINISHED
	@sends ActionQueueEvent#QUEUE_QUIT
	*/
	public function AQQuit () : ActionQueue {
		AQstop();
		AQCleanUp();
		dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_FINISHED, mName));
		dispatchEvent(new ActionQueueEvent(ActionQueueEvent.QUEUE_QUIT, mName));
		return this;
	}
	
	/**
	Cleans up the queue.
	*/
	private function AQCleanUp () : Void {
		delete mWorker;
		delete mActions;
		delete this;
	}
	
	/**
	
	*/
	private function AQStartOnEnterFrame () : Void {
		mFramePulse.addEventListener(FramePulseEvent.ON_ENTERFRAME, this);
	}
	
	/**
	
	*/
	private function AQStopOnEnterFrame () : Void {
		mFramePulse.removeEventListener(FramePulseEvent.ON_ENTERFRAME, this);
	}
	
	/**
	
	*/
	private function AQNextAction () : Void {
		mWorker.stopOnEnterFrame();
	}
	
	/**
	@return The current ActionQueue.
	*/
	private function AQaddFunction (inArgs:Array) : ActionQueue {
		var functionReference:Object = inArgs.shift();
		var o:ActionQueueData = new ActionQueueData();
		o.type = ACTION_TYPE;
		o.obj = mWorker;
		o.args = inArgs;
		o.func = Function(functionReference);
		mActions.push(o);
		return this;
	}
	
	/**
	@return The current ActionQueue.
	*/
	private function AQaddMethod (inArgs:Array) : ActionQueue {

		var methodObject:Object = inArgs.shift();
		var methodName:String = String(inArgs.shift());

		var o:ActionQueueData = new ActionQueueData();
		
		o.type = ACTION_TYPE;
		o.obj = methodObject;
		o.mname = methodName;
		o.args = inArgs;
		o.func = methodObject[methodName];
		if (o.func == undefined) {
			Log.warn("AQaddMethod - Could not resolve method " + methodName + " at this time.", toString());
		}
		mActions.push(o);
		return this;
	}
	
	/**
	@return The current ActionQueue.
	*/
	private function AQaddObjectMethod (inFunctionOwner:Object, inArgs:Array) : ActionQueue {
		
		var func:Function = Function(inArgs.shift());
		var o:ActionQueueData = new ActionQueueData();
		o.type = ACTION_TYPE;
		o.obj = inFunctionOwner;
		o.args = inArgs;
		o.func = func;
		if (o.func == undefined) {
			Log.warn("AQaddObjectMethod - Could not resolve method " + func + " at this time.", toString());
		}
		mActions.push(o);
		return this;
	}
	
	/**
	@return The current ActionQueue.
	*/
	private function AQaddInAction (inArgs:Array) : ActionQueue {
    
		var queue:ActionQueue = new ActionQueue();
		var f:Function = function () : Void {
			queue.addAction( inArgs );
			queue.run();
		};
		addAction(f);
		return queue;
    }
	
	/**
	onEnterFrame is called every enter frame
	          |
	          -> calls AQnext => while loop is used here whenever possible to bypass onEnterFrame, and AQapplyAction is called instead
	                    |
	                    -> calls AQapplyAction
	                                   |
                    	               -> calls the action
	               
	Calls {@link #AQstop} when no more actions are in the list.
	@param inEvent: not used
	*/
	public function onEnterFrame (inEvent:FramePulseEvent) : Void {
		if (!mWorker.onEnterFrame) {
			if (mActions.length == 0) {
				AQstop();
				return;
			}
			// get the next action
			AQnext( ActionQueueData(mActions.shift()) );
		}
	}
	
	/**
	
	*/
	private function AQnext (o:ActionQueueData) : Void {
		
		// For performance, try to loop through the array as long as possible.
		while (o && !AQapplyAction(o)) {
			o = ActionQueueData(mActions.shift());
		}
	}
	
	/**
	@return The called method's return value: in case of an AQMethod, the called function will return true if it has an onEnterFrame. If so, ActionQueue must pass an onEnterFrame itself.
	*/
	private function AQapplyAction (o:ActionQueueData) : Boolean {
				
		if (o.func == undefined) {
			// try to resolve the method now
			o.func = o.obj[o.mname];
		}
		var performData:ActionQueuePerformData;
		// returnValue will be true if the called function returns true
		// this happens for AQxxx methods with an onEnterFrame 
		performData = ActionQueuePerformData(o.func.apply(o.obj, o.args));
		if (performData != undefined && performData instanceof ActionQueuePerformData) {
			mWorker.returnValue(performData);
			return true;
		}
		return false;
	}
	
}