/*
Copyright 2005-2006 by the authors of asapframework

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
A collection of Object utility functions.
@author Martijn de Visser
*/

class org.asapframework.util.ObjectUtils {

	// used by traceObject
	private static var sCloseChar:String;
	
	/**
	Clones an object with all its properties (without a reference to the original object).
	@param inObj: Object to clone
	@returns The cloned object.
	*/
	public static function clone ( inObj:Object ) : Object {

		var o:Object = new Object();

		// loop object
		for (var i:String in inObj) {

			// determine what's inside...
			if (typeof(inObj[i]) == "object") {

				// check to see if the variable is an array.
				if (inObj[i] instanceof Array) {

					o[i] = new Array();

				} else {

					o[i] = new Object();
				}

				// object or array, recurse it
				o[i] = clone(inObj[i]);

			} else {

				// primitive, copy property
				o[i] = inObj[i];
			}
		}

		// return the cloned object
		return o;
	}

	/**
	Compares two objects. Please note: this is simple, first setup. Comparing primitives returns true, even if not similar.
	@param inObj1: first object to compare
	@param inObj2: second object to compare
	@returns Boolean, true if objects are similar, false if not.
	*/
	public static function compare ( inObj1:Object, inObj2:Object ) : Boolean {

		for (var i:String in inObj1) {

			if (typeof inObj1[i] == "object") {

				if (typeof inObj2[i] == "object") {

					if (!compare(inObj1[i], inObj2[i])) return false;

				} else {

					return false;

				}

			} else {

				if (inObj2[i] != inObj1[i]) return false;
			}
		}
		return true;
	}

	/**
	Recursively traces the properties of an object
	@param obj: object to trace
	@todo Rewrite so this function returns a string (for usage with Console)
	@todo BUG: The first { is not printed. Probably due to conversion to static method.
	*/
	public static function traceObject ( obj:Object,
										inMaxDepth:Number,
										inOpenChar:String,
										isInited:Boolean,
										openChar:String,
										tabs:String ) : Void	{
											
		if (inMaxDepth == undefined) inMaxDepth = 10;
		if (inMaxDepth < 0) return;
		// based on : http://www.darronschall.com/weblog/archives/000025.cfm

		// initial block is used to signify if the outer character
		// has already been printed to the screen.
		if (!isInited) {
			isInited = true;
			tabs = "";
			if (obj instanceof Array) {
				openChar = "[";
			} else {
				openChar = "\u007B";
			}
			trace(openChar);
		}

		// every time this function is called we'll add another
		// tab to the indention in the output window
		tabs += "\t";

		// loop through everything in the object we're tracing
		for (var i:String in obj) {
			
			// determine what's inside...
			if (typeof(obj[i]) == "string") {
				// display string value
				trace(tabs + i + ": \"" + obj[i] + "\"");				
			} else if (typeof(obj[i]) == "object") {				
				// check to see if the variable is an array.
				if (obj[i] instanceof Array) {

					trace(tabs + i + " : [");

					ObjectUtils.traceObject(obj[i], --inMaxDepth, "[", isInited, openChar, tabs);
				} else {
					// object
					trace(tabs + i + " : \u007B");
					// recursive call
					ObjectUtils.traceObject(obj[i], --inMaxDepth, "\u007B", isInited, openChar, tabs);
				}				
			} else {
				//variable is not an object or string, just trace it out normally
				trace(tabs + i + ": " + obj[i]);
			}
		}
		// here we need to displaying the closing '}' or ']', so we bring
		// the indent back a tab, and set the outerchar to be it's matching
		// closing char, then display it in the output window
		tabs = tabs.substr(0, tabs.length - 1); 
		trace(tabs + (inOpenChar == "[") ? "]" : "}");
	}
}
