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
Data structure for {@link NotificationCenter}.
@author Arthur Clemens
*/

class org.asapframework.events.notificationcenter.NotificationObserverData {

	public var observer:Object;
	public var method:String;
	public var note:String;
	public var object:Object;
	
	public function NotificationObserverData (inObserver:Object,
											  inMethod:String,
											  inNote:String,
											  inObject:Object) {
		observer = inObserver;
		method = inMethod;
		note = inNote;
		object = inObject;
	}
	
	/**
	Tests if the variables of the current NotificationObserverData object is equal to the passed parameters.
	*/
	public function isEqualToParams (inObserver:Object,
									 inMethod:String,
									 inNote:String,
									 inObject:Object) : Boolean
	{
		if (observer == inObserver &&
			method == inMethod &&
			note == inNote &&
			object == inObject) {
			return true;
		}
		return false;	
	}
	
	public function toString () : String
	{
		return "NotificationObserverData: observer=" + observer + "; method=" + method + ";note=" + note + "; object=" + object;
	}
	
}