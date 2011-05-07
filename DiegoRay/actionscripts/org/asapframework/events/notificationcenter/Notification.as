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

class org.asapframework.events.notificationcenter.Notification {

	public var name:String;
	public var object:Object;
	public var data:Object;
	
	/**
	Creates a new Notification object.
	@param inName: the name of the notification
	@param inObject: the notification object
	@param inData: the notification data
	*/
	public function Notification (inName:String,
								  inObject:Object,
								  inData:Object) {
		name = inName;
		object = inObject;
		data = inData;
	}
	
	/**
	
	*/
	public function toString () : String
	{
		return "Notification: name=" + name + "; object=" + object + "; data=" + data;
	}
	
}