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
import org.asapframework.management.sound.EventSound;

/**
*	Event extension used by {@link org.asapframework.management.sound.EventSound}
*/

class org.asapframework.management.sound.EventSoundEvent extends Event {
	
	public static var ON_COMPLETE:String = "onEventSoundComplete";
	public static var ON_LOADED:String = "onEventSoundLoaded";
	
	public var success:Boolean;	/**< Indicates successful loading when the ON_LOADED event is broadcast */

	/**
	*	Constructor
	*	@param inType: type of event to be broadcast
	*	@param inSource: EventSound object sending event
	*	@param inSuccess: Indicates successful loading when the ON_LOADED event is broadcast
	*/
	function EventSoundEvent (inType:String, inSource:EventSound, inSuccess:Boolean) {
		super(inType, inSource);
		success = inSuccess;
	}
}
