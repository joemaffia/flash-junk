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
import org.asapframework.management.sound.EventSound;
import org.asapframework.management.sound.EventSoundEvent;
import org.asapframework.management.sound.SoundClipEvent;
import org.asapframework.util.debug.Log;

/**
*	The SoundClip class is used for controlling individual sounds through the {@link SoundManager} class.
*	For most common operations, such as starting, stopping and setting volume, it is recommended to use the SoundManager functions instead of the SoundClip. 
*/

class org.asapframework.management.sound.SoundClip extends Dispatcher {
	
	private var mName:String;
	private var mMovieName:String;
	private var mSound:EventSound;
	private var mMc:MovieClip;
	private var mVolume:Number;
	private var mIsPlaying:Boolean = false;
	private var mIsLooping:Boolean = false;
	private var mIsLoaded:Boolean;
	private var mIsExternal:Boolean = false;
	private var mURL:String;
	private var mIsStreaming:Boolean = false;


	/**
	*	Constructor
	*	@param inName: unique identifying name
	*	@param inMovieName: name of the container movie that contains the movieclip for this sound
	*	@param inSound: the EventSound object that contains or will contain the actual sound
	*	@param inMovieClip: the movieclip that owns the sound
	*	@param inVolume: the initial volume of the sound
	*/
	public function SoundClip (inName:String, inMovieName:String, inSound:EventSound, inMovieClip:MovieClip, inVolume:Number) {

		super();

		mName = inName;
		mMovieName = inMovieName;
		sound = inSound;
		mMc = inMovieClip;
		volume = inVolume;
	}

	/**
	*	Load an external sound from a url. An event (either SoundClipEvent.ON_LOADED or SoundClipEvent.ON_ERROR) is fired after loading. On local systems, this event can come during this call.
	*	The sound is loaded entirely before it can be played.
	*	@param inUrl: the url for the sound to be loaded.
	*/
	public function loadExternalSound (inUrl:String) : Void {
		mURL = inUrl;
		
		mIsExternal = true;
		
		mIsLoaded = false;
		mSound.loadSound(inUrl, false);
	}

	/**
	*	The identifying name
	*/
	public function get name () : String {
		return mName;
	}

	/**
	*	The name of the container movie
	*/
	public function get movieName () : String {
		return mMovieName;
	}

	/**
	*	The EventSound object that contains the actual sound
	*/
	public function get sound () : EventSound {
		return mSound;
	}

	public function set sound (inSound:EventSound) : Void {
		if (mSound){
			mSound.removeEventListener(EventSoundEvent.ON_COMPLETE, this);
			mSound.removeEventListener(EventSoundEvent.ON_LOADED, this);
		}
		mSound = inSound;
		mSound.addEventListener(EventSoundEvent.ON_COMPLETE, this);
		mSound.addEventListener(EventSoundEvent.ON_LOADED, this);
	}

	/**
	*	The movieclip that owns the sound
	*/
	public function get movieclip () : MovieClip {
		return mMc;
	}

	/**
	*	true if the sound is playing
	*/
	public function get isPlaying () : Boolean {
		return mIsPlaying;
	}

	/**
	*	true if the sound loops
	*/
	public function get isLooping () : Boolean {
		return mIsLooping;
	}

	/**
	*	The volume of the sound, 0 - 100
	*/
	public function get volume () : Number {
		return mVolume;
	}

	public function set volume (inVolume:Number) : Void {
		mVolume = inVolume;
		mSound.setVolume(mVolume);
	}

	/**
	*	True if an external sound has loaded
	*/
	public function get isLoaded () : Boolean {
		return mIsLoaded;
	}

	/**
	*	True if the sound is external
	*/
	public function get isExternal () : Boolean {
		return mIsExternal;
	}
	
	/**-----------------------------------------------------------------------
	*	The url of the external sound
	-------------------------------------------------------------------------*/
	public function get url () : String {
		return mURL;
	}

	/**
	*	Set the sound to stream when playing, and the url to play a stream from. This does not start playing - use {@link #startSound} for that purpose.
	*	@param inURL: the url of the sound to be streamed
	*/
	public function setStreaming (inURL:String) : Void {
		mURL = inURL;
		mIsExternal = true;
		mIsStreaming = true;
		mIsLoaded = true;
	}

	/**
	*	Start playing the sound. If it is playing, stop it first.
	*	@param playCount: the number of times to play the sound. If 0 or less, the sound loops infinitely
	*/
	public function startSound (playCount:Number) : Void {
		if (mIsPlaying){
			mSound.stop();
		}
		mIsLooping = (playCount <= 0);

		if (mIsStreaming) {
			mSound.loadSound(mURL, true);
		} else {
			// loop if playCount <= 0, otherwise play playCount number of times
			mSound.start(0, mIsLooping ? 10000 : playCount);
		}
		mIsPlaying = true;
	}

	/**
	*	Stop the sound
	*/	
	public function stop () : Void {
		mSound.stop();
		mIsPlaying = false;
	}

	/**
	*	Set the volume of the sound to 0. The original volume is preserved, and can be restored with {@link unmute()}.
	*/
	public function mute () : Void {
		mSound.setVolume(0);
	}

	/**
	*	Restore the original volume of the sound.
	*/
	public function unmute () : Void {
		mSound.setVolume(mVolume);
	}

	/**
	*	Event handler for the onSoundComplete event from the EventSound object. Is called when a sound is done playing.
	*	If a sound loops, it gets played a large number of times in a loop by the Flash player. When done with the large number, this event is fired.
	*	Restarting the sound after receiving this event results in a small glitch in the sound. 
	*/
	private function onEventSoundComplete () : Void {
		if (mIsLooping) {
			startSound(0);
		} else {
			mIsPlaying = false;
		}
	}

	/**
	*	Event handler for the onLoad event from the EventSound object. Is called when an external sound has been loaded, or an error has occurred.
	*	@sends SoundClipEvent#ON_LOADED
	*	@sends SoundClipEvent.ON_ERROR
	*/
	private function onEventSoundLoaded (e:EventSoundEvent) : Void {
		mIsLoaded = e.success;
		if (mIsLoaded){
			mSound.setVolume(mVolume);
			// dispatch onSoundClipLoaded event
			dispatchEvent(new SoundClipEvent(SoundClipEvent.ON_LOADED, this, mName));
		} else {
			// dispatch onSoundClipLoadError event
			dispatchEvent(new SoundClipEvent(SoundClipEvent.ON_ERROR, this, mName));
		}
	}
	
	public function toString () : String {
		return "; org.asapframework.management.sound.SoundClip: " + mName;
	}
}
