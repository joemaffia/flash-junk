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

/**
*	Event extension used by {@link org.asapframework.management.sound.SoundClip}
*/

import org.asapframework.events.Event;
import org.asapframework.management.sound.SoundClip;

class org.asapframework.management.sound.SoundClipEvent extends Event {
	/** Event sent when an external sound has been loaded successfully */
	public static var ON_LOADED:String = "onSoundClipLoaded";
	/** Event sent when there was an error loading an external sound */
	public static var ON_ERROR:String = "onSoundClipLoadError";
	
	public var name:String;

	/**
	*	Constructor
	*	@param inType: type of event to send
	*	@param inSource: SoundClip source of event
	*	@param inName: name of SoundClip source
	*/
	function SoundClipEvent (inType:String, inSource:SoundClip, inName:String) {
		super(inType, inSource);
		name = inName;
	}
}
