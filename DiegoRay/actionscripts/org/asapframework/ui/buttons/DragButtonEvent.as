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
import org.asapframework.ui.buttons.DragButton;

class org.asapframework.ui.buttons.DragButtonEvent extends Event {
	public static var ON_MOVE:String = "onDragMove";
	public static var ON_START:String = "onDragStart";
	public static var ON_END:String = "onDragEnd";
	
	public var buttonName:String;
	function DragButtonEvent (inType:String, inSource:DragButton, inBtnName:String) {
		super(inType, inSource);
		buttonName = inBtnName;
	}
}
