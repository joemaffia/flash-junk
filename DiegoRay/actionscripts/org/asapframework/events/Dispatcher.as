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

/**
Base class that contains the EventDispatcher mix-in and initialization.

@use
For any class that is to dispatch events, and that does not extend MovieClip, extend this class.
For classes that do extend MovieClip, use {@link EventMovieClip}.

Example extending a class:
<code>
import org.asapframework.events.Dispatcher;
import org.asapframework.events.Event;

class DataManager extends Dispatcher {
	public static var EVENT_XML_LOADED:String = "onXMLLoaded";

	// call <i>super</i> to initialize EventDispatcher
	private function DataManager () {
		super;
	}
			
	private function handleXMLLoaded () {
		<b>dispatchEvent</b>(new Event(DataManager.EVENT_XML_LOADED));
	}
}
</code>

Example using this extended class, supposing it implements the Singleton pattern:
<code>
import org.asapframework.events.EventDelegate;

DataManager.getInstance().addEventListener(DataManager.EVENT_XML_LOADED, EventDelegate.create(this, handleXMLLoaded));
</code>
*/


class org.asapframework.events.Dispatcher {
	
	// mix-in EventDispatcher
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;

	/**
	*	Call super() in any extending class to initialize EventDispatcher.
	*	If the constructor is public, the call to super can be left out since Flash calls it automatically.
	*/
	public function Dispatcher () {
		
		// initialize EventDispatcher
		EventDispatcher.initialize(this);
	}
}
