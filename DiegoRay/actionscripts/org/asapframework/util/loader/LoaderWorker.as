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
import org.asapframework.util.FrameDelay;
import org.asapframework.util.loader.FileData;
import org.asapframework.util.loader.LoaderWorkerEvent;

/**
* Used internally by {@link Loader}.
* @author Arthur Clemens
* @author Martijn de Visser, added check for already loaded movies. These are now unloaded first.
* @author Martijn de Visser, implemented MovieClipLoader instead of MovieClip.loadMovie - major refactoring of code.
*/

class org.asapframework.util.loader.LoaderWorker extends Dispatcher {

	private var mNumber:Number; /**< Loader's worker number, counting from zero (used for debugging). */
	private var mLoadingState:Boolean = false;
	private var mLoadingData:FileData;
	private var mLoader:MovieClipLoader;
	
	private static var TIMEOUT:Number = 10000; 	/**< Initial timeout when waiting for data from server (10 seconds). */
		
	/**
	Creates a new LoaderWorker object.
	*/
	function LoaderWorker (inNumber:Number) {
		
		super();
		
		mNumber = inNumber;
		
		// setup MovieClipLoader
		mLoader = new MovieClipLoader();
		mLoader.addListener(this);
	}
	
	/**
	Starts loading content
	@param data: a {@link FileData} object
	*/
	public function load (inData:FileData) : Void {
		//delete mLoadingData;
		mLoadingData = inData;
		mLoadingState = true;

		// was a movie already loaded in target?
		var progress:Object = mLoader.getProgress(inData.location);
		var b:Number = progress.bytesLoaded;
		if (b > 4) {
			unloadContent(true);
		} else {
			startLoading();
		}
	}
	
	/**
	Stops loading the asset
	*/
	public function stopLoading () : Void {
		
		// unload clip
		mLoader.unloadClip(mLoadingData.location);
		
		// reset
		resetState();
		
		sendDoneMessage();
	}
	
	/**
	The loading state of the worker, true: the worker is currently loading; false: the worker has not yet started loading, or has finished or has encountered an error.
	*/
	public function get loading () : Boolean {		
		return mLoadingState;
	}
	
	/**
	The {@link FileData} object.
	*/
	public function get loadingData () : FileData {
		return mLoadingData;
	}
	
	// EVENTS
	
	/**
	Invoked when a file loaded with MovieClipLoader.loadClip() has failed to load.
	@sends LoaderWorkerEvent#ON_ERROR
	*/
	public function onLoadError ( target_mc:MovieClip, errorCode:String, httpStatus:Number ) : Void {
		
		// debug message
		Log.error("onLoadError - '" + httpStatus + "' error while loading file: " + mLoadingData.url, toString());
		
		// reset
		resetState();
		
		// dispatch onWorkerLoadError event
		dispatchEvent(new LoaderWorkerEvent(LoaderWorkerEvent.ON_ERROR, this, mLoadingData.name, mLoadingData.location, httpStatus));
	}
	
	/**
	Invoked every time the loading content is written to the hard disk during the loading process (that is, between MovieClipLoader.onLoadStart and MovieClipLoader.onLoadComplete).
	@sends LoaderWorkerEvent#ON_PROGRESS
	*/
	public function onLoadProgress ( target_mc:MovieClip, loadedBytes:Number, totalBytes:Number ) : Void {
		
		// update data
		mLoadingData.bytesLoaded = loadedBytes;
		mLoadingData.bytesTotal = totalBytes;
		
		// dispatch onWorkerLoadProgress event
		dispatchEvent(new LoaderWorkerEvent(LoaderWorkerEvent.ON_PROGRESS, this, mLoadingData.name, mLoadingData.location));
	}
	
	/**
	Invoked when the actions on the first frame of the loaded clip have been executed.	
	*/
	public function onLoadInit ( target_mc:MovieClip ) : Void {
				
		// reset
		resetState();

		// set visibility
		mLoadingData.location._visible = mLoadingData.visible;
		
		sendDoneMessage();
	}
	
	/**
	Invoked when a call to MovieClipLoader.loadClip() has begun to download a file.
	@sends Nothing, not yet implemented.
	*/
	public function onLoadStart  ( target_mc:MovieClip ) : Void {		
		// unused
	}
		
	/**
	Invoked when a file that was loaded with MovieClipLoader.loadClip() is completely downloaded.
	@sends Nothing, not implemented.
	*/
	public function onLoadComplete ( target_mc:MovieClip, httpStatus:Number ) : Void {
		// unused
	}	

	// PRIVATE METHODS
	
	/**
	@sends LoaderWorkerEvent#ON_DONE
	*/
	private function sendDoneMessage () : Void {
		dispatchEvent(new LoaderWorkerEvent(LoaderWorkerEvent.ON_DONE, this, mLoadingData.name, mLoadingData.location));
	}

	/**
	Resets the state of this worker
	*/
	private function resetState () : Void {
		
		// set flag
		mLoadingState = false;
		
		// reset loaded bytes
		mLoadingData.bytesTotal = mLoadingData.bytesLoaded = 0;
	}

	/**
	Starts the actual loading process
	*/
	private function startLoading () : Void {
		mLoader.loadClip(mLoadingData.url, mLoadingData.location);
	}
	
	/**
	Unloads the current movie if a movie was already loaded in mc
	@param start, set to true to start loading new content after 1 frame dealy
	*/
	private function unloadContent (inStart:Boolean) : Void {
		
		mLoader.unloadClip(mLoadingData.location);
		if (inStart) var d:FrameDelay = new FrameDelay(this,startLoading,1);
	}
	
	/**
	@return Package and class name
	*/
	public function toString () : String {
		return "org.asapframework.util.loader.LoaderWorker: " + mNumber;
	}
}