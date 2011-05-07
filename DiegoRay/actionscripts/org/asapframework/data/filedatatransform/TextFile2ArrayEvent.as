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

/**
Event object that is dispatched by {@link TextFile2Array}.
@author Arthur Clemens
*/
class org.asapframework.data.filedatatransform.TextFile2ArrayEvent extends Event {

	public static var FINISHED:String = "onTextFile2ArrayFinished";

	public var array:Array;
	
	/**
	Creates a new event with the name of the event handler and the source of the event.
	@param inType : String, name of event and of handler function
	@param inArray : the collection object (Array) that is passed from TextFile2Array to its listener
	*/
	public function TextFile2ArrayEvent (inType:String,
										 inArray:Array) {
		super(inType);
		array = inArray[0];
	}
}
