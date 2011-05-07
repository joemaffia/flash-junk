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
Key-value object class.
@author Arthur Clemens
*/

class org.asapframework.data.KeyValue {

	public var key:String;
	public var value:Object;
	
	/**
	Creates a new KeyValue object.
	@param inKey : (optional) key
	@param inValue : (optional) value
	*/
	public function KeyValue (inKey:String, inValue:Object) {
		if (inKey != undefined) {
			key = inKey;
		}
		if (inValue != undefined) {
			value = inValue;
		}
	}
	
	/**
	Creates a String <code>key inDelimiter value</code>.
	@param inDelimiter : connecting string between key and value
	@return A new String with key, inDelimiter, value. Returns an empty String if value is empty or undefined.
	*/
	public function stringify (inDelimiter:String) : String {
		if (value == undefined || String(value).length == 0) {
			return "";
		}
		var delimiter:String = (inDelimiter != undefined) ? inDelimiter : "=";
		return key + delimiter + value;
	}
	
	/**
	Returns the key-value pairs as formatted string.
	@param inFormattedString : accepts %1 and %2 as format parameters
	@return A new string with the key-values formatted.
	@example
	<code>
	var author:KeyValue= new KeyValue("Author", "Tolstoj");
	var myHtml:String = author.stringifyWithFormattedString("<font color='#666666'>%1</font> <font color='#000000'>%2</font>");
	</code>
	Result:<br \><font color='#666666'>Author</font> <font color='#000000'>Tolstoj</font>
	*/
	public function stringifyWithFormattedString (inFormattedString:String) : String {
		var formattedString:String = replace(inFormattedString, "%1", key);
		formattedString = replace(formattedString, "%2", String(value));
		return formattedString;
	}
	
	/**
	
	*/
	public function toString () : String {
		return stringify("=");
	}
	
	/**
	Replaces a string with another string. See {@link StringUtils#replace}.
	*/
	private function replace ( inSource:String, inRemove:String, inReplace:String ) : String {

		var index:Number = inSource.indexOf(inRemove);
		while (index >= 0) {
			inSource = inSource.substr(0, index) + inReplace + inSource.substr(index + inRemove.length);
			index = inSource.indexOf(inRemove, index+1);
		}
		return inSource;
	}
	
}