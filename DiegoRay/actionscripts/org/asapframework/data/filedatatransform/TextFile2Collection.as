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
import org.asapframework.events.EventDelegate;

/**
Base class that takes a text file url, loads the file data and converts the text contents to a collection structure (Tree or Array). Actual parsing is not provided in this class, see the subclasses for implementations.
@author Arthur Clemens
*/

class org.asapframework.data.filedatatransform.TextFile2Collection extends Dispatcher {
	
	private var mCollection:Object;
	private var mListener:Object;
	private var mFileUrl:String;
	
	/**
	Creates a TextFile2Collection instance.
	@param inFileUrl: url of the text file with data to parse
	@param inListener: (optional) object that receives a 'finished' event after parsing; most likely the listener will be the invoker of this constructor
	@param inCollection: (optional) existing object to store the data in; if not provided a new object will be created
	*/
	public function TextFile2Collection (inFileUrl:String,
										 inListener:Object,
										 inCollection:Object)  {
		if (inCollection != undefined) {
			mCollection = inCollection;
		}
		if (inListener != undefined) {
			mListener = inListener;
		}
		mFileUrl = inFileUrl;
	}
	
	/**
	Loads the text file and starts the parser.
	*/
	public function load () : Void {
		var lv:LoadVars = new LoadVars();
		lv.onData = EventDelegate.create(this, handleDataLoaded);
		lv.load(mFileUrl);
	}
	
	/**
	Invoked by LoadVars when data is received.
	@param inSource: the file data
	*/
	private function handleDataLoaded (inSource:String) : Void {
		parse(inSource);
	}
	
	/**
	The text data parsing method - implemented by subclasses.
	@implementationNote Subclass implementation should always call {@link #notifyFinished}.
	*/
	private function parse (inSource:String) : Void {
		// parsing is implemented by subclass
		notifyFinished(); // method that should always be called by the subclass after parsing
	}

	/**
	Sends 'finished' message - implemented by subclasses.
	*/
	private function notifyFinished () : Void {
		// implemented by subclass
	}
	
}