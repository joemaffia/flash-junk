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

import org.asapframework.events.Event;
import org.asapframework.management.focus.FocusManager;
import org.asapframework.management.focus.IFocus;

/**
	Subclass of {@link org.asapframework.events.Event} used by the {@link org.asapframework.management.focus.FocusManager} to send its events.

	@usage:
	<code>
		var myFocus:FocusManager = new FocusManager();
		myFocus.addEventListener(FocusEvent.ON_CHANGE_FOCUS, EventDelegate.create(this, onChangeFocus));
	</code>
*/

class org.asapframework.management.focus.FocusEvent extends Event {
	public static var ON_CHANGE_FOCUS:String = "onChangeFocus";	/**< Constant name of the event being sent */
	
	public var previous:IFocus;	/**< The element that had focus before the current */
	public var current:IFocus;	/**< The element that currently has focus */

	function FocusEvent (inType:String, inSource:FocusManager, inPrevious:IFocus, inCurrent:IFocus ) {
		super(inType, inSource);

		previous = inPrevious;
		current = inCurrent;
	}
}
