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
ValueObject class that holds data for a text item. 
Classes that implement {@link IMultiLanguageTextContainer} get this type of data from the LanguageManager.
Basic info contained in this class is the text and the id by which it is referenced.
Optional info are offset values for changing textfields.
*/
 
class org.asapframework.management.lang.ItemData {

	public var text:String;
	public var id:Number;
	public var width_offset:Number = 0;
	public var x_offset:Number = 0;
	public var y_offset:Number = 0;
	
	/**
	
	*/
	public function ItemData (inID:Number, inText:String) {
		id = inID;
		text = inText;
	}
}