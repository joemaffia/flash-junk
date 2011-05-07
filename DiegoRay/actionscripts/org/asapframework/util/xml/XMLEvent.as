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

// ASAP classes
import org.asapframework.events.Event;
import org.asapframework.util.xml.XMLWorker;

/**
 * XML Event Value Object
 */
class org.asapframework.util.xml.XMLEvent extends Event {
	
	public static var ON_ERROR:String = "onXMLLoadError";		/**Constant for 'onXMLLoadError' event */
	public static var ON_LOADED:String = "onXMLLoaded";			/**Constant for 'onXMLLoaded' event 	*/
	public static var ON_TIMEOUT:String = "onXMLTimeout";		/**Constant for 'onXMLTimeout' event 	*/
	public static var ON_ALL_LOADED:String = "onAllXMLLoaded";	/**Constant for 'onAllXMLLoaded' event */
	
	public var name:String;		/**The name of the XML request */
	public var error:String;	/**The error message (if loading failed) */
	public var status:Number;	/**The status of the loading atempt, its value will either be 0 (success), correspond to one of the ERROR_ constants in the XMLLoader class, of be something else, in which case an unknown error has occured. */
	public var xmlSource:XML;	/**The XML source data that was loaded */

	function XMLEvent (inType:String, inSource:XMLWorker, inName:String, inError:String, inStatus:Number ) {
		
		super(inType, inSource);
		name = inName;
		error = inError;
		status = inStatus;
		xmlSource = inSource.xml;
	}
}
