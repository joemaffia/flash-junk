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

import org.asapframework.events.notificationcenter.Notification;
import org.asapframework.events.notificationcenter.NotificationObserverData;
import org.asapframework.util.debug.Log;

/**
NotificationCenter provides a way for objects that don't know about each other to communicate. It receives Notification objects and broadcasts them to all interested objects.<br />
This is an almost complete ActionScript implementation of Apple Cocoa's <a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/index.html">NSNotificationCenter</a>.
@author Arthur Clemens
@use
Add an observer:
<code>
NotificationCenter.getDefaultCenter().addObserver(this,
												  "handleAdviceAccordionDidUpdate",
												  "AdviceAccordionDidUpdateNotification");
</code>
The 'this' object will now listen to the notifications with name "AdviceAccordionDidUpdateNotification". This notification can be sent by any object, also from the timeline (see below).
When the notification "AdviceAccordionDidUpdateNotification" is posted, method <code>handleAdviceAccordionDidUpdate</code> is called (second argument).
<hr>
The receiving class (the 'this' in the example above) should implement the method handleAdviceAccordionDidUpdate:
<code>
private function handleAdviceAccordionDidUpdate (inNote:Notification) : Void
{
	var notificationName:String = inNote.name;
	var notificationObject:Object = inNote.object;
	var productData:Object = inNote.data;
	// do something with productData ...
}
</code>
<hr />
In a class, let's say class A, the object will post a notification like this:
<code>
NotificationCenter.getDefaultCenter().post("AdviceAccordionDidUpdateNotification",
										   null,
										   prodData);
</code>
In our example, <code>prodData</code> is an object that will be used by the receiving class.
<hr />
Unregister the observer from the notification with:
<code>
NotificationCenter.getDefaultCenter().removeObserver(this,
													 "AdviceAccordionDidUpdateNotification");
</code>
<hr />
<b>Timeline notifications</b>
The whole idea is that the posting object does not have to know the receiving object. This can be useful for sending an event somewhere from a (nested) timeline.

For example we want to draw a background before playing an external movie. At the last frame of the background drawing, we put:
<code>
stop();

import org.asapframework.events.notificationcenter.NotificationCenter;
NotificationCenter.getDefaultCenter().post("MovieBackgroundDidFinishNotification");
</code>
And in our manager class we implement:
<code>
NotificationCenter.getDefaultCenter().addObserver(this,
												  "handleMovieBackgroundDidFinishNotification",
												  "MovieBackgroundDidFinishNotification");
</code>
<hr />
<b>On naming</b><br />
Apple uses a naming convention for notification names. Examples of notification names are:
<verbatim>
Task<span style="color:green">Did</span>Terminate<span style="color:orange">Notification</span>
Menu<span style="color:green">Will</span>Fold<span style="color:orange">Notification</span>
</verbatim>
So the formula is:
<verbatim>
Class of Affected Object + <span style="color:green">Did/Will</span> + Action + <span style="color:orange">Notification</span>
</verbatim>
@todo Find out if this can be used for Key-value observing similar to <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueObserving/Concepts/DependentKeys.html">Cocoa's Registering Dependent Keys</a>.
*/

class org.asapframework.events.notificationcenter.NotificationCenter {

	private static var DEFAULT_NOTIFICATION_NAME:String = "__0__";

	private static var sDefaultCenter:NotificationCenter = new NotificationCenter(true);
	private var mObservers:Object; /**< Key value object with notification name as key and an array as value; the array stores a value object with the properties observer, method, note and object. */
	private var mObjects:Object; /**< For optimized object retrieval in post; key value object with object name as key and an array as value; the array stores NotificationObserverData objects */
	private var mTempCleanupList:Array; /**< Marked observerData objects to be removed */
	private var mCheckOnAdding:Boolean; /**< Check for doubles flag */
	private var mNotifyErrors:Boolean;	/**< Will report errrors flag */
	
	/**
	Creates a new NotificationCenter. Call this constructor only if you explicitely don't want to use the default NotificationCenter, for instance if you want to control performance.
	@param inShouldNotifyErrors (optional) if true, the NotificationCenter will report errors to the {@link Console}; by default error reporting is off.
	@see #getDefaultCenter
	*/
	public function NotificationCenter (inShouldNotifyErrors:Boolean)
	{
		mObservers = {};
		mObjects = {};
		mTempCleanupList = [];
		mCheckOnAdding = false;
		mNotifyErrors = (inShouldNotifyErrors != undefined) ? inShouldNotifyErrors : false;
	}
	
	/**
	@param inFlag : If true, NotificationCenter will report errors to the {@link Console}. Error reporting is off by default.
	*/
	public function setNotifyErrors (inFlag:Boolean) : Void
	{
		mNotifyErrors = inFlag;
	}
	
	/**
	Accesses the default notification center. For most cases you can just use this default notification center. If performance becomes problematic (if you have a few thousand observers, and need to do frequent adding and removing) it makes sense to instantiate a custom NotificationCenter object. 
	@return Reference to the static NotificationCenter (Singleton).
	*/
	public static function getDefaultCenter () : NotificationCenter
	{
		return sDefaultCenter;
	}
	
	/**
	Registers inObserver to receive notifications with the name inNotificationName and/or containing inNotificationObject.
	When a notification of name inNotificationName containing the object inNotificationObject is posted, inObserver's method inMethodName is called with a {@link Notification} as the argument. If inNotificationName is undefined, the notification center notifies the observer of all notifications with an object matching inNotificationObject. If inNotificationObject is nil, the notification center notifies the observer of all notifications with the name inNotificationName. inObserver may not be undefined.
	@param inObserver : object to receive notifications
	@param inMethodName : The observer's method that will be called when sent a notification. This method should only have one argument (of type Notification).
	@param inNotificationName : (optional) notification identifier name; if undefined, you must use inNotificationObject
	@param inNotificationObject : (optional) notification identifier object; the notification center notifies the observer of all notifications with an object matching this object
	@example
	This example adds an observer 'this', to let method 'doSomething' be called as soon as the notification named 'PanelWillUpdateNotification' is posted:
	<code>
	NotificationCenter.getDefaultCenter().addObserver(this,
													  "doSomething",
													  "PanelWillUpdateNotification");
	</code>
	<hr />
	In the following example, we don't specify a notification name:
	<code>
	NotificationCenter.getDefaultCenter().addObserver(this,
													  "updatePanel",
													  null,
													  myPanel);
	</code>
	Now all notifications with 'myPanel' as object argument will be passed (we'll pass the current time as data):
	<code>
	NotificationCenter.getDefaultCenter().post(null,
											   myPanel,
											   getTimer());
	</code>
	*/
	public function addObserver (inObserver:Object,
								 inMethodName:String,
								 inNotificationName:String,
								 inNotificationObject:Object) : Void
	{	
		if (inNotificationName == undefined) {
			inNotificationName = DEFAULT_NOTIFICATION_NAME; // dummy because empty string cannot be searched on
		}
		if (mObservers[inNotificationName] == undefined) {
			mObservers[inNotificationName] = new Array();
		}
		// check if alreay in list with the same arguments
		if (mNotifyErrors && mCheckOnAdding && contains(mObservers, inObserver, inMethodName, inNotificationName, inNotificationObject)) {
			Log.warn("addObserver - Observer already added with same arguments: '" + arguments + "' -- not added.", toString());
			return;
		}
		var observerData:NotificationObserverData = new NotificationObserverData(inObserver,
																				 inMethodName,
																				  inNotificationName,
																				 inNotificationObject);
		mObservers[inNotificationName].push(observerData);
		
		// optimize object handling, to retrieve all messages targeted to the object
		if (inNotificationObject != null) {
			if (mCheckOnAdding && contains(mObjects, inObserver, inMethodName, inNotificationName, inNotificationObject)) {
				// No warning, should be covered by previous warning message.
				return;
			}
			if (mObjects[inNotificationObject] == undefined) {
				mObjects[inNotificationObject] = new Array();
			}
			mObjects[inNotificationObject].push(observerData);
		}
	}
	
	/**
	Set checking for doubles when calling addObserver. If true, each entry is checked if it is already in the list. For performance, checking is off by default.
	@param inFlag : When true, newly added observers will be checked if they are already in the list.
	*/
	public function checkOnAdding (inFlag:Boolean) : Void
	{
		mCheckOnAdding = inFlag;
	}
	
	/**
	Removes inObserver as the observer of notifications with the name inNotificationName and object inNotificationObject from the object. inObserver may not be nil. Be sure to invoke this method before removing the observer object or any object specified in addObserver.
	If inNotificationName is nil, inObserver is removed as an observer of all notifications containing inNotificationObject. If inNotificationObject is nil, inObserver is removed as an observer of inNotificationName containing any object.
	@param inObserver: observing object
	@param inNotificationName: (optional) notification identifier name; if undefined, you must use inNotificationObject
	@param inNotificationObject: (optional) notification identifier object; specify when the observer listens to notifications with an object matching this object
	@example
	To unregister someObserver from all notifications it had previously registered for, you would send this method:
	<code>
	NotificationCenter.getDefaultCenter().removeObserver(someObserver);
	</code>
	To unregister the observer from the  particular notification theNotificationName, use:
	<code>
	NotificationCenter.getDefaultCenter().removeObserver(someObserver, theNotificationName);
	</code>
	*/
	public function removeObserver (inObserver:Object,
									inNotificationName:String,
									inNotificationObject:Object) : Void
	{
		if (mObservers[inNotificationName].length == 0) {
			if (mNotifyErrors) {
				Log.info("removeObserver - Nothing to remove.", toString());
			}
			return;
		}
		var removed:Boolean;
		removed = removeFromCollection(mObservers, inObserver, inNotificationName, inNotificationObject);
		if (mNotifyErrors && !removed) {
			Log.warn("removeObserver - Nothing removed from mObservers: " + arguments, toString());
		}
		if (inNotificationObject != null) {
			removed = removeFromCollection(mObjects, inObserver, inNotificationName, inNotificationObject);
			if (mNotifyErrors && !removed) {
				Log.warn("removeObserver - Nothing removed from mObjects: " + arguments, toString());
			}
		}
		
		// erase marked observerData objects
		var len:Number = mTempCleanupList.length;
		if (len > 0) {
			if (mNotifyErrors) {
				Log.info("removeObserver - Removing: " + len + " objects.", toString());
			}
			var i:Number = len;
			while (--i != -1) {
				removeObject(mTempCleanupList[i]);
			}
			mTempCleanupList = [];
		}
	}
	
	/**
	Creates a {@link Notification} instance and passes this to the observers associated through inNotificationName or inNotificationObject.
	@param inNotificationName : (optional) notification identifier name; if undefined, you must use inNotificationObject
	@param inNotificationObject : (optional) notification identifier object; typically the object posting the notification; may be null; if not null, any message is sent that is directed to this object
	@param inData : (optional) object to pass - this will be packed in the Notification
	@example
	This example finds all observers that are associated with the notification name 'ButtonDidUpdateNotification', and passes them a Notification object with data "My message".
	<code>
	NotificationCenter.getDefaultCenter().post("ButtonDidUpdateNotification",
											   null,
											   "My message");
	</code>
	The following example sends a notification to the observers that are associated with identifier object <i>anIdentifier</i>. Note that the name of the notification is not important when you pass an object - it may be an empty string. The object is associated with the observer in addObserver (<i>the notification center notifies the observer of all notifications with an object matching inNotificationObject</i>).
	<code>
	var anIdentifier:Object = this;
	NotificationCenter.getDefaultCenter().post(null,
											   anIdentifier,
											   "My message");
	</code>
	*/
	public function post (inNotificationName:String,
						  inNotificationObject:Object,
						  inData:Object) : Void
	{
		var noteName:String = (inNotificationName != undefined) ? inNotificationName : DEFAULT_NOTIFICATION_NAME;
		
		var observers:Array;
		
		if (inNotificationObject == null) {
			observers = mObservers[noteName];
		} else {
			observers = mObjects[inNotificationObject];
		}
		
		if (mNotifyErrors) {
			if ( observers.length == 0 || observers.length == undefined) {
				Log.error("postNotificationName - No notification with name '" + noteName + "' known.", toString());
				return;
			}
		}
		var len:Number = observers.length;
		var i:Number = len;
		while (--i != -1) {
			var observerData:NotificationObserverData = NotificationObserverData(observers[i]);
			if (noteName != observerData.note) {
				if ((observerData.note != DEFAULT_NOTIFICATION_NAME) || inNotificationObject == null) {
					// proceed
				} else {
					continue; // skip
				}
			}
			
			if (inNotificationObject != observerData.object) {
				continue; // skip
			}
			
			var note:Notification = new Notification(observerData.note, inNotificationObject, inData);
			var func:Function = observerData.observer[observerData.method];
			if (mNotifyErrors && func == undefined) {
				Log.error("postNotificationName - Could not resolve method '" + observerData.method + "' for observer '" + observerData.observer + "'.", toString());
				continue;
			}
			// We are now calling the method directly
			// Another implementation might be to pass the Notification object to the NotificationCenter class and do the calling in another method. 
			func.apply(observerData.observer, [note]);
		}
	}
	
	// PRIVATE METHODS
	
	/**
	Loops through the collection inCollection to check if the item is already present. This is very time consuming with large collections.
	@return True when in list, false when not.
	*/
	private function contains (inCollection:Object,
							   inObserver:Object,
							   inMethodName:String,
							   inNotificationName:String,
							   inNotificationObject:Object) : Boolean
	{
   		for (var n:String in inCollection) {
			var o:Object = inCollection[n];
			var len:Number = o.length;
			var i:Number = len;
			while (--i != -1) {
				var observerData:NotificationObserverData = o[i];
				if (observerData.isEqualToParams(inObserver, inMethodName, inNotificationName, inNotificationObject)) {
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	
	*/
	private function removeFromCollection (inCollection:Object,
										   inObserver:Object,
										   inNotificationName:String,
										   inNotificationObject:Object) : Boolean
	{
		var removed:Boolean = false;
		for (var n:String in inCollection) {
			var o:Object = inCollection[n];
			var len:Number = o.length;
			for (var i:Number = len - 1; i >= 0; --i) {
				var observerData:Object = o[i];
				if (observerData.observer == inObserver) {
					if (inNotificationObject != null && inNotificationName != null) {
						if (observerData.object == inNotificationObject && observerData.note == inNotificationName) {
							mTempCleanupList.push(observerData);
							if (len == 1) {
								delete o; o = null;
							}
							removed = true;
						}
					}
					
					if (inNotificationObject != null && inNotificationName == null) {
						// check for object
						if (observerData.object == inNotificationObject) {
							mTempCleanupList.push(observerData);
							if (len == 1) {
								delete o; o = null;
							}
							removed = true;
						}
					}
					
					if (inNotificationObject == null && inNotificationName != null) {
						// check for notification name
						if (observerData.note == inNotificationName) {
							mTempCleanupList.push(observerData);
							if (len == 1) {
								delete o; o = null;
							}
							removed = true;
						}
					}
					
					// else 
					if (inNotificationObject == null && inNotificationName == null) {
						mTempCleanupList.push(observerData);
						if (len == 1) {
							delete o; o = null;
						}
						removed = true;
					}
				}
			}
		}
		return removed;
	}
	
	/**
	Deletes an object with its properties.
	*/
	private function removeObject (o:Object) : Void
	{
		if (o == null) return;
		for (var n:String in o) {
			delete o[n];
			o[n] = null;
		}
		delete o;
		o = null;
	}
	
	public function toString() : String {
		return ";org.asapframework.events.NotificationCenter";
	}
	
}