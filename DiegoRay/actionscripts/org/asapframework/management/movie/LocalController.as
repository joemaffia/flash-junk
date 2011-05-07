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
import org.asapframework.management.movie.ILocalController;
import org.asapframework.management.movie.MovieManager;
import org.asapframework.util.debug.Log;

/**
(Virtual) base class for controlling movies locally, either independently or embedded.
Extend this class for each separate movie in your project that requires certain complex controlled functionality.
The base class takes care of communication with the MovieManager, so the movie is known to other movies.

The LocalController functions as controller for everything that happens locally.
For other movies, it functions as a Facade, hiding implementation of details.
The preferred mode of communication with the LocalController is through events, to avoid having to know the actual specific interface.
*/

class org.asapframework.management.movie.LocalController extends Dispatcher implements ILocalController {

	/** Name identifier. */
	private var mName:String; 
	/** Movieclip that is controlled by the LocalController. */
	private var mTimeline:MovieClip; 

	/**
	Constructor, performs basic initialization, and notifies the MovieManager that the movie has been created.
	Gets its name from the MovieManager.
	@param inTimeline : movieclip that is controlled by the LocalController, usually the timeline reference from where the LocalController is created
	@example
	On the timeline:
	<code>
	HistoryController.main(this);
	</code>
		
	Inside the class HistoryController:
	<code>
	class HistoryController extends LocalController {
	
		public function HistoryController (inTimeline:MovieClip) {
			super(inTimeline);
			
			// let MovieManager know initialization is done
			notifyMovieInitialized();
		}
		
		// the main entry point of the application
		public static function main (inTimeline:MovieClip) : Void {
			var controller:HistoryController = new HistoryController(inTimeline);
		}
		
		public function toString() {
			return ";HistoryController";
		}
	}
	</code>
	*/
	public function LocalController (inTimeline:MovieClip) {
		
		super(); 

		// block out the empty constructor call
		if (inTimeline == undefined) {
			Log.error("Constructor: Specify timeline to be controlled", toString());
			return;
		}
		
		mTimeline = inTimeline;

		// notify the MovieManager of creation; the name of this controller is set by the MovieManager
		MovieManager.getInstance().movieCreated(this, mTimeline);
	}

	/**
	Let the MovieManager know that the movie is done initializing.
	In specific circumstances you may need to wait at least one enterFrame before calling this (for example using {@link FrameDelay}).
	*/
	public function notifyMovieInitialized () : Void {
		MovieManager.getInstance().movieInitialized(this);
	}

	/**
	Method to perform cleaning up before the LocalController gets deleted.
	Default implementation does nothing.
	Specific behaviour may be implemented in subclasses.
	*/	
	public function kill () : Void {

	}

	/**
	Start the movie. Usually called from the container when onMovieReady event has been received,
	Basic behaviour just shows the movie.
	Specific behaviour may be implemented in subclasses.
	*/
	public function start () : Void {
		show();
	}

	/**
	Stop the movie. Usually called from the container to tell the movie to go away.
	Basic behaviour just hides the movie.
	Specific behaviour may be implemented in subclasses.
	*/
	public function stop () : Void {
		hide();
	}

	/**
	Show the movie. 
	Basic behaviour sets visibility of the root movieclip to true.
	Specific behaviour may be implemented in subclasses.
	*/
	public function show () : Void {
		mTimeline._visible = true;
	}

	/**
	Hide the movie.
	Basic behaviour sets the visibility of the root movieclip to false.
	Specific behaviour may be implemented in subclasses.
	*/
	public function hide () : Void {
		mTimeline._visible = false;
	}

	/**
	Gets the name of the LocalController by which it is uniquely identified.
	@return The name identifier.
	*/
	public function getName () : String {
		return mName;
	}

	/**
	Sets the name of the LocalController by which it is uniquely identified.
	@param inName : name
	*/
	public function setName (inName:String) : Void {
		mName = inName;
		
		MovieManager.getInstance().handleControllerNameChanged(this, inName);
	}

	/**
	Gets the movieclip that this controller controls.
	@return Movieclip
	*/
	public function getTimeline () : MovieClip {
		return mTimeline;
	}
	
	/**
	Return whether the movie that the controller controls, is running embedded or standalone.
	@return True: the movie is running standalone; false: the movie is running embedded.
	*/
	public function isStandalone () : Boolean {
		return (mTimeline == _level0);
	}
	
	/**

	*/
	public function toString () : String {
		return ";org.asapframework.management.movie.LocalController : name = '" + mName + "'";
	}
}
