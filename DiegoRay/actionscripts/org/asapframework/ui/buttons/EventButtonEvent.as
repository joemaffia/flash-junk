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
import org.asapframework.ui.buttons.EventButton;

class org.asapframework.ui.buttons.EventButtonEvent extends Event {
	public static var ON_ROLLOVER:String = "onEventButtonRollOver";
	public static var ON_ROLLOUT:String = "onEventButtonRollOut";
	public static var ON_PRESS:String = "onEventButtonPress";
	public static var ON_RELEASE:String = "onEventButtonRelease";

	public var buttonName:String;

	function EventButtonEvent (inType:String, inSource:EventButton, inBtnName:String) {
		super(inType, inSource);

		buttonName = inBtnName;
	}
}
