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
import org.asapframework.util.debug.LogEvent;

/**
This class implements a simple logging functionality that dispatches an event whenever a log message is received.
The object sent with the event is of type LogEvent. The LogEvent class contains public properties for the text of the message, 
a String denoting the sender of the message,and the level of importance of the message.
By default, log messages are also output as traces to the Flash IDE output window. This behaviour can be changed.
@example:
<code>
Log.addEventListener(EventDelegate.create(this, onLogEvent));	// handle events locally
Log.showTrace(false);	// don't output log messages as traces

Log.debug("This is a debug message", toString());
Log.error("This is an error message", toString());
Log.info("This is an info message", toString());

private function onLogEvent (e:LogEvent) {
	// handle the event by showing the message as a trace
	trace(e.text);
}

public function toString () : String {
	return "TestClass";
}
</code>
This will show the following output in the Flash IDE output window:

This is a debug message
This is an error message
This is an info message

The standard trace output of the Log class looks as follows:

11	debug: This is a debug message -- TestClass
11	error: This is an error message -- TestClass
11	info: This is an info message -- TestClass

The number "11" is the time at which the log message was generated. This time is not kept in the LogEvent class.
@author stephan.bezoen
 */
 
class org.asapframework.util.debug.Log extends Dispatcher {

	// The possible levels of log messages
	public static var LEVEL_DEBUG:String = "debug";
	public static var LEVEL_INFO:String = "info";
	public static var LEVEL_WARN:String = "warn";
	public static var LEVEL_ERROR:String = "error";
	public static var LEVEL_FATAL:String = "fatal";
	public static var LEVEL_STATUS:String = "status";
 
 	
	private static var theInstance : Log;
	
	private var mDoTrace:Boolean = true;
	
	
	/**
	 * @return singleton instance of Logger
	*/
	public static function getInstance() : Log {
		if (theInstance == null)
			theInstance = new Log();
		return theInstance;
	}
	
	/**
	*	Log a message with debug level
	*	@param inText: the message
	*	@param inSender: a String denoting the source of the message; 
	*			typical toString() of the calling class
	*	@use
	*	<code>
	*	Log.debug("This is a debug message", toString());
	*	</code>
	*/
	public static function debug (inText:String, inSender:String) : Void {
		Log.getInstance().send(inText, inSender, Log.LEVEL_DEBUG);
	}
	
	/**
	*	Log a message with info level
	*	@param inText: the message
	*	@param inSender: a String denoting the source of the message; 
	*			typical toString() of the calling class
	*	@use
	*	<code>
	*	Log.info("This is an info message", toString());
	*	</code>
	*/
	public static function info (inText:String, inSender:String) : Void {
		Log.getInstance().send(inText, inSender, Log.LEVEL_INFO);
	}
	
	/**
	*	Log a message with error level
	*	@param inText: the message
	*	@param inSender: a String denoting the source of the message; 
	*			typical toString() of the calling class
	*	@use
	*	<code>
	*	Log.error("This is an error message", toString());
	*	</code>
	*/
	public static function error (inText:String, inSender:String) : Void {
		Log.getInstance().send(inText, inSender, Log.LEVEL_ERROR);
	}
	
	/**
	*	Log a message with warning level
	*	@param inText: the message
	*	@param inSender: a String denoting the source of the message; 
	*			typical toString() of the calling class
	*	@use
	*	<code>
	*	Log.warn("This is a warning message", toString());
	*	</code>
	*/
	public static function warn (inText:String, inSender:String) : Void {
		Log.getInstance().send(inText, inSender, Log.LEVEL_WARN);
	}
	
	/**
	*	Log a message with fatal level
	*	@param inText: the message
	*	@param inSender: a String denoting the source of the message; 
	*			typical toString() of the calling class
	*	@use
	*	<code>
	*	Log.fatal("This is a fatal message", toString());
	*	</code>
	*/
	public static function fatal (inText:String, inSender:String) : Void {
		Log.getInstance().send(inText, inSender, Log.LEVEL_FATAL);
	}
	
	/**
	*	Log a message with status level
	*	@param inText: the message
	*	@param inSender: a String denoting the source of the message; 
	*			typical toString() of the calling class
	*	@use
	*	<code>
	*	Log.status("This is a status message", toString());
	*	</code>
	*/
	public static function status (inText:String, inSender:String) : Void {
		Log.getInstance().send(inText, inSender, Log.LEVEL_STATUS);
	}
	
	/**
	*	Dispatch a LogEvent with the input parameters; trace if flag is set to do so
	*	@param inText: the message
	*	@param inSender: a String denoting the source of the message
	*	@param inLevel: the level of the message
	*/
	private function send (inText:String, inSender:String, inLevel:String) : Void {
		if (mDoTrace) {
			trace(getTimer() + "\t" + inLevel + ": " + inText + " -- " + inSender);
		}
		dispatchEvent(new LogEvent(inLevel, inText, inSender));
	}

	/**
	*	Add a function as listener to LogEvent events
	*	@param inFunction: the function to handle LogEvents
	*	@use:
	*	<code>
	*	Log.addLogListener(EventDelegate.create(this, onLog));
	*	
	*	private function onLog (e:LogEvent) {
	*	}
	*	</code>
	*/
	public static function addLogListener (inFunction:Function) : Void {
		Log.getInstance().addListener(inFunction);
	}
	
	/**
	*	Add a function to the event listeners
	*/
	private function addListener (inFunction:Function) : Void {
		addEventListener(LogEvent.EVENT_LOG, inFunction);
	}
	
	/**
	*	Set whether log messages should be output as a trace
	*	@param inShow: if true, log messages are output as a trace
	*	Set this to false if a log listener also outputs as a trace.
	*	@use
	*	<code>
	*	Log.showTrace(false);
	*	<code>
	*/
	public static function showTrace (inShow:Boolean) : Void {
		Log.getInstance().doShowTrace(inShow);
	}
	
	/**
	*	Set whether log messages should be output as a trace
	*	@param inShow: if true, log messages are output as a trace
	*/
	private function doShowTrace (inShow:Boolean) : Void {
		mDoTrace = inShow;
	}
}
