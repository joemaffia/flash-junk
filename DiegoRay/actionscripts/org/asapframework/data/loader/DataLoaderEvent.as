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

import org.asapframework.data.loader.DataLoader;
import org.asapframework.events.Event;

/**
Event extension used to send events from the {@link DataLoader} class.
 */
 
class org.asapframework.data.loader.DataLoaderEvent extends Event {
	/** Generic event */
	public static var EVENT_DATALOADER:String = "onDataLoaderEvent";
	
	/** subtype of event sent when data has been loaded successfully */
	public static var DATA_LOADED:String = "dataLoaded";
	/** subtype of event sent when an error has occurred */
	public static var ERROR:String = "error";
	
	/** type of event */
	public var subtype:String;
	/** result of XML2Object parsing */
	public var data:Object;
	/** name of original request */
	public var name:String;
	/** error message when something has gone wrong */
	public var error:String;
	
	function DataLoaderEvent(inType : String, inData:Object, inName:String, inSource : DataLoader) {
		super(EVENT_DATALOADER, inSource);
		
		subtype = inType;
		data = inData;
		name = inName;
	}

}