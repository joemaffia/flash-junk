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
Base class for dispatching events with EventDispatcher. 
The EventDispatcher.dispatchEvent() expects an object with at least one property, 'type:String', which is the identifier of the event.
This is either the function that is called when the event is dispatched, or the link through Delegate to the function to be called.
Another (optional) property is 'target:Object', which is the source of the event.If this is left out, EventDispatcher puts the sending object in the property to ensure its presence and validity.

The base class contains these two properties as public properties, and a constructor to create an event fit for dispatching. As such, the class can be used to send events without any further information.
If more information must be sent, the class can be extended to contain more properties. The proposed pattern for the Event class and its subclasses is a ValueObject, with public properties.

@example:
<code>
	public static var EVENT_BUTTON_CLICKED:String = "onButtonClicked";
	dispatchEvent(new Event(EVENT_BUTTON_CLICKED, this));
</code>
*/

class org.asapframework.events.Event {
	public var type:String;
	public var target:Object;

	/**
	Creates a new event with the name of the event handler and the source of the event.
	@param inType:String, name of event (and name of handler function when no Delegate is used)
	@param inSource:Object, (optional) source of event
	*/
	function Event (inType:String, inSource:Object) {
		type = inType;
		target = inSource;
	}
}
