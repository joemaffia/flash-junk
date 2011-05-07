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
import org.asapframework.data.array.TraverseArrayEnumerator;

/**
@author Arthur Clemens
*/

class org.asapframework.data.array.TraverseArrayEnumeratorEvent extends Event {

	public static var UPDATE:String = "onTraverseArrayEnumeratorUpdate";
	
	public var enumerator:TraverseArrayEnumerator;
	public var value:Object;
	
	/**
	@param inType: name of event (and name of handler function when no Delegate is used)
	@param inObject: the object at the TraverseArrayEnumerator pointer position
	@param inEnumerator : the TraverseArrayEnumerator object
	*/
	public function TraverseArrayEnumeratorEvent (inType:String, 	  		  inObject:Object, inEnumerator:TraverseArrayEnumerator) {
		super(inType);
		value = inObject;
		enumerator = inEnumerator;
	}

}
