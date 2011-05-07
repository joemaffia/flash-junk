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
import org.asapframework.events.Event;
import org.asapframework.management.movie.*;

/**	
Used by the {@link org.asapframework.management.movie.MovieManager} to send events about the status of movies.
*/

class org.asapframework.management.movie.MovieManagerEvent extends Event {
	public static var ON_MOVIE_INITIALIZED:String = "onMovieInitialized";
	public static var ON_MOVIE_LOADED:String = "onMovieLoaded";
	public static var ON_MOVIE_READY:String = "onMovieReady";

	public var name:String;
	public var controller:LocalController;

	function MovieManagerEvent (inType:String, inSource:MovieManager, inName:String, inController:LocalController) {
		super(inType, inSource);

		name = inName;
		controller = inController;
	}
}
