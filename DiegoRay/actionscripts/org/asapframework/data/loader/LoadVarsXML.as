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

import org.asapframework.data.loader.URLData;
import org.asapframework.events.Dispatcher;
import org.asapframework.events.Event;
import org.asapframework.events.EventDelegate;
import org.asapframework.util.debug.Log;
import org.asapframework.util.xml.XML2Object;

/**
Class to make XML based LoadVars requests with. This class will automatically parse all data to native objects and store this in the .result getter
This class can be used to load dynamic, parameter-based XML, or post forms that expect XML as response.
@see {@link DataLoader} for usage of this class. The {@link DataLoader} forms a wrapper for this class.
@use
This example code is taken from the DataLoader class:
<code>
	private function DataLoader() {
		super();

		// create xml loader with post data, listen to events
		mPostXMLLoader = new LoadVarsXML();
		mPostXMLLoader.addEventListener(LoadVarsXML.EVENT_DONE, EventDelegate.create(this, handlePostDone));
		mPostXMLLoader.addEventListener(LoadVarsXML.EVENT_ERROR, EventDelegate.create(this, handlePostError));
	}

	// Handle done event from the postXMLLoader
	private function handlePostDone () : Void {
		handleDataLoaded(mPostXMLLoader.result, mPostXMLLoader.urlData.name);
	}

	// Handle error while loading from the postXMLLoader
	private function handlePostError () : Void {
		Log.error("handlePostError: error loading '" + mPostXMLLoader.urlData.name + "'", toString());
	}

	// Handle event that data has been loaded
	private function handleDataLoaded (inData:Object, inName:String) : Void {
		Log.info("handleDataLoaded: done loading '" + mPostXMLLoader.urlData.name + "'", toString());
	}
</code>
*/

class org.asapframework.data.loader.LoadVarsXML extends Dispatcher {
	/** Types of post */
	public static var POST:String = "POST";
	public static var GET:String = "GET";
	
	private var mResult:Object;
	private var mXMLResultHandler:XML;
	private var mCallPending:Boolean;
	private var mType:String = POST;
	
	
	public static var EVENT_DONE:String = "onLoadVarsRequestDone";
	public static var EVENT_ERROR:String = "onLoadVarsRequestError";

	private var mURLData : URLData;
	
	/**
	 * Constructor (private)
	 */
	public function LoadVarsXML () {
	
		super();
		
		mCallPending = false;
		mType = LoadVarsXML.POST;
		
		// setup XML receiver
		mXMLResultHandler = new XML();
		mXMLResultHandler.ignoreWhite = true;
		mXMLResultHandler.onLoad = EventDelegate.create(this,handleRequestDone);
	}
	
	/**
	*	The URLData object as passed in the execute call
	*/
	public function get urlData () : URLData {
		return mURLData;
	}
	
	/**
	 * Executes a request
	 * @param inURLData: data block containing name and url
	 * @param inRequest: LoadVars object containing all the POST data
	 * @param inType: type of post, either POST or GET
	 * @return true if the process was started successfully, otherwise false
	 */
	public function load ( inURLData:URLData, inRequest:LoadVars, inType:String ) : Boolean {
		mURLData = inURLData;
		type = inType;
				
		// check if a call is pending
		if (mCallPending) {
			
			Log.error("Call already in progress", toString());
			return false;
		}
		 
		// create dummy LV if none was given
		if (inRequest == undefined) inRequest = new LoadVars();
		
		// set flag
		mCallPending = true;
					
		// start LoadVars sender, result will be caught by mXMLResult XML object
		return inRequest.sendAndLoad(mURLData.url, mXMLResultHandler, mType);
	}
	
	/*
	 * 	  EVENTS
	 */
	
	/**
	 * Triggered by mXMLResultHandler.
	 */
	private function handleRequestDone ( inSuccess:Boolean ) : Void {
		
		// clear pending flag
		mCallPending = false;
		
		// successful call or not?
		if (inSuccess) {
			
			// parse the data received
			mResult = XML2Object.parseXML(mXMLResultHandler, true);
			
			// send event
			dispatchEvent( new Event( LoadVarsXML.EVENT_DONE, this) );
			
		} else {
			
			// log error
			Log.error("Cannot execute request", toString());
			
			// send event
			dispatchEvent( new Event( LoadVarsXML.EVENT_ERROR, this) );
		}
	}
	
	/**
	 * The result of the operation
	 */
	public function get result () : Object {
		return mResult;
	}
	
	/**
	 * True if a call is already being exeuted
	 */
	public function get pending () : Boolean {
		return mCallPending;
	}
	
	/**
	 * Sets the request type, either LoadVarsXML.POST (default) or LoadVarsXML.GET
	 */
	public function set type ( inType:String )  {
		
		if (inType == LoadVarsXML.POST || inType == LoadVarsXML.GET) {
			
			mType = inType;
		}
	}
	
	/**
	 * @return Package and class name
	 */
	public function toString () : String {
		return "org.asapframework.data.loader.LoadVarsXML";
	}
}