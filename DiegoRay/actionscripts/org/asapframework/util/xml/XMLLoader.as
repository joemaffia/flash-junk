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
import org.asapframework.util.xml.XMLEvent;
import org.asapframework.util.xml.XMLWorker;
import org.asapframework.util.xml.XMLWorkerEvent;

/**
Loads XML files. For your convenience, this class won't allow more than 3 simultaneous XML.load calls, to prevent this Flash Player bug: http://www.macromedia.com/go/c0da292b from occuring.

More than three simulaneous calls are placed in a queue and loaded sequentially.
@author Martijn de Visser
@use
<code>
var myXMLLoader:XMLLoader = XMLLoader.getInstance();
myXMLLoader.addEventListener( XMLEvent.ON_LOADED, this );
myXMLLoader.load("../xml/myfile.xml", "myFile");
</code>
In your listening class ('this' in example):
<code>	
public function onXMLLoaded (e:XMLEvent) : Void {
	// handle result
}
</code>
 */


class org.asapframework.util.xml.XMLLoader extends Dispatcher {

	private var mWorkerQueue:Array;	 /**Array of {@link org.asapframework.util.xml.XMLWorker} objects */
	
	// limit number of simultaneous XMLWorkers, due to Flash player bug: http://www.macromedia.com/go/c0da292b
	private static var mCurrentCalls:Number = 0;
	private static var MAX_CALLS:Number = 3;
	
	// error constants
	public static var ERROR_CDATA_TERMINATION:Number = -2;
	public static var ERROR_XML_TERMINATION:Number = -3;
	public static var ERROR_DOCTYPE_TERMINATION:Number = -4;
	public static var ERROR_COMMENT_TERMINATION:Number = -5;
	public static var ERROR_ELEMENT_MALFORMED:Number = -6;
	public static var ERROR_OUT_OF_MEMORY:Number = -7;
	public static var ERROR_ATTRIBUTE_TERMINATION:Number = -8;
	public static var ERROR_STARTTAG_WITHOUT_ENDTAG:Number = -9;
	public static var ERROR_ENDTAG_WITHOUT_STARTTAG:Number = -10;
	public static var ERROR_TIMEOUT:Number = -100;
		
	// Singleton instance of class
	private static var instance:XMLLoader = null;

	/**
	Private constructor, use {@link #getInstance} to refer to the singleton instance.
	*/
	public function XMLLoader () {
		super();		
		mWorkerQueue = new Array();
	}

	/**
	Loads an XML file.
	@param inURL The URL of the xml file
	@param inName Unique identifier; this name will also be used in callback events when file was loaded or when an error was encountered.
	@param inNoCache If set to true, the xml file will always be fetched from the server by appending a timestamp to the call, thus circumventing the local browser cache.
	@param inTimeOut Set value to specify time to wait (in milliseconds) for a server response (excluding the download time of the actual XML data itself). Defaults to 10 seconds if no value is specified. Set to '0' to disable timeout.
	@returns Boolean, false if XML document couldn't be added (because name already exists is list).
	*/
	public function load ( inURL:String, inName:String, inNoCache:Boolean, inTimeOut:Number ) : Boolean {

		// does name already exist?
		var len:Number = mWorkerQueue.length;
		for (var i:Number=0; i<len; ++i) {
		
			var w:XMLWorker = XMLWorker(mWorkerQueue[i]);
			if (w.name == inName) {
			
				Log.error("load: XML document with name '" + inName + "' already in queue.", toString());
				return false;
			}
		}
		
		// no duplicate found
		var nw:XMLWorker = new XMLWorker(inURL, inName, inNoCache, inTimeOut);
		nw.addEventListener(XMLWorkerEvent.ON_LOADED, this);
		nw.addEventListener(XMLWorkerEvent.ON_TIMEOUT, this);
		
		// add to queue
		mWorkerQueue.push(nw);
		
		// start loading
		startLoading(nw);
		return true;
	}
	
	/**
	Tries to start loading the file.
	@param inWorker:XMLWorker
	@returns Boolean indicating if we could start or not.
	*/
	private function startLoading ( inWorker:XMLWorker ) : Boolean {
	
		// can we start loading right away?
		if (XMLLoader.mCurrentCalls < XMLLoader.MAX_CALLS) {
			
			XMLLoader.mCurrentCalls++;
			inWorker.load();
			return true;
		}
		return false;
	}
	
	/**
	Callback from XMLWorker
	@sends XMLEvent#ON_ERROR
	@sends XMLEvent#ON_LOADED
	 */
	private function onXMLLoaded ( e:XMLWorkerEvent ) : Void {

		// lower counter
		XMLLoader.mCurrentCalls--;
		
		var w:XMLWorker = e.worker;				
		var errorString:String;
		if (w.status != 0) {

			errorString = "Error on loading xml file '" + w.url + "' with id '" + w.name + "'\n\t\t" + XMLError(w.status);
			Log.error(errorString, toString());
			
			// dispatch onXMLLoadError event
			dispatchEvent(new XMLEvent(XMLEvent.ON_ERROR, w, w.name, errorString, w.status));
			
		} else {
			
			if (w.result) {
				
				// dispatch onXMLLoaded event
				dispatchEvent(new XMLEvent(XMLEvent.ON_LOADED, w, w.name, null, w.status));
				
			} else {
				
				errorString = "Error on loading xml file '" + w.url + "' with id '" + w.name + "'";
				Log.error(errorString, toString());
				
				// dispatch onXMLLoadError event
				dispatchEvent(new XMLEvent(XMLEvent.ON_ERROR, w, w.name, errorString, w.status));
			}
		}
		
		// remove wrapper from queue
		removeWorker(w);
		
		// check if we should start loading another file
		loadNext();
	}
	
	/**
	Triggered if no response from server was received within timeout interval.
	*/
	public function onXMLTimeout ( e:XMLWorkerEvent ) : Void {
	
		// dispatch onXMLTimeout event
		var w:XMLWorker = e.worker;
		var error:String = "Timeout on loading xml file '" + w.url + "' with id '" + w.name + "'";
		dispatchEvent(new XMLEvent(XMLEvent.ON_TIMEOUT, w, w.name, error, XMLLoader.ERROR_TIMEOUT));
		
		// remove wrapper from queue
		removeWorker(w);
		
		// check if we should start loading another file
		loadNext();
	}
	
	/**
	Loads the next file in the queue that's not being loaded yet.
	@sends XMLEvent#ON_ALL_LOADED
	*/
	private function loadNext () : Void {
		
		// room for another call?
		if (XMLLoader.mCurrentCalls < XMLLoader.MAX_CALLS) {
		
			var len:Number = mWorkerQueue.length;
			
			if (len > 0) {
				
				// find next in line to load
				for (var i:Number=0; i<len; ++i) {
				
					var w:XMLWorker = XMLWorker(mWorkerQueue[i]);
					if (!w.loading) {
					
						startLoading(w);
						break;
					}
				}
				
			} else {
				
				// we're done loadign all files, dispatche vent
				dispatchEvent(new XMLEvent(XMLEvent.ON_ALL_LOADED));
			}
		}
	}
	
	/**
	Removes a wrapper from the queue and breaks listener relation.
	*/
	private function removeWorker ( inWorker:XMLWorker ) : Void {
			
		// find and remove worker
		var len:Number = mWorkerQueue.length;
		for (var i:Number=0; i<len; ++i) {
		
			var w:XMLWorker = XMLWorker(mWorkerQueue[i]);
			if(w.name == inWorker.name) {
			
				// stop listening
				inWorker.removeEventListener(XMLWorkerEvent.ON_LOADED, this);
				inWorker.removeEventListener(XMLWorkerEvent.ON_TIMEOUT, this);
		
				// remove from queue
				mWorkerQueue.splice(i, 1);
				break;
			}
		}
	}

	/**
	Converts an XML error to a string.
	*/
	private static function XMLError ( inError:Number ) : String {
		
		var msg:String = new String("XML error: " + inError);
		switch( inError ) {
			case XMLLoader.ERROR_CDATA_TERMINATION:			msg += " (A CDATA section was not properly terminated)"; break;
			case XMLLoader.ERROR_XML_TERMINATION: 			msg += " (The XML declaration was not properly terminated)"; break;
			case XMLLoader.ERROR_DOCTYPE_TERMINATION: 		msg += " (The DOCTYPE declaration was not properly terminated)"; break;
			case XMLLoader.ERROR_COMMENT_TERMINATION: 		msg += " (A comment was not properly terminated)"; break;
			case XMLLoader.ERROR_ELEMENT_MALFORMED: 		msg += " (An XML element was malformed)"; break;
			case XMLLoader.ERROR_OUT_OF_MEMORY: 			msg += " (Not enough memory to parse the XML source)"; break;
			case XMLLoader.ERROR_ATTRIBUTE_TERMINATION: 	msg += " (An attribute value was not properly terminated)"; break;
			case XMLLoader.ERROR_STARTTAG_WITHOUT_ENDTAG:	msg += " (A start tag had no corresponding end tag)"; break;
			case XMLLoader.ERROR_ENDTAG_WITHOUT_STARTTAG:	msg += " (An end tag had no corresponding start tag)"; break;
			case XMLLoader.ERROR_TIMEOUT:					msg += " (Time-out while waiting for server response)"; break;
			default : 										msg += " (Unknown error)"; break;
		}
		return msg;
	}
	
	/**
	Returns reference to singleton instance of XMLLoader.
	*/
	public static function getInstance () : XMLLoader {
		
		if (instance == null) {
			instance = new XMLLoader();
		}
		return instance;
	}
	
	public function toString() : String {
		return ";org.asapframework.util.xml.XMLLoader";
	}
}