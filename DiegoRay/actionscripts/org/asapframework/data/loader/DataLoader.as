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

import org.asapframework.data.loader.DataLoaderEvent;
import org.asapframework.data.loader.LoadVarsXML;
import org.asapframework.data.loader.URLData;
import org.asapframework.events.Dispatcher;
import org.asapframework.events.EventDelegate;
import org.asapframework.util.debug.Log;
import org.asapframework.util.xml.XML2Object;
import org.asapframework.util.xml.XMLEvent;
import org.asapframework.util.xml.XMLLoader;

/**
Class for loading XML-data with or without posting parameters in the request to the server.
This class can be used to load static XML files or dynamic XML files based on parameters, or to post forms that give XML back as a result.
Identification of a request is done by a unique name, that is passed in the request, and returned in the response.
XML data is parsed into an Object instance by means of XML2Object.parseXML. This object is returned in the event that is sent when the data has been received and parsed.
An event of type {@link DataLoaderEvent#DATA_LOADED DataLoaderEvent.DATA_LOADED} is dispatched when data has been loaded successfully. This event contains the name of the original request, and the parsed data.
In case of an error, an event of type {@link DataLoaderEvent#DATA_LOADED DataLoaderEvent.ERROR} is dispatched, with the name of the original request, but without any data.

The function {@link #addLoaderListener} can be used to add a handler for all DataLoaderEvent events. The handler can be removed with {@link #removeLoaderListener}.

@use
This is an example of code in a DataManager class that uses the DataLoader:
<code>
	// Private constructor for use as Singleton
	private function DataManager() {
		mDataLoader = DataLoader.getInstance();
		mDataLoader.addLoaderListener(EventDelegate.create(this, handleDataLoaded));
	}

	// load XML from specified url with specified name	
	public function loadXMLData (inURL:String, inName:String) : Boolean {
		var ud:URLData = new URLData(inName, inURL);
		return mDataLoader.loadXML(ud);
	}

	// load settings xml
	public function loadSettings () : Void {
		loadXMLData(URL_SETTINGS, URLNames.SETTINGS);
	}
	
	// Handle data loaded event from data loader
	private function handleDataLoaded (e:DataLoaderEvent) : Void {
		Log.debug("handleDataLoaded: name = " + e.name, toString());

		// check error		
		if (e.type == DataLoaderEvent.ERROR) {
			handleDataError(e);
			return;
		}
		
		switch (e.name) {
			case URLNames.SETTINGS: handleSettingsLoaded(e.data, e.name); break;
		}
	}
	
	// Handle error event from data loader
	private function handleDataError (e:DataLoaderEvent) : Void {
		var evt:DataEvent = new DataEvent(DataEvent.LOAD_ERROR, e.name, null, this);
		evt.error = "Failed to load the XML file named " + e.name;
		dispatchEvent(evt);
	}
	
	// Handle settings loaded
	private function handleSettingsLoaded (inData:Object, inName:String) {
		// parse object
	}
</code>
 */
 
class org.asapframework.data.loader.DataLoader extends Dispatcher {

	private static var mInstance : DataLoader;
	private var mXMLLoader : XMLLoader;
	private var mPostXMLLoader : LoadVarsXML;

	
	/**
	 * @return singleton instance of Loader
	 */
	public static function getInstance() : DataLoader {
		if (mInstance == null)
			mInstance = new DataLoader();
		return mInstance;
	}

	/**
	*	Add specified function as handler for DataLoaderEvent events
	*/
	public function addLoaderListener (inHandler:Function) : Void {
		addEventListener(DataLoaderEvent.EVENT_DATALOADER, inHandler);
	}
	
	/**
	*	Remove specified function as handler for DataLoaderEvent events
	*/
	public function removeLoaderListener (inHandler:Function) : Void {
		removeEventListener(DataLoaderEvent.EVENT_DATALOADER, inHandler);
	}

	/**
	*	Load data, with or without post
	*	@param inURLData: {@link URLData} object containing name and url to load from
	*	@param inLV: LoadVars object with post info; if left out, a regular request is performed
	*	@return true if loading was started successfully, otherwise false
	*/
	public function loadXML (inURLData:URLData, inLV:LoadVars) : Boolean {
		if (inLV != undefined) {
			return mPostXMLLoader.load(inURLData, inLV);
		} else {
			return mXMLLoader.load(inURLData.url, inURLData.name);
		}
	}

	/**
	*	Handle loaded event from xml loader
	*/
	private function handleXMLLoaded (e:XMLEvent) : Void {
		handleDataLoaded(XML2Object.parseXML(e.xmlSource), e.name);
	}

	/**
	*	Handle done event from the postXMLLoader
	*/
	private function handlePostDone () : Void {
		handleDataLoaded(mPostXMLLoader.result, mPostXMLLoader.urlData.name);
	}
	
	/**
	*	Handle event that data has been loaded
	*/
	private function handleDataLoaded (inData:Object, inName:String) : Void {
		dispatchEvent(new DataLoaderEvent(DataLoaderEvent.DATA_LOADED, inData, inName, this));
	}
	
	/**
	*	Handle error while loading with the XMLLoader
	*/
	private function handleXMLError (e:XMLEvent) : Void {
		Log.error("handleXMLError: error loading '" + e.name + "', error: " + e.error, toString());
		
		var dle:DataLoaderEvent = new DataLoaderEvent(DataLoaderEvent.ERROR, null, e.name, this);
		dle.error = e.error;
		dispatchEvent(dle);
	}
	
	/**
	*	Handle error while loading from the postXMLLoader
	*/
	private function handlePostError () : Void {
		var name:String = mPostXMLLoader.urlData.name;
		
		Log.error("handlePostError: error loading '" + name + "'", toString());
		
		dispatchEvent(new DataLoaderEvent(DataLoaderEvent.ERROR, null, name, this));
	}

	/**
	*	Constructor
	*/
	private function DataLoader() {
		super();

		// create xml loader and listen to events
		mXMLLoader = new XMLLoader();
		mXMLLoader.addEventListener(XMLEvent.ON_LOADED, EventDelegate.create(this, handleXMLLoaded));
		mXMLLoader.addEventListener(XMLEvent.ON_ERROR, EventDelegate.create(this, handleXMLError));
		mXMLLoader.addEventListener(XMLEvent.ON_TIMEOUT, EventDelegate.create(this, handleXMLError));

		// create xml loader with post data, listen to events
		mPostXMLLoader = new LoadVarsXML();
		mPostXMLLoader.addEventListener(LoadVarsXML.EVENT_DONE, EventDelegate.create(this, handlePostDone));
		mPostXMLLoader.addEventListener(LoadVarsXML.EVENT_ERROR, EventDelegate.create(this, handlePostError));
	}
	
	public function toString() : String {
		return ";org.asapframework.data.loader.DataLoader";
	}
}
