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

import org.asapframework.management.movie.LocalController;

/**
Class to store information about a external (separately loaded) SWF movie - used internally by {@link MovieManager} to store and retrieve data.
MovieData stores properties of the movie, such as container clip, name, url and localController, and the state of the SWF: whether it has been created , loaded and initialized.

The state flags have the following meaning:
<ul>
	<li><b>isCreated</b> is true when the constructor of the local controller of the movie to load is called.</li>
	<li><b>isLoaded</b> is true when the loader has signalled that the loading is complete</li>
	<li><b>isInitialized</b> is true when the function notifyMovieInitialized() of the local manager of the movie to load has been called.
</ul>
*/

class org.asapframework.management.movie.MovieData {
	public var mc:MovieClip;	/**< Movieclip controlled by the localController */
	public var name:String;		/**< Identifyer */
	public var url:String;		/**< url from which an swf has been loaded */
	public var isCreated:Boolean;	/**< Indicates whether a LocalController has been created */
	public var isLoaded:Boolean;	/**< Indicates whether the swf has been loaded */
	public var isInitialized:Boolean;	/**< Indicates if the LocalController has signalled notifyMovieInitialized */
	public var localController:LocalController;	/**< The LocalController of the movieclip */

	
	/**
		Class constructor
		@param inName: unique identifying name of movie
		@param inURL: url where the swf can be found
		@param inMovieClip: movieclip in which the swf will be or has been loaded
	*/
	public function MovieData (inName:String, inURL:String, inMovieClip:MovieClip) {
		mc = inMovieClip;
		name = inName;
		url = inURL;

		isLoaded = false;
		isCreated = false;
		isInitialized = false;
	}
	
	public function toString () : String {
		return ";org.asapframework.management.movie.MovieData" + "\n\t mc = " + mc + "\n\t name = " + name + "\n\t url = " + url + "\n\t isLoaded = " + isLoaded + "\n\t isCreated = " + isCreated + "\n\t isInitialized = " + isInitialized;
	}
}
