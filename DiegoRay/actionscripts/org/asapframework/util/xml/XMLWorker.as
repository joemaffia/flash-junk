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
import org.asapframework.events.EventDelegate;
import org.asapframework.util.framepulse.FramePulse;
import org.asapframework.util.framepulse.FramePulseEvent;
import org.asapframework.util.xml.XMLWorkerEvent;

/**
 * A worker class for XML that sends an "onXMLLoaded" message when XML has been loaded.
 * XMLWorker is used interally by {@link org.asapframework.util.xml.XMLLoader} and should not be used by itself.
 */

class org.asapframework.util.xml.XMLWorker extends Dispatcher {

	public var result:Boolean;
	public var status:Number;
	public var timeout:Number;
	public var url:String;
	public var name:String;
	public var noCache:Boolean;
	public var loaded:Boolean;		
	public var loading:Boolean;
		
	// private xml object
	private var mXML:XML;
	private var mLoadDelegate:Function;
	private var mTimeoutID:Number;
	
	private var fpulse:FramePulse;
	
	private static var TIME_OUT:Number = 10000;

	/**
	 * Creates a new XMLWorker object.
	 * @param inURL The URL of the xml file
	 * @param inName Unique identifier; this name will also be used in callback events when file was loaded or when an error was encountered.
	 * @param inNoCache If set to true, the xml file (if loaded over http, so this setting is ignored for local files) will always be fetched from the server by appending a timestamp to the call, thus circumventing the local browser cache. The URL will be extended with a param named 'asapts'.
	 * @param inTimeOut Set value to specify time to wait (in milliseconds) for a server response (excluding the download time of the actual XML data itself). Defaults to 10 seconds if no value is specified. Set to '0' to disable timeout.
	 */
	public function XMLWorker ( inURL:String, inName:String, inNoCache:Boolean, inTimeOut:Number ) {
		
		super();
		
		// store values
		url = inURL;
		name = inName;
		noCache = inNoCache;
		loaded = false;
		loading = false;
		timeout = (inTimeOut == undefined)? XMLWorker.TIME_OUT : inTimeOut;
		
		// setup framepulse (for progress monitoring)
		fpulse = FramePulse.getInstance();
		
		// setup XML loading
		mLoadDelegate = EventDelegate.create(this, onXMLloaded);
		mXML = new XML();
		mXML.ignoreWhite = true;
		mXML.onLoad = mLoadDelegate;
	}
	
	/**
	 * The XML data.
	 */
	public function get xml () : XML {
		
		return mXML;
	}
	
	/**
	 * Starts loading the XML file.
	 */
	public function load () : Void {
		
		// set flag
		loading = true;
		
		// start timeout
		if (timeout > 0) {
			setTimeout();
		}
		
		// get copy of URL (to prevent overwriting original url) and append timestamp if required.
		var tURL:String = url;
		
		// add timestamp?
		if (noCache && (tURL.substr(0,4) == "http")) {
			
			var theDate:Date = new Date();
			var stamp:String;

			// check for already present vars
			if (tURL.indexOf("?") == -1) {
				stamp = "?asapts=" + theDate.getTime();
			} else {
				stamp = "&asapts=" + theDate.getTime();
			}
			tURL += stamp;
		}
		
		// listen to events
		startListener();
		
		// load the xml file
		mXML.load(tURL);
	}
	
	/**
	 * Triggered by FramePulse class.
	 */
	public function onEnterFrame (e:FramePulseEvent) : Void {
		
		// see if we received any bytes at all so far
		var l:Number = mXML.getBytesLoaded();
		if (l != undefined && l > 0) {
		
			// clear timeout
			clearTimeout();
			
			// clear listener
			clearListener();
		}	
	}

	/**
	 * Triggered when XML has been loaded.
	 * @sends onXMLLoaded event to XMLLoader
	 */
	public function onXMLloaded ( inResult:Boolean ) : Void {
		
		// clear timeout
		clearTimeout();
		
		// stop listening to framepulse events
		clearListener();
		
		// store data
		result = inResult;
		status = mXML.status;
		loading = false;
		loaded = true;
		
		// dispatch onXMLLoaded event
		dispatchEvent(new XMLWorkerEvent(XMLWorkerEvent.ON_LOADED, this));
	}
	
	/**
	 * Triggered if no response from server was received within timeout interval.
	 * @sends onXMLTimeout event to XMLLoader
	 */
	public function onXMLTimeout () : Void {
	
		// clear the timeout
		clearTimeout();
		
		// clear listener
		clearListener();
		
		// dispatch onXMLTimeout event
		dispatchEvent(new XMLWorkerEvent(XMLWorkerEvent.ON_TIMEOUT, this));
	}
	
	/**
	 * Starts the timeout.
	 */
	private function setTimeout () : Void {
	
		clearTimeout();
		mTimeoutID = setInterval(this, "onXMLTimeout", timeout);
	}
	
	/**
	 * Clears the timeout.
	 */
	private function clearTimeout() : Void {
		
		clearInterval(mTimeoutID);
		delete(mTimeoutID);
	}
	/**
	 * Starts the FramePulse listener.
	 */
	private function startListener () : Void {		
		
		// listen to framepulse events		
		fpulse.addEventListener(FramePulseEvent.ON_ENTERFRAME, this);
	}
	
	/**
	 * Removes the FramePulse listener.
	 */
	private function clearListener () : Void {
	
		// remove listener
		fpulse.removeEventListener(FramePulseEvent.ON_ENTERFRAME, this);
	}
}