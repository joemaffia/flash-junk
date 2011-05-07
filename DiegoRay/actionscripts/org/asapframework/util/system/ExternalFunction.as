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
import org.asapframework.events.Dispatcher;
import org.asapframework.util.debug.Log;
import org.asapframework.util.system.ExternalFunctionEvent;


/**
	@author Martijn de Visser 
	@description Class to create handler with, allowing for communication between Javascript and Flash.
	This class will fire evens that you can listen to. The events fired will have the same name as they have in Javascript.
	@usage 
	In Flash, import and instantiate ExternalEvent class:
	<code>
import org.asapframework.util.system.ExternalFunction;
import org.asapframework.util.system.ExternalFunctionEvent;

var mExtFunc:ExternalFunction = ExternalFunction.getInstance();
mExtFunc.addEventListener("myCustomEvent", this);

var myCustomEvent:Function = function ( e:ExternalFunctionEvent ) {	
	// code goes here...
}
	</code>
	In your Javascript file (to load in the embedding HTML file), add the following function:
	<code>
function flashEvent(inSwf, inEvent, inParams) {	
	
	var divcontainer = "flash_setvariables_" + inSwf;	
	if(!document.getElementById(divcontainer)){
		var divholder = document.createElement("div");
		divholder.id = divcontainer;
		document.body.appendChild(divholder);
	}
	var divinfo = "<embed src='swf/gateway.swf' FlashVars='lc=" + inSwf + "&ev=" + escape(inEvent) + "," + escape(inParams) + "' width='0' height='0' type='application/x-shockwave-flash'></embed>";
	document.getElementById(divcontainer).innerHTML = "";
	document.getElementById(divcontainer).innerHTML = divinfo;
}
	</code>
	As you can see, there is a reference here to a file named 'gateway.swf'. This file acts as an intermediary between Javascript and the ActionScript event. You can obtain a copy of this file (and the souce files) here: http://www.martijndevisser.com/download/externalfunction.zip
	Next, in HTML, call this JavaScript function and specify the event type and, optionally, a comma delimited string of parameters.
	For example:
	<code>
	<a href="javascript:flashEvent('myFlashFile', 'myCustomEvent', 'myParam1, myParam2');">test...</a>
	</code>
*/

class org.asapframework.util.system.ExternalFunction extends Dispatcher {

	private var handler:LocalConnection;
	private var lcID:String;
	private static var instance:ExternalFunction = null;
	
	/**
	*	Private constructor, use getInstance to refer to singleton instance
	*/
	private function ExternalFunction () {

		super();
		
		// get lcID to connect to
		lcID = _level0.extfunc_lc;		
		if (lcID == undefined) return;
	
		// setup localconnection and connect
		handler = new LocalConnection();
		handler.flashEvent = function ( e:String ) {
			
			// pass event to ExternalFunction
			ExternalFunction.getInstance().onFlashEvent(e);
		};
		handler.connect(lcID);
		
		// debug
		Log.debug("\n\t\t\tLocalConnection ID = '" + lcID + "'", toString());
	}
	
	/**
	*	Triggered once an event has been received, fires {@link ExternalFunctionEvent}
	@sends ExternalFunctionEvent
	*/
	public function onFlashEvent ( inEvent:String ) : Void {
	
		// parse event and parameters
		var params:Array = inEvent.split(",");
		var e:String = params[0];
		var a:Array = params.slice(1);
		
		// debug info
		Log.debug("\n\t\t\tevent: '" + e + "', " + (a.length) + " params", toString());
		
		// dispatch event
		dispatchEvent(new ExternalFunctionEvent(e,this,a));
	}
	
	/**
	*	Returns reference to singleton instance of ExternalEvent
	*/
	public static function getInstance () : ExternalFunction {
		
		if (instance == null) {
			instance = new ExternalFunction();
		}
		return instance;
	}
	
	/**
	*	Returns ID of LocalConnection
	*/
	public function get lc () : String {
		
		return lcID;
	}
	
	public function toString() : String {
		return ";org.asapframework.util.system.ExternalFunction";
	}
}
