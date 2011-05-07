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

import org.asapframework.data.KeyValue;

/**
KeyValueList is a dictionary/associative array that stores a list of key-value pairs ({@link KeyValue KeyValue objects}).

KeyValueList uses an Array as storage, so the input order is preserved.
@author Arthur Clemens
@use
This example stores a list of movieclips 
<code>
var LETTERS:Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

mClientLetters = new KeyValueList();
var i:Number, ilen:Number = LETTERS.length;
for (i=0; i<ilen; ++i) {
	var letter:String = LETTERS[i];
	var letterClip:MovieClip = timeline.attachMovie("alphabet letter", letter, timeline.getNextHighestDepth());
	// Each letter gets one letter movieclip
	mClientLetters.addValueForKey(letterClip, letter);
}
</code>
*/

class org.asapframework.data.KeyValueList {

	private static var DEFAULT_ITEM_DELIMITER:String = ",";

	private var mKeyValues:Array; /**< Holds objects of type {@link KeyValue}. */
	
	/**
	Creates a new KeyValueList.
	*/
	public function KeyValueList () {
		mKeyValues = new Array();
	}
	
	/**
	Adds a new KeyValue object to the list.
	@param inValue : value to store
	@param inKey : new key to store the value at
	*/
	public function addValueForKey (inValue:Object, inKey:String) : Void {
		mKeyValues.push(new KeyValue(inKey, inValue));
	}
	
	/**
	Retrieves a stored object for a given key.
	@param inKey : key where object is stored at
	@return (Deliberately untyped) stored object at given key.
	*/
	public function getValueForKey (inKey:String) {
		return mKeyValues[findValueForKey(inKey)].value;
	}
	
	/**
	Stores an object at an existing key. If the key does not exist yet, the key is added.
	@param inValue : value to store
	@param inKey : new key to store the value at
	*/
	public function setValueForKey (inValue:Object, inKey:String) {
	
		var index:Number = findValueForKey(inKey);
		if (index == -1) {
			addValueForKey(inValue, inKey);
			return;
		}
		// else update old entry
		mKeyValues[index].value = inValue;
	}
	
	/**
	Removes an object at a key.
	@param inKey : name of key to remove the object from
	*/
	public function removeValueForKey (inKey:String) : Void {
		var index:Number = findValueForKey(inKey);
		if (index == -1) {
			return;
		}
		mKeyValues.splice(index, 1);
	}
	
	/**
	Removes an object at an array position.
	@param inIndex : array position to remove the object at
	*/
	public function removeObjectAtIndex (inIndex:Number) : Void {
		mKeyValues.splice(inIndex, 1);
	}
	
	/**
	Reference to the internal KeyValue array.
	@return The KeyValue array.
	*/
	public function getArray () : Array {
		return mKeyValues;
	}
	
	/**
	Gets the number of items in the list.
	@return The number of items in the list.
	*/
	public function getCount () : Number {
		return mKeyValues.length;
	}
	
	/**
	Creates a copy of the current KeyValueList except for the keys as passed in inFilterKeys.
	@param inFilterKeys : array of keys that should be filtered out from the returned KeyValueList
	@return A copy of the current KeyValueList except for the keys as passed in inFilterKeys.
	*/
	public function filter (inFilterKeys:Array) : KeyValueList {
		var filterSet:Object = new Object();
		var ilen:Number = inFilterKeys.length;
		for (var i:Number = 0; i<ilen; ++i) {
			var key:String = inFilterKeys[i];
			filterSet[key] = key;
		}
		
		var list:KeyValueList = new KeyValueList();
		var jlen:Number = mKeyValues.length;
		for (var j:Number = 0; j<jlen; ++j) {
			var key:String = mKeyValues[j].key;
			if (filterSet[key] == undefined) {
				list.addValueForKey(mKeyValues[j].value, key);
			}
		}
		return list;
	}
	
	/**
	Creates a String for all KeyValue objects in the list. Each key-value pair is stringified following the pattern <code>key inKeyValueDelimiter value</code>. The key-value pair strings are separated with <code>inItemDelimiter</code>
	@param inKeyValueDelimiter : connecting string between key and value
	@param inItemDelimiter : connecting string between key-value pairs
	@return A new string with formatted key-value strings. Returns an empty String if the list has no items.
	<code>
	var myList:KeyValueList = new KeyValueList();
	myList.addValueForKey("Tolstoj", "Name");
	myList.addValueForKey("Saint Petersburg", "Place of birth");
	var myText:String = myList.stringify(": ", "\n");
	</code>
	Creates:
	<code>
	Name: Tolstoj
	Place of birth: Saint Petersburg
	</code>
	*/
	public function stringify (inKeyValueDelimiter:String, inItemDelimiter:String) : String {
	
		var i:Number, ilen:Number = mKeyValues.length;
		var outString:String = "";
		var itemDelimiter:String = (inItemDelimiter != undefined) ? inItemDelimiter : DEFAULT_ITEM_DELIMITER;
		for (i=0; i<ilen; ++i) {
			outString += mKeyValues[i].stringify(inKeyValueDelimiter);
			if (i < ilen-1) {
				outString += itemDelimiter;
			}
		}
		return outString;
	}
	
	/**
	Returns the list of values as formatted string.
	@param inFormattedString : accepts %1 and %2 as format parameters
	@param inItemDelimiter : (optional) delimiter between items, for example '\n'; default {@link #DEFAULT_ITEM_DELIMITER}
	@return A new string with formatted key-value strings.
	@example
	<code>
	var list:KeyValueList= new KeyValueList();
	list.addValueForKey("Tolstoj", "Author");
	list.addValueForKey("Russia", "Country");
	var myHtml:String = list.stringifyWithFormattedString("<font color='#666666'>%1</font> <font color='#000000'>%2</font>", "\n");
	</code>
	Result:<br \><font color='#666666'>Author</font> <font color='#000000'>Tolstoj</font><br \><font color='#666666'>Country</font> <font color='#000000'>Russia</font>
	*/
	public function stringifyWithFormattedString (inFormattedString:String, inItemDelimiter:String) : String {
	
		var i:Number, ilen:Number = mKeyValues.length;
		var outString:String = "";
		for (i=0; i<ilen; ++i) {
			outString += mKeyValues[i].stringifyWithFormattedString(inFormattedString);
			if (i < ilen-1) {
				outString += inItemDelimiter;
			}
		}
		return outString;
	}
	
	/**
	
	*/
	private function toString () : String {
		return mKeyValues.join(",");
	}
	
	// PRIVATE METHODS
	
	/**
	Retrieves an object for a given key.
	*/
	private function findValueForKey (inKey:String) : Number {
		var i:Number = mKeyValues.length;
		while (i--) {
			if (mKeyValues[i].key == inKey) {
				return i;
			}
		}
		return -1;
	}

}
