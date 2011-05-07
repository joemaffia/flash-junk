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

import org.asapframework.data.loader.IParsable;
import org.asapframework.util.xml.XML2Object;

/**
Class for parsing Object data, usually from {@link XML2Object#parseXML}, into DataValueObject classes.
The class provides static functions for calling {@link IParsable#parseObject} on newly created objects of a specified type, either for single data blocks or for an array of similar data.
The Parser removes the tedious for-loop from the location where the XML data is loaded, and moves the parsing of the XML data to the location where it's used for the first time: the DataValueObject class. Your application can use this data, that contains typed variables, without ever caring about the original source of the data.
When the XML structure is changed, only the parsing function in the DataValueObject class has to be changed, thereby facilitating maintenance and development.

@use
Consider an XML file with the following content:
<code>
<?xml version="1.0" encoding="UTF-8"?>
	<settings>
		<urls>
			<url name="addressform" url="../xml/address.xml" />
			<url name="entries" url="../xml/entries.xml" />
		</urls>
	</settings>
</code>
See the {@link DataLoader} for an example of how to load this XML and get it as an Object. Once the XML has been loaded and parsed into an Object, it can be converted into an Array of URLData objects with the following code:
<code>
	// objects of type URLData
	private var mURLs:Array;
	
	// parse an Object containing converted XML
	// @param o: Object from DataLoader or XML2Object
	// @return true if parsing went ok, otherwise false
	private function handleSettingsLoaded (o:Object) : Boolean {
		mURLs = Parser.parseList(o.settings.urls.url, org.asapframework.data.loader.URLData, false);
		
		return (mURLs != null);
	}
</code>
After calling this function, the member variable <code>mURLs</code> contains a list of objects of type URLData, filled with the content of the XML file.

Notes to this code:
<ul>
<li>The first parameter to {@link #parseList} is a (can be a) repeating node where each node contains similar data to be parsed into </li>
<li>Conversion of nodes to an Array is not necessary. If the {@code <urls>}-node in the aforementioned XML file would contain only one {@code <url>}-node, the parser still returns an Array, with one object of type URLData.</li>
<li>Since the last parameter to the call to {@link #parseList} is false, an error in the xml data will result in mURLs being null. The parsing class determines if the data is valid or not, by returning true or false from parseObject().</li>
</ul> 
*/
 
class org.asapframework.data.loader.Parser {
	/**
	*	Parse an array of objects from XML into an array of the specified class instance by calling its parseObject function
	*	@param inObject: object from XML2Object (usually), will be converted to an Array if it isn't already
	*	@param f: classname to be instanced
	*	@param ignoreError: if true, the return value of {@link #parseObject} is always added to the array, and the array itself is returned. Otherwise, an error in parsing will return null.
	*	@return Array of new objects of the specified type, cast to IParsable, or null if parsing returned false
	*/
	public static function parseList (inListObj:Object, f:Function, ignoreError:Boolean) : Array {
		var list:Array = XML2Object.makeArray(inListObj);
		 
		var a:Array = new Array();
		
		var len:Number = list.length;
		for (var i : Number = 0; i < len; i++) {
			var newObject:IParsable = parseObject(list[i], f, ignoreError);
			if ((newObject == null) && !ignoreError) return null;
			else a.push(newObject);
		}
		
		return a;
	}
	
	/**
	*	Parse an object from XML into the specified class instance by calling its parseObject function
	*	@param inObject: object from XML2Object (usually)
	*	@param f: classname to be instanced
	*	@param ignoreError: if true, the return value of {@link IParsable#parseObject} is ignored, and the newly created object is always returned.
	*	@return a new object of the specified type, cast to IParsable, or null if parsing returned false
	*/
	public static function parseObject (inObject:Object, f:Function, ignoreError:Boolean) : IParsable {
		var ip:IParsable = new f();
		if (ip.parseObject(inObject) || ignoreError) {
			return ip;
		} else {
			return null;
		}
	}
	
}
