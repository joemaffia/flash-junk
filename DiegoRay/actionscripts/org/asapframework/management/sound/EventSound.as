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

// macromedia classes
import mx.events.EventDispatcher;

// ASAP classes
import org.asapframework.management.sound.EventSoundEvent;
import org.asapframework.util.debug.Log;

/**
*	Extension of Sound class that sends events when internal event handler functions are called.
*	Otherwise functionally compatible with internal Sound class.
*/

class org.asapframework.management.sound.EventSound extends Sound {
	
	/*- mix-in EventDispatcher */
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;

	/**
	*	Constructor.
	*	@param inClip: "owner" of the Sound object
	*/
	function EventSound (inClip:MovieClip) {
		super(inClip);
		// initialize EventDispatcher
		EventDispatcher.initialize(this);
	}

	/**
	*	Handler of the onSoundComplete event, received when a sound is done playing
	*	@sends EventSoundEvent#ON_COMPLETE
	*/
	public function onSoundComplete () : Void {
		// dispatch onSoundClipLoaded event
		dispatchEvent(new EventSoundEvent(EventSoundEvent.ON_COMPLETE, this));
	}

	/**
	*	Handler of the onLoad event, received when an external sound has been loaded
	*	@sends EventSoundEvent#ON_LOADED
	*/
	public function onLoad (inSuccess:Boolean) : Void {
		// dispatch onSoundClipLoaded event
		dispatchEvent(new EventSoundEvent(EventSoundEvent.ON_LOADED, this, inSuccess));
	}

	public function toString() : String {
		return ";org.asapframework.management.sound.EventSound";
	}
}
