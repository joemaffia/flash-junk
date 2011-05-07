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
import org.asapframework.management.sound.EventSound;
import org.asapframework.management.sound.SoundClip;
import org.asapframework.management.sound.SoundClipEvent;
import org.asapframework.management.sound.SoundMovie;
import org.asapframework.util.debug.Log;

/**
SoundManager provides a single access point to all sounds in a Flash project.
Sounds may be compiled into a SWF movie (<em>internal</em>) or loaded as MP3 files (<em>external</em>).
SoundManager allows access to these sounds from any part in the Flash project.
@use
<code>
import org.asapframework.management.sound.SoundManager;

var theSoundManager:SoundManager = SoundManager.getInstance();
// played sounds need a MovieClip
var mc:MovieClip = createEmptyMovieClip("soundmanager", 0);

theSoundManager.addMovie("main", mc);

theSoundManager.addSound("test10", "main");
theSoundManager.addSound("test11", "main");

theSoundManager.playSound("test10");
theSoundManager.playSound("test11");

onUnload = function () {
	theSoundManager.removeMovie("main");
}
</code>
*/

class org.asapframework.management.sound.SoundManager {

	private var mSounds:Array;
	private var mMovies:Array;
	private var mCurrentLevel:Number = 1;
	
	private static var sInstance:SoundManager = null;
	
	/**
	Private constructor, use {@link #getInstance} to refer to singleton instance.
	*/
	private function SoundManager () {
		mSounds = new Array();
		mMovies = new Array();
	}
	
	/**
	Returns reference to singleton instance of SoundManager
	*/
	public static function getInstance () : SoundManager {
		if (sInstance == null) {
			sInstance = new SoundManager();
		}	
		return sInstance;
	}

	/**
	Add a named movieclip to function as container for sounds
	Make sure the movieclip resides in the same swf as the sounds that will be added to it.
	@param inName: (unique) name of movie to be used as identifier
	@param inClip: the movieclip itself
	@return True if the movie was successfully added, otherwise false (due to non-unique name).
	*/
	public function addMovie (inName:String, inClip:MovieClip) : Boolean {
		if (getMovie(inName)){
			Log.error("addMovie: Movie with name '" + inName + "' already exists, not added", toString());
			return false;
		}
		var movie:SoundMovie = new SoundMovie(inName, inClip);
		mMovies.push(movie);
	}

	/**
	Remove a previously added movie with specified name. Also removes all associated sounds.
	@param inName: (unique) name of a movie
	*/
	public function removeMovie (inName:String) : Void {
		var index:Number = getMovieIndex(inName);
		if (index == -1){
			Log.error("removeMovie: movie with name '" + inName + "' not found, not removed", toString());
			return;
		}
		
		// remove sounds associated with this movie
		removeSoundsInMovie(inName);
		
		// remove soundmovie itself
		mMovies.splice(index, 1);
	}

	/**
	Add a sound from the library, associated with the specified movie name
	@param inLinkageName: linkage id of the sound in the library
	@param inMovieName: name of previously added movieclip in which the sound will be created
	@return True if the sound was successfully added, or false if not. False indicates either that a sound with the specified linkage id has already been added, that the movie with the specified moviename was not found, or that a sound with the specified linkage id does not exist in the library.
	*/
	public function addSound (inLinkageName:String, inMovieName:String) : Boolean {
		// create SoundClip
		var clip:SoundClip = createSoundClip(inLinkageName, inMovieName);
		if (clip == null) return false;

		// attach library sound
		clip.sound.attachSound(inLinkageName);
		
		// check if sound has duration; if not, it's most likely not in the library
		if (clip.sound.duration == undefined) {
			Log.error("addSound: Could not attach sound with linkage id '" + inLinkageName + "'; check the library!", toString());
			return false;
		}
		
		// store in list
		mSounds.push(clip);

		return true;
	}
	
	/**
	Add an external sound. If <code>inIsStreaming</code> is set to false, loading of the external sound starts immediately.
	@param inLinkageName: unique identifier for the sound
	@param inMovieName: name of previously added movie to associate sound with
	@param inUrl: url of sound
	@param inIsStreaming: specify if sound should be loaded entirely before playing (false) or be played streaming (true)
	@param inListener: Object to be added as listener to {@link  SoundClipEvent#ON_LOADED} and {@link SoundClipEvent#ON_ERROR} events from the SoundClip
	@return True if the sound was successfully added. This indicates either that a sound with the specified linkage id has already been added, or that the movie with the specified moviename was not found.
		
	Note that adding an event listener after adding the sound may result in ON_LOADED or ON_ERROR events going missing. If the sound is loaded from the local system, the event can be fired during the addExternalSound call. It is therefore recommended to use the "inListener" property.
		
	@example
	On the timeline, add this code:
	<code>
	com.lostboys.AppController.main(this);
	</code>
	
	Create a new class com.lostboys.AppController, and add the following code:
	<code>
	import org.asapframework.management.sound.SoundClip;
	import org.asapframework.management.sound.SoundClipEvent;
	import org.asapframework.management.sound.SoundManager;
	import org.asapframework.util.debug.Log;
	import org.asapframework.management.movie.LocalController;
	 
	class com.lostboys.AppController extends LocalController {
		private static var TEST_SOUND_NAME:String = "test";
		private static var TEST_SOUND_URL:String = "test.mp3";
		private static var TEST2_SOUND_NAME:String = "test2";
		private static var TEST2_SOUND_URL:String = "test2.mp3";
		private static var SOUND_CONTAINER:String = "main";
		
		
		public function AppController (inMC:MovieClip) {
			super(inMC);
			
			// get sound manager
			var sm:SoundManager = SoundManager.getInstance();
			
			// create sound container clip
			var mc:MovieClip = timeline.createEmptyMovieClip("soundContainer", 0);
			
			// add container clip to sound manager
			sm.addMovie(SOUND_CONTAINER, mc);
			
			// try to add the external sounds, non-streaming so it starts loading immediately
			// For the test, make sure one of these sounds exists, and the other doesn't
			sm.addExternalSound(TEST_SOUND_NAME, SOUND_CONTAINER, TEST_SOUND_URL, false, this);
			sm.addExternalSound(TEST2_SOUND_NAME, SOUND_CONTAINER, TEST2_SOUND_URL, false, this);
		}
			
		//	Event handler for SoundClipEvent.ON_LOADED event from external sounds
		private function onSoundClipLoaded (e:SoundClipEvent) : Void {
			SoundManager.getInstance().playSound(e.name);
		}
	
		//	Event handler for SoundClipEvent.ON_ERROR event from external sounds
		private function onSoundClipLoadError (e:SoundClipEvent) : Void {
			Log.error("Could not load sound with url '" + SoundClip(e.target).url + "'", toString());
		}
			
		//	The main entry point from the timeline
		public static function main (inMC:MovieClip) : Void {
			var controller:AppController = new AppController(inMC);
		}
		
		public function toString() : String {
			return ";com.lostboys.AppController";
		}
	}
	</code>
	
	This will play the sound that exists, and output an error message to the trace window with the url of the non-existent sound file.
	*/
	public function addExternalSound (inLinkageName:String, inMovieName:String, inUrl:String, inIsStreaming:Boolean, inListener:Object) : Boolean {
		// create SoundClip
		var clip:SoundClip = createSoundClip(inLinkageName, inMovieName);
		if (clip == null) return false;
		
		// add listener
		if (inListener != undefined) {
			clip.addEventListener(SoundClipEvent.ON_LOADED, inListener);
			clip.addEventListener(SoundClipEvent.ON_ERROR, inListener);
		}

		if (inIsStreaming) {
			clip.setStreaming(inUrl);
		} else {
			clip.loadExternalSound(inUrl);
		}
		
		// store SoundClip
		mSounds.push(clip);

		return true;
	}

	/**
	Remove a previously added sound
	@param inName: (unique) name
	*/
	public function removeSound (inName:String) : Void {
		var index:Number = getSoundIndex(inName);
		if (index == -1){
			Log.error("removeSound: sound with name '" + inName + "' not found, not removed", toString());
			return;
		}
		mSounds.splice(index, 1);
	}

	/**
	Remove all sounds in a previously added sound container movie
	@param inMovieName: name of movie
	*/
	public function removeSoundsInMovie (inMovieName:String) : Void {
		var clipNames:Array = new Array();
		var movieNames:Array = new Array();
		var i:Number;
		var sLen:Number = mSounds.length;
		for (i=0; i<sLen; ++i){
			var clip:SoundClip = SoundClip(mSounds[i]);
			clipNames.push(clip.name);
			movieNames.push(clip.movieName);
		}		
		
		var j:Number;
		var mLen:Number = movieNames.length;
		for (j=0; j<mLen; ++j) {
			if (String(movieNames[j]) == inMovieName){
				removeSound(clipNames[j]);
			}
		}
	}

	/**
	Play a sound with the specified name and play count. If the sound was playing, it is stopped.
	@param name Sound identifier.
	@param playCount Number of times to play the sound. 0: play in a loop; nothing: play once.
	@return True if successfully started. False indicates that a sound with the specified name has not been added, or that an external sound has not loaded (yet).
	
	@use
	To play a sound once:
	<code>
	SoundManager.getInstance().playSound("test");
	</code>
	
	To play a sound 10 times:
	<code>
	SoundManager.getInstance().playSound("test", 10);
	</code>
		
	To loop a sound:
	<code>
	SoundManager.getInstance().playSound("test", 0);
	</code>
	
	Note: looping is <b>only</b> devoid of glitches with sounds in the library. External sounds are always with a glitch.
	
	Note: in certain cases, when used with an <b>external sound</b> (an mp3 file), you can pass playSound only after a frame has passed. For example from a controller class:
	<code>
	private function onSoundClipLoaded (inName:String) : Void
	{	// passed from SoundClip
		mc.onEnterFrame = function() {
			delete mc.onEnterFrame;
				var theSoundManager:SoundManager = SoundManager.getInstance();
			theSoundManager.playSound("mainsound", 0);
			theSoundManager.setSoundVolume("mainsound", 70);
		}
	}
	</code>
	or you can use the class org.asapframework.util.FrameDelay for this: (example untested!)
	<code>
	private function onSoundClipLoaded (inName:String) : Void
	{	// passed from SoundClip
		new FrameDelay(SoundManager.getInstance(), playSound, ["mainsound", 0]);
	}
	</code>
	*/
	public function playSound (inName:String, inPlayCount:Number) : Boolean {
		var clip:SoundClip = getSound(inName);
		if (clip == null) {
			Log.error("playSound: Sound with name '" + inName + "' not found", toString());
			return false;
		}

		if (clip.isExternal && !clip.isLoaded){
			Log.error("playSound: Sound with name '" + inName + "' not loaded", toString());
			return false;
		}
		clip.stop();
		clip.startSound(inPlayCount == undefined ? 1 : inPlayCount);
		return true;
	}
	
	/**
	Stop the sound with the specified name
	@param inName: identifying name of the sound to be stopped
	@return True if the sound was stopped. False indicates that a sound with the specified name was not added, or that an external sound has not loaded (yet).
	*/
	public function stopSound (inName:String) : Boolean {
		var clip:SoundClip = getSound(inName);
		if (clip == null) return false;

		if (clip.isExternal && !clip.isLoaded){
			Log.error("stopSound: Sound with name '" + inName + "' not loaded", toString());
			return false;
		}
		clip.stop();
	}

	/**
	@param name : Sound identifier.
	@param volume : A number from 0 to 100.
	@return True if successfully applied to sound. False indicates that a sound with the specified name was not added.
	*/
	public function setSoundVolume (inName:String, inVolume:Number) : Boolean {
		var clip:SoundClip = getSound(inName);
		if (clip == null) return false;

		clip.volume = inVolume;
		return true;
	}

	/**
	Stop all sounds.
	Note that this function affects only sounds played with the SoundManager.
	*/
	public function stopAllSounds () : Void {
		for (var i:Number = 0; i < mSounds.length; i++){
			var clip:SoundClip = SoundClip(mSounds[i]);
			clip.stop();
		}
	}

	/**
	Set the volume of all sounds to 0. The original volume is retained, and can be reset with {@link #unmuteAllSounds}.
	Note that this function affects only sounds played with the SoundManager.
	*/
	public function muteAllSounds () : Void {
		for (var i:Number = 0; i < mSounds.length; i++){
			var clip:SoundClip = SoundClip(mSounds[i]);
			clip.mute();
		}
	}

	/**
	Reset the original volume of all sounds.
	Note that this function affects only sounds played with the SoundManager.
	*/
	public function unmuteAllSounds () : Void {
		for (var i:Number = 0; i < mSounds.length; i++){
			var clip:SoundClip = SoundClip(mSounds[i]);
			clip.unmute();
		}
	}

	/**
	Get the SoundClip object for more direct manipulation.
	@param inName: name of the sound for which the SoundClip object is requested
	@return The SoundClip object if found, or null if none was found.
	*/
	public function getSound (inName:String) : SoundClip {
		for (var i:Number = 0; i < mSounds.length; i++){
			var clip:SoundClip = SoundClip(mSounds[i]);
			if (clip.name == inName){
				return clip;
			}
		}
		return null;
	}

	/**
	Return the index of the SoundClip object with the specified name.
	@param inName: name of the object to be found
	@return The index of the sound, or -1 if none was found.
	*/
	private function getSoundIndex (inName:String) : Number {
		for (var i:Number = 0; i < mSounds.length; i++){
			var clip:SoundClip = SoundClip(mSounds[i]);
			if (clip.name == inName){
				return i;
			}
		}
		return -1;
	}

	/**
	Return the movie with the specified name.
	@param inName: name of the movie to be found
	@return The movie, or null if none was found.
	*/
	private function getMovie (inName:String) : SoundMovie {
		for (var i:Number = 0; i < mMovies.length; i++){
			var movie:SoundMovie = SoundMovie(mMovies[i]);
			if (movie.name == inName){
				return movie;
			}
		}
		return null;
	}

	/**
	Return the index of the movie with the specified name
	@param inName: name of the movie to be found
	@return The index, or -1 if none was found.
	*/
	private function getMovieIndex (inName:String) : Number {
		for (var i:Number = 0; i < mMovies.length; i++){
			var movie:SoundMovie = SoundMovie(mMovies[i]);
			if (movie.name == inName){
				return i;
			}
		}
		return -1;
	}
	
	/**
	Create a new SoundClip object with the specified name in the specified movie
	@param inLinkageName: unique identifier for the sound clip
	@param inMovieName: name of the movie in which the sound clip will be created
	@return The created SoundClip, or null if an error occurred. This indicates that a sound with the specified name has been added already, or that the movie with the specified movie name has not been added. 
	*/
	private function createSoundClip (inLinkageName:String, inMovieName:String) : SoundClip {
		var clip:SoundClip = getSound(inLinkageName);
		if (clip != null){
			Log.error("Sound with name '" + inLinkageName + "' already exists in movie '" + clip.movieName + "', not added", toString());
			return null;
		}
		var movie:SoundMovie = getMovie(inMovieName);
		if (movie == null){
			Log.error("Movie with name '" + inMovieName + "' not found, sound with name '" + inLinkageName + "' not added", toString());
			return null;
		}
		var mc:MovieClip = movie.createClip(inLinkageName);
		var sound:EventSound = new EventSound(mc);
		
		clip = new SoundClip(inLinkageName, inMovieName, sound, mc, 100);
		return clip;
	}

	/**
	
	*/
	public function toString () : String {
		return "; org.asapframework.management.sound.SoundManager";
	}

}