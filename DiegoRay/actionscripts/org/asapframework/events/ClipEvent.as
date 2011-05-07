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

/**
General event class for events related to movieclips.
As the type of the event is undefined, it is left to the user to use this event only where applicable.
Example to notify the nearest LocalController that the clip has loaded:
<code>
	public static var EVENT_CLIP_LOADED:String = "onClipLoaded";

	var lc:LocalController = MovieManager.getInstance().getNearestLocalController(this);
	addEventListener(EVENT_CLIP_LOADED, lc);
	dispatchEvent(new ClipEvent(EVENT_CLIP_LOADED, this));
}
</code>
*/

class org.asapframework.events.ClipEvent extends Event {

	public var mc:MovieClip;
	public var name:String;

	public function ClipEvent (inType:String, inSource:MovieClip) {
		super(inType, inSource);

		mc = inSource;
		name = inSource._name;
	}
}
