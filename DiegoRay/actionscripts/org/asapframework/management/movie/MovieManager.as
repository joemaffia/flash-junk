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
import org.asapframework.management.movie.LocalController;
import org.asapframework.management.movie.MovieData;
import org.asapframework.management.movie.MovieManagerEvent;
import org.asapframework.util.debug.Log;
import org.asapframework.util.loader.Loader;
import org.asapframework.util.loader.LoaderEvent;

/**
	@description The MovieManager handles administration, loading and retrieving of separate SWF movies.
	
	Start the loading process by calling {@link #loadMovie}.
	After this, three events of type {@link MovieManagerEvent} can be expected: when the movie has initialized, has been loaded, and is ready.
	Ready is defined as both initialized and loaded.

	Once a movie has been loaded, its localController can be retrieved by name or by backtracing from any point within any movieclip to its nearest localController.

	A typical sequence of events will be:
	<ul>
	<li>{@link #loadMovie} is called with an SWFData block containing a container movieclip, a name and an url</li>
	<li>the SWF starts being loaded</li>
	<li>the code in the first frame of the loaded movie is run, usually creating a LocalController</li>
	<li>{@link #movieCreated} is called by the LocalController object, the controller gets its name from the data block loadMovie was called with, the controller is known to the MovieManager</li>
	<li>{@link #onLoadDone} is called by the loader, indicating 100% of the SWF has been loaded; the event {@link MovieManagerEvent#ON_MOVIE_LOADED onMovieLoaded} is broadcast</li>
	<li>{@link #movieInitialized} is called by the LocalController object, indicating the controller is done initializing and ready to start; the event "onMovieInitialized" is broadcast</li>
	<li>when the movie has been loaded and initialized, the event {@link MovieManagerEvent#ON_MOVIE_READY onMovieReady} is broadcast</li>
	</ul>

	Note that it is left up to whoever loads the movie, or controls the application, or to the loaded movie itself, to actually start the movie.

	Naming of movies:
	- use a unique name for each movie
	- use publicly accessible constants for movie names. This makes it easier to change names throughout the application.
	- the name has to be given when loading the movie with MovieManager.getInstance().loadMovie(). 
		This means the local controller of a standalone running movie does not have a name. 
		This can be circumvented (if necessary) by giving the local controller its name locally when it is running standalone. 
		ILocalController has a function isStandalone() for checking this.
	@use
	This example shows an application controller (subclass of LocalController) that loads a menu SWF:
	<code>
	class MovieNames {
		public static var NAME_APPLICATION:String = "application";
		public static var NAME_MENU:String = "menu";
		
		public static var URL_MENU:String = "menu.swf";
	}
	
	class AppController extends LocalController {  
		public function AppController (inTimeLine:MovieClip) {
			super(inTimeLine);
			
			// Set name of controller so other controllers can find the reference of this by name if necessary
			setName(MovieNames.NAME_APPLICATION); 
			
			// listen for event when movies are loaded and ready to play
			MovieManager.getInstance().addEventListener(MovieManagerEvent.ON_MOVIE_READY, EventDelegate.create(this, handleMovieReady));
			// load the menu movie and give it the name specified in MovieNames.NAME_MENU
			MovieManager.getInstance().loadMovie( MovieNames.NAME_MENU, MovieNames.URL_MENU, inTimeLine.swfholder, true);
		}
		
		private function handleMovieReady (e:MovieManagerEvent) {
			Log.info("handleMovieReady: movie with name = '" + e.name + "' has been loaded.", toString());
		}
	}
	</code>
*/

class org.asapframework.management.movie.MovieManager extends Dispatcher {
	/** Contains a list of objects of type org.asapframework.moviemanagement.MovieData */
	private var mMovies:Array;	
	private var mLoader:Loader;
	private var mControllerCache:Object; // cache; associative array of [object] -> [manager]

	private static var sInstance:MovieManager = null;

	/**
	Private constructor
	*/
	private function MovieManager () {

		super();

		mMovies = new Array();
		mControllerCache = new Object();		
		mLoader = new Loader();
		
		// register for event handling
		mLoader.addEventListener(LoaderEvent.ON_DONE, this);
		mLoader.addEventListener(LoaderEvent.ON_ERROR, this);
	}

	/**
	Access point for the one instance of the MovieManager
	*/
	public static function getInstance () : MovieManager {
		if (sInstance == null) {
			sInstance = new MovieManager();
		}

		return sInstance;
	}


	/**
	Start loading the movie with path inSource.url into movieclip inSource.mc, and adds it to the list of movies under the name inSource.name
	@param inName: unique identifying name for the movie to be loaded
	@param inURL: url where the swf can be found
	@param inMovieClip: movieclip object in which the swf is to be loaded; must not be _level0, or your application will behave erratically.
	@param inIsVisible:  true if the movie has to be made visible when loaded
	@return: false if the loader cannot load the movie, or the movie could not be added to the list (usually because another or the same movie with the same name exists already), otherwise true
	*/
	public function loadMovie (inName:String, inURL:String, inMovieClip:MovieClip, inIsVisible:Boolean) : Boolean {
		if (inMovieClip == undefined) {
			Log.error("loadMovie; the movieclip to load the movie into does not exist!", toString());
			return false;
		}

		if (!mLoader.load(inMovieClip, inURL, inName, inIsVisible)) {
			// only reason can be now that the filename is illegal or the file does not exist
			Log.error("loadMovie; error with mLoader.load - filename '" + inURL + "' is illegal or the file does not exist", toString());
			return false;
		}

		// movie loading, so try adding
		if (!addMovie(inName, inURL, inMovieClip)) {
			return false;
		}

		return true;
	}

	/**
	Tries to find the movie with the specified name and shows it if it has loaded and started
	the movie is approached through the LocalController of the movie, and not shown directly
	@param inName : the name used as identifier for the movie to be shown
	@return: false if the movie wasn't found, loaded or started; true otherwise
	*/
	public function showMovie (inName:String) : Boolean {
		var mcData:MovieData = getMcData(inName);
		if (mcData == null) {
			Log.error("showMovie; data for movie with name '" + inName + "' not found", toString());
			return false;
		}
		if (!(mcData.isCreated && mcData.isLoaded && mcData.isInitialized)){
			Log.error("showMovie; movie with name '" + inName + "' not ready", toString());
			return false;
		}

		mcData.localController.show();
	}

	/**
	Tries to find the movie with the specified name and hides it if it has loaded and started
	the movie is approached through the LocalController of the movie, and not hidden directly.
	@param inName : the name used as identifier for the movie to be hidden
	@return: false if the movie wasn't found, loaded or started; true otherwise
	*/
	public function hideMovie (inName:String) : Boolean {
		var mcData:MovieData = getMcData(inName);
		if (mcData == null) {
			Log.error("hideMovie; data for movie with name '" + inName + "' not found", toString());
			return false;
		}

		if (!(mcData.isCreated && mcData.isLoaded && mcData.isInitialized)){
			Log.error("hideMovie; movie with name '" + inName + "' not ready", toString());
			return false;
		}
		mcData.localController.hide();
	}

	/**
	Looks for the movie and checks whether it has been loaded
	@param inName : the name used as identifier for the movie
	@return : false if the movie wasn't found or wasn't loaded, otherwise true
	*/
	public function isMovieLoaded (inName:String) : Boolean {
		var mcData:MovieData = getMcData(inName);
		return ((mcData != null) && mcData.isLoaded);
	}

	/**
	Tries to find the movie with the specified identifier, empties the attached movieclip and removes the movie data from the list
	after this action, a movie has to be loaded again using loadMovieInClip
	it is not checked whether a movie is being loaded, has been loaded or has been started, so this is tricky when a movie is in the loader
	@param inMovie either :String: the name used as identifier for the movie to be removed, or :MovieClip: the movieclip reference
	@param inShouldRemoveMovieClip : the movieclip holder will be removed too; but then this movieclip cannot be used again; default false
	@return : false if the movie wasn't found, true otherwise
	*/
	public function removeMovie (inMovie:Object, inShouldRemoveMovieClip:Boolean) : Boolean {
		// retrieve data block depending on type of inMovie
		var mcData:MovieData;
		
		switch (typeof inMovie) {
		case "movieclip":
			mcData = getMcDataForMovieClip(MovieClip(inMovie));
			if (mcData == null) {
				Log.error("removeMovie; data for movie '" + inMovie + "' not found", toString());
				return false;
			}
			break;
		case "string":
			mcData = getMcData(String(inMovie));
			if (mcData == null) {
				Log.error("removeMovie; data for movie with name '" + inMovie + "' not found", toString());
				return false;
			}
			break;
		default:
			Log.error("removeMovie; no string or movieclip passed to function", toString());
			return false;
		}

		// unload and remove if requested
		mcData.mc.unloadMovie();
		if (inShouldRemoveMovieClip) {
			mcData.mc.removeMovieClip();
		}

		// remove from list of data objects
		mMovies.splice(getMovieIndex(mcData.name), 1);
		
		// remove from object cache; this has to be extended to all scopes contained in the movieclip being removed
		if (mControllerCache[mcData.mc] != undefined) {
			delete mControllerCache[mcData.mc];
		}
			
		return true;
	}

	/**
	Retrieve a local controller from the scope of an object.
	Finds the first local controller
	@param inSender : object or movieclip or button
	@return The first local manager upwards in the parent chain, starting from the sender object.
	@implementationNote Because the lookup of the manager can (in some cases)
	be expensive, the found managers are stored in an associative array. When
	this method is called, the array is first consulted.
	
	Note Stephan: the way it is implemented now, it doesn't work. The original inSender is lost after the first _parent.
	Once this has been cleared, removeMovie has to be extended to include proper cache emptying
	*/
	public function getNearestLocalController (inSender:Object) : LocalController {
		// first try if this is already mapped
		var controller:LocalController = mControllerCache[inSender];
		if (controller != undefined) {
			return controller;
		}

		while (inSender) {
			var i:Number, len:Number = mMovies.length;
			for (i=0; i<len; ++i) {
				var mcData:MovieData = MovieData(mMovies[i]);
				if ((mcData.mc == inSender) && (mcData.localController != undefined)) {
					// map result
					mControllerCache[inSender] = mcData.localController;
					return mcData.localController;
				}
			}
			inSender = inSender._parent;
		}
		// else
		Log.warn("getLocalManager; manager from sender '" + inSender + "' not found.", toString());
		return null;
	}

	/**
	Finds a local controller by name
	@param inName: unique identifier for the loaded movie
	@returns The controller for that movie, or null if none was found
	*/
	public function getLocalControllerWithName (inName:String) : LocalController {
		var mcData:MovieData = getMcData(inName);
		if (mcData == null) {
			Log.warn("getLocalManagerWithName; manager with name '" + inName + "' not found.", toString());
			return null;
		}

		return mcData.localController;
	}

	/**
	Handles the event sent by local controllers to notify that the local controller that sends the event has been created.
	Initializes the name of the controller by setting it to the name that the movie was loaded by.
	If no data block was found for the input clip, a new data block is created, with the name of the movieclip as name
	@param inCtrl: the local controller of the movie clip that has been created
	*/
	public function movieCreated (inCtrl:LocalController, inMC:MovieClip) : Void {

		// check if movie data exists
		var mcData:MovieData = getMcDataForMovieClip(inCtrl.getTimeline());

		// if not, create new movie data block
		if (mcData == null) {
			mcData = new MovieData(inMC._name, "", inMC);
			mMovies.push(mcData);
		}

		if (!mcData.isCreated) {
			mcData.isCreated = true;
			mcData.localController = inCtrl;
			inCtrl.setName(mcData.name);
		}
	}

	/**
	Handles the event sent by local controllers that their name has been set externally.
	This updates the internal data with the new name
	@param inCtrl: the local controller whose name has been changed
	*/
	public function handleControllerNameChanged (inCtrl:LocalController, inName:String) : Void {
		var mcData:MovieData = getMcDataForMovieClip(inCtrl.getTimeline());
		
		if (mcData == null) {
			Log.warn("Can't change name of movie '" + inCtrl.getTimeline() + "' to '" + inName + "', movie not found", toString());
			return;
		}

		mcData.name = inName;
	}
	
	/**
	Handles the event sent by local controllers to notify that the local controller that sends the event has initialized.
	@param inCtrl:LocalController,  the local controller of the movie clip that has been initialized
	@sends MovieManagerEvent#ON_MOVIE_INITIALIZED
	*/
	public function movieInitialized (inCtrl:LocalController) : Void {
		var mcData:MovieData = getMcDataForMovieClip(inCtrl.getTimeline());
		if (mcData == null) {
			Log.error("movieInitialized; data for movie with movieclip '" + inCtrl.getTimeline() + "' not found", toString());
			return;
		}

		if (!mcData.isInitialized) {
			mcData.isInitialized = true;

			// dispatch onMovieInitialized event
			dispatchEvent(new MovieManagerEvent(MovieManagerEvent.ON_MOVIE_INITIALIZED, this, mcData.name, mcData.localController));

			checkProgress(mcData);
		}
	}
	
	/**
	The {@link org.asapframework.util.loader.Loader} loader class used by MovieManager.
	*/
	public function get loader () : Loader {
		
		return mLoader;
	}
	
	public function set loader (inLoader:Loader) : Void {
		if (mLoader != undefined) {
			// un-register events
			mLoader.removeEventListener(LoaderEvent.ON_DONE, this);
			mLoader.removeEventListener(LoaderEvent.ON_ERROR, this);
		}

		mLoader = inLoader;
		// register for event handling
		mLoader.addEventListener(LoaderEvent.ON_DONE, this);
		mLoader.addEventListener(LoaderEvent.ON_ERROR, this);
	}

	/**
	Adds a movie with specified properties to the list, after checking if a movie with the same name exists already
	Note: If you want to re-use the same movieclip for multiple SWFs, use {@link #removeMovie}; otherwise use a different movieclip holder for each loaded SWF.
	@param inName: unique identifying name for the movie to be loaded
	@param inURL: url where the swf can be found
	@param inMovieClip: movieclip object in which the swf is to be loaded
	@return : false if another movie with the same name exists in the list, otherwise true
	*/
	private function addMovie (inName:String, inURL:String, inMovieClip:MovieClip) : Boolean {
		var mcData:MovieData = getMcData(inName);
		if (mcData != null) {
			Log.error("addMovie; movie with name '" + inName + "' is already added to MovieManager", toString());
			return false;
		}

		// mcData does not exist
		mcData = new MovieData(inName, inURL, inMovieClip);
		mMovies.push(mcData);

		return true;
	}

	/**
	Handles the event sent by the loader to notify that the movie has been loaded (100%)
	if the movie with the specified name is found, the movie is set to "loaded" 
	@param e: event object with members: .name, .type, .target
	@sends MovieManagerEvent#ON_MOVIE_LOADED
	*/
	private function onLoadDone (e:LoaderEvent) : Void {
		var mcData:MovieData = getMcData(e.name);
		if (mcData == null) {
			Log.error("onLoadDone; data for movie with name '" + e.name + "' not found", toString());
			return;
		}

		mcData.isLoaded = true;

		// dispatch onMovieLoaded event
		dispatchEvent(new MovieManagerEvent(MovieManagerEvent.ON_MOVIE_LOADED, this, e.name, mcData.localController));

		checkProgress(mcData);
	}

	/**
	Check whether the movie has been created, loaded and initialized.
	If so, send event onMovieReady
	@param inData:MovieData, the data block for the movie to be checked
	@sends MovieManagerEvent#ON_MOVIE_READY
	*/
	private function checkProgress (inData:MovieData) : Void {
		if (inData.isCreated && inData.isLoaded && inData.isInitialized) {
			dispatchEvent(new MovieManagerEvent(MovieManagerEvent.ON_MOVIE_READY, this, inData.name, inData.localController));
		}
	}
	
	/**
	Handles the event sent by the loader to notify that there was an error loading the file
	@param e: event object with members: .name, .type, .target
	*/
	private function onLoadError ( e:LoaderEvent ) : Void {
		Log.error("onLoadError: error loading " + e.name, toString());
	}
	
	/**
	Retrieves the movie data for the movie specified by the identifier
	@param inName : the name to be used as identifier
	@return : null if the movie data was not found, otherwise an object of type MovieData
	*/
	private function getMcData (inName:String) : MovieData {
		var len:Number = mMovies.length;
		for (var i:Number=0; i<len; ++i) {
			var mcData:MovieData = MovieData(mMovies[i]);
			if (mcData.name == inName) {
				return mcData;
			}
		}
		return null;
	}
	
	/**
	Retrieves the movie data for the movie specified by a movieclip reference
	@param inMc : the movieclip reference
	@return : null if the movie data was not found, or an object of type MovieData
	*/
	private function getMcDataForMovieClip (inMc:MovieClip) : MovieData {
		var len:Number = mMovies.length;
		for (var i:Number=0; i<len; ++i) {
			var mcData:MovieData = MovieData(mMovies[i]);
			if (mcData.mc == inMc) {
				return mcData;
			}
		}
		return null;
	}
	
	/**
	Retrieves in the list the index of the movie specified by the identifier
	@param inName : the name to be used as identifier
	@return : the index in the list, or -1 if the movie data was not found 
	*/
	private function getMovieIndex (inName:String) : Number {
		var len:Number = mMovies.length;
		for (var i:Number=0; i<len; ++i) {
			if (MovieData(mMovies[i]).name == inName) {
				return i;
			}
		}
		return -1;
	}

	/**
	*
	*/
	public function toString () : String {
		return ";org.asapframework.util.moviemanagement.MovieManager";
	}	
}
