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
import org.asapframework.util.xml.XMLWorker;

/**
*	XMLWrapper Event
*/
class org.asapframework.util.xml.XMLWorkerEvent extends Event {

	public static var ON_LOADED:String = "onXMLLoaded";		/**Constant for 'onXMLLoaded' event 	*/
	public static var ON_TIMEOUT:String = "onXMLTimeout";	/**Constant for 'onXMLTimeout' event 	*/
	
	public var result:Boolean;
	public var status:Number;
	public var worker:XMLWorker;

	function XMLWorkerEvent (inType:String, inSource:XMLWorker, inResult:Boolean, inStatus:Number) {
		
		super(inType, inSource);
		worker = inSource;
		result = inResult;
		status = inStatus;
	}
}
