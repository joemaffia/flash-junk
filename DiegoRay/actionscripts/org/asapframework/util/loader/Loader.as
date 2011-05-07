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
import org.asapframework.util.loader.FileData;
import org.asapframework.util.loader.LoaderEvent;
import org.asapframework.util.loader.LoaderWorker;
import org.asapframework.util.loader.LoaderWorkerEvent;
import org.asapframework.util.FrameDelay;

/**
Loads SWF movies or JPEG images into a clip. Multiple/subsequent movies that are added are queued. Loader can deal with multiple loading threads simultaneously (but the real life efficiency is dependent on the capability of the browser).
@author Arthur Clemens, Martijn de Visser (rewritten for EventDispatcher usage and added check for already loaded data)
@see LoaderWorker
@example
Example to load multiple images:
<code>
var loader:Loader = new Loader();
</code>
Listen for feedback during loading:
<code>
loader.addEventListener(LoaderEvent.ON_PROGRESS, this);
loader.addEventListener(LoaderEvent.ON_DONE, this);
</code>
Load the assets. We will make them invisible first, and turn them visible once they are loaded:
<code>
loader.load( movieholder1_mc, "seaside.jpg", "Seaside", false );
loader.load( movieholder2_mc, "tree.jpg", "Woods", false );
</code>
To keep track of loading progress, implement the listener method - we will update a progress bar with the incoming data:
<code>
private function onLoadProgress (e:LoaderEvent) : Void {
	progressbar._xscale = 100 / e.total * e.loaded;
}
</code>
And the method that is called when each asset has finished loading:
<code>
private function onLoadDone (e:LoaderEvent) : Void {
	trace(e.name + " is loaded");
	e.targetClip._visible = true; // or use {@link ActionQueue ActionQueue} to fade in the clip
}
</code>
We could also have implemented {@link LoaderEvent#ON_ALL_LOADED} to find out when everything is done.
*/

class org.asapframework.util.loader.Loader extends Dispatcher {

	private var STATE_NONE:Number = 0;
	private var STATE_LOADING:Number = 1;
	private var STATE_PAUSED:Number = 2;
	
	private var mWorkerCount:Number = 4; /**< The number of LoaderWorker objects that will be doing loading work simultaneously. */
	private var mFileQueue:Array;		/**< Array of {@link FileData} objects. */
	private var mCurrentLoadList:Array;	/**< Array of {@link FileData} objects that are currently being loaded. */
	private var mWorkers:Array;			/**< Array of {@link LoaderWorker} objects. */
	private var mLoadingState:Number;	/**< Loading state of the Loader. */


	
	/**
	@param inThreadCount (optional) The number of threads the Loader should be using. Default (when left empty) is 4. This means that (theoretically) 4 files will be loaded at once. The actual number that Flash uses is dependent on the browser. When the number of threads is 1, the next file will only be loaded when the first is done loading.
	*/
	public function Loader (inThreadCount:Number) {

		super();
		mLoadingState = STATE_NONE;
		
		if (inThreadCount > 0) {
			mWorkerCount = inThreadCount;
		}
		mFileQueue = new Array();
		mCurrentLoadList = new Array();
		mWorkers = new Array();
		for (var i:Number = 0; i<mWorkerCount; ++i) {
			var worker:LoaderWorker = new LoaderWorker(i);			
			worker.addEventListener(LoaderWorkerEvent.ON_PROGRESS, this);
			worker.addEventListener(LoaderWorkerEvent.ON_ERROR, this);
			worker.addEventListener(LoaderWorkerEvent.ON_DONE, this);			
			mWorkers.push(worker);
		}
	}

	/**
	Adds a file to the load queue. The file will be ordered to load as soon as one of the loader workers is idle. Supported file types are: swf, jpg
	@param loc : Movieclip in where the file should be loaded
	@param url : File's url or disk location
	@param name : (optional) Unique identifying name for the loading request
	@param isVisible : (optional) The visible state of the movieclip once the file is loaded; if not specified, visible = true is assumed
	@return Error state; false if an error occurred, true if successfully added to the queue
	*/
	public function load (inLoc:MovieClip, inUrl:String, inName:String, inIsVisible:Boolean) : Boolean {
		// Error checking
		// check if location is valid
		if (inLoc == undefined) {
			Log.error("load; location is not valid", toString());
			return false;
		}
		// Check if url is valid
		if (inUrl.length == 0) {
			Log.error("load; url is not valid", toString());
			return false;
		}
		// check for formal validity of url
		var urlComponents:Array = inUrl.split(".");
		if (urlComponents.length <= 1) {
			Log.error("load; filename is wrong: '" + inUrl + "'", toString());
			return false;
		}
		var isVisible:Boolean = (inIsVisible != undefined) ? inIsVisible : true;
		var fileData:FileData = new FileData(inLoc, inUrl, inName, isVisible);
		mFileQueue.push(fileData);
		// start loading the file one frame later
		var fd:FrameDelay = new FrameDelay(this, getNextInQueue);
		// return start loading succesful
		return true;
	}
	
	/**
	
	*/
	public function getFileCount () : Number {
		return mFileQueue.length;
	}

	/**
	Stops the loading of one file.
	@param name : Name of the loading request as passed with {@link #load}
	*/
	public function stopLoading (inName:String) : Void {
		stopLoadingWorkers(inName);
	}

	/**
	Stops the loading of all files, clears the loading queue and frees the loader workers.
	*/
	public function stopAllLoading () : Void {
		stopLoadingWorkers();
		delete mFileQueue;
		mFileQueue = new Array();
	}
	
	/**
	Stops the loading of all files until resumeAllLoading is called.
	*/
	public function pauseAllLoading () : Void {
		stopLoadingWorkers();
		mLoadingState = STATE_PAUSED;
	}
	
	/**
	Stops the loading of all files until resumeAllLoading is called.
	*/
	public function resumeAllLoading () : Void {
		getNextInQueue();
	}
	
	/**
	The Loader's loading state.
	@return True when one of the workers is still loading, false when all workers have finished.
	*/
	public function isLoading () : Boolean {
		return mLoadingState == STATE_LOADING;
	}
	
	/**
	Calculates the total number of bytes loading and loaded of all workers.
	@return A value object {total:Number, loaded:Number}.
	*/
	public function getTotalAndLoaded () : Object {
		var totalAndLoaded:Object = {total:0, loaded:0};
		var i:Number, len:Number = mWorkers.length;
		for (i=0; i<len; ++i) {
			var worker:LoaderWorker = LoaderWorker(mWorkers[i]);
			if (worker.loading) {
				var data:FileData = worker.loadingData;
				var dataTotal:Number = data.bytesTotal;
				if (dataTotal != undefined) totalAndLoaded.total += dataTotal;
				var dataLoaded:Number = data.bytesLoaded;
				if (dataLoaded != undefined) totalAndLoaded.loaded += dataLoaded; 
			}
		}
		return totalAndLoaded;
	}

	/**
	*
	*/
	public function toString () : String {
		return "; org.asapframework.util.loader.Loader";
	}
	
	/**
	@sends LoaderEvent#ON_ALL_LOADED When no more assets are in the queue
	@sends LoaderEvent#ON_START When a new LoaderWorker starts loading
	*/
	private function getNextInQueue () : Void {

		updateLoadingState();
		
		if (mFileQueue.length == 0) {
			if (!isLoading()) {
				dispatchEvent(new LoaderEvent(LoaderEvent.ON_ALL_LOADED, this));				
			}
			return;
		}

		// Not done yet, so get next free Worker
		var i:Number, len:Number = mWorkers.length;
		for (i=0; i<len; ++i) {
			var worker:LoaderWorker = LoaderWorker(mWorkers[i]);
			if (!worker.loading) {
				// get the first item
				var fileData:FileData = FileData(mFileQueue.shift());
				mCurrentLoadList.push(fileData);
				worker.load(fileData);
				mLoadingState = STATE_LOADING;
				dispatchEvent(new LoaderEvent(LoaderEvent.ON_START, this, fileData.name, 0, 0));
				break;
			}
		}

	}
	
	/**
	Updates the loading state; sets mLoadingState to true if one of the workers is loading; to false if all loader workers are free.
	*/
	private function updateLoadingState () : Void {
		if (mLoadingState == STATE_PAUSED) {
			return;
		}
		if (mCurrentLoadList.length > 0) {
			mLoadingState = STATE_LOADING;
		} else {
			mLoadingState = STATE_NONE;
		}
	}

	/**
	Monitors the loading progress of one LoaderWorker object. This event is passed on to listeners of the Loader.
	@param e: event object with properties: .name, .type, .target
	@sends LoaderEvent#ON_PROGRESS When some data has been received
	*/
	private function onWorkerLoadProgress (e:LoaderWorkerEvent) : Void {
		// calculate the total amount of data of all workers,
		// then send this information out
		var totalAndLoaded:Object = getTotalAndLoaded();
		dispatchEvent(new LoaderEvent(LoaderEvent.ON_PROGRESS, this, e.name, e.targetClip, totalAndLoaded.total, totalAndLoaded.loaded));
	}

	/**
	Received when a LoaderWorker object is finished or stopped loading. This event is passed on to listeners of the Loader.
	@param e: event object with properties: .name, .type, .target
	@sends LoaderEvent#ON_DONE When one asset has finished loading
	@implementationNote Calls {@link #getTotalAndLoaded}.
	*/
	private function onWorkerLoadDone (e:LoaderWorkerEvent) : Void {

		var totalAndLoaded:Object = getTotalAndLoaded();
		dispatchEvent(new LoaderEvent(LoaderEvent.ON_DONE, this, e.name, e.targetClip, totalAndLoaded.total, totalAndLoaded.loaded));
		removeFromCurrentlyLoading(e.target.loadingData);
		getNextInQueue();
	}

	/**
	Received when a LoaderWorker object encounters an error during loading. This event is passed on to listeners of the Loader.
	@param e: event object with properties: .name, .target
	@sends LoaderEvent#ON_ERROR When an error happened during loading
	*/
	private function onWorkerLoadError (e:LoaderWorkerEvent) : Void {
		
		// dispatch onLoadError event
		dispatchEvent(new LoaderEvent(LoaderEvent.ON_ERROR, this, e.name, e.targetClip));
	}
	
	/**
	Stops all workers loading.
	@param name : (optional) name of the loading request as passed with {@link #load}; if name is passed only the worker with that loading request name will be stopped; otherwise all workers will be stopped
	*/
	private function stopLoadingWorkers (inName:String) : Void {
		var i:Number, len:Number = mWorkers.length;
		for (i=0; i<len; ++i) {
			var worker:LoaderWorker = LoaderWorker(mWorkers[i]);
			if (worker.loading) {
				if (inName != undefined) {
					if (worker.loadingData.name == inName) {
						worker.stopLoading();
					}
				} else {
					worker.stopLoading();
				}
			}
		}
	}
	
	/**
	Removes a FileData object from mCurrentLoadList.
	@param inFileData: object to remove
	*/
	private function removeFromCurrentlyLoading (inFileData:FileData) : Void {
		var i:Number, ilen:Number = mCurrentLoadList.length;
		for (i=0; i<ilen; ++i) {
			if (mCurrentLoadList[i] == inFileData) {
				mCurrentLoadList.splice(i,1);
			}
		}
	}
	
	
}
