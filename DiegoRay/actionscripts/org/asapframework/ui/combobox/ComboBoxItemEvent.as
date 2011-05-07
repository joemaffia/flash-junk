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
import org.asapframework.ui.combobox.ComboBoxItem;

class org.asapframework.ui.combobox.ComboBoxItemEvent extends Event {
	public static var ON_ITEM_CLICKED:String = "onItemClicked";

	public var name:String;

	public function ComboBoxItemEvent (inType:String, inItem:ComboBoxItem, inName:String) {
		super(inType, inItem);

		name = inName;
	}
}
