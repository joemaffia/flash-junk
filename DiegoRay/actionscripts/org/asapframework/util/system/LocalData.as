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
A class for storing typed data locally. Wraps the SharedObject class.
Based on Colin Moock's class - http://moock.org/asdg/technotes/saveDataToDisk/
@author Martijn de Visser
@example
<code>
// Check if user has visited the site before
var visited:Object = LocalData.loadField("MySite", "visited");
if (visited && Boolean(visited) == true) {
	// do visited code
	// ...
} else {
	// do first time visit code
	// ...
	// Now store 'visited' tag for later user
	LocalData.saveField("MySite", "visited", true);
}
</code>
*/
class org.asapframework.util.system.LocalData {

	/**
	Private constructor: it is not possible to instantiate a LocalData instance. Call the static methods instead.
	*/
	private function LocalData () {}

	/**
	@description Saves a single value to disk using a SharedObject instance.
	@param inRecord : the name of the record to save
	@param inData : the data to save
	@param inPath : (optional) The path to the SharedObject on disk which restricts this record to the swf that saves the data. Leave empty for default path.
	*/
	public static function saveSOL ( inRecord:String, inData:Object, inPath:String ) : Void {

		var so:SharedObject = SharedObject.getLocal(inRecord, inPath);

		// loop provide object and copy properties
		for ( var i:String in inData ) {

			so.data[i] = inData[i];
		}
		
		so.flush();
	}

	/**
	Retrieves a single value from disk using a SharedObject instance.
	@param inRecord : String, The name of the record to retrieve.
	@param inPath : (optional) The path to the SharedObject on disk which restricts this record to the swf that saves the data. Leave empty for default path.
	@return  Object, The value of the specified record.
	*/
	public static function loadSOL ( inRecord:String, inPath:String ) : Object {

		return Object( SharedObject.getLocal(inRecord, inPath).data );
	}

	/**
	Clears the SharedObject instance; on Flash Player 7 the instance is cleared from disk, on lower players all properties are deleted from the object
	@param inRecord String, the name of the record to be cleared
	@param inPath : (optional) The path to the SharedObject on disk which restricts this record to the swf that saves the data. Leave empty for default path.
	*/
	public static function clearSOL (inRecord:String, inPath:String) : Void {
		var so:SharedObject = SharedObject.getLocal(inRecord, inPath);
		if (so.clear != undefined) { // flash player 7 only
			so.clear();
		} else {
			for (var prop:String in so.data) {
				delete so.data[prop];
			}
			so.flush();
		}
	}

	/**
	Saves a single value to disk using a SharedObject instance.
	@param inRecord : String, The name of the record to save.
	@param inField : String, The specific field to save within the specified record.
	@param inData : 
	@param inPath : (optional) String, the path to the cookie on disk, leave empty for default path, which restricts this record to the swf that saves the data
	*/
	public static function saveField( inRecord:String, inField:String, inData:Object, inPath:String ) : Void {

		var so:Object = Object( SharedObject.getLocal(inRecord, inPath) );
		so.data[inField] = inData;
		so.flush();
	}

	/**
	Retrieves a single value from disk using a SharedObject instance.
	@param inRecord : String, the name of the record to retrieve
	@param inField : String, the specific field to retrieve within the specified record
	@param inPath : (optional) String, the path to the cookie on disk, leave empty for default path, which restricts this record to the swf that saves the data
	@return Object, The value of the specified field.
	*/
	public static function loadField ( inRecord:String, inField:String, inPath:String ) : Object {

		return Object( SharedObject.getLocal(inRecord, inPath) ).data[inField];
	}

	public static function toString () : String {
		return "; org.asapframework.util.management.datamanager.LocalData";
	}
}
