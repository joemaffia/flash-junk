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

import org.asapframework.util.StringUtilsTrim;

/**
Split trimmming methods.
More string manipulation methods in {@link StringUtils}.
@author Arthur Clemens
*/

class org.asapframework.util.StringUtilsSplit {

	public static var QUOTE_CHAR:String = "\"";
	
	/**
	Splits a line of text in components - separated by inDelimiter - and returns a components array. The components are trimmed from whitespace.
	This method preserves text inside double quoteContents ("").
	@param inText: the text string to split
	@param inDelimiter: the string delimiter
	@return The components array.
	*/
	public static function splitAndPreserveQuotes (inText:String,
												   inDelimiter:String) : Array
	{
		
		var placeholder:String = "ASAPQUOTEPLACEHOLDER";
		
		var quoteContents:Array = new Array();
		var quoteComponents:Array = inText.split(QUOTE_CHAR);
		// temporarily store quoted strings
		// use placeholder in their place
		var s:String = "";
		var hasQuote:Boolean = false;

		var i:Number, ilen:Number = quoteComponents.length;
		if (ilen > 0) {
			hasQuote = true;
			for (i=0; i<ilen; ++i) {
				if (i%2 == 0) {
					// even: no quoteContents contents
					s += quoteComponents[i];
				} else {
					// uneven: quoted contents
					// store quote contents
					quoteContents.push(quoteComponents[i]);
					// write placeholder
					s += placeholder;
				}
			}
		} else {
			s = inText;
		}

		var components:Array = s.split(inDelimiter);
		ilen = components.length;
		for (i=0; i<ilen; ++i) {
			// clean up

			components[i] = StringUtilsTrim.trim(components[i]);
			if (hasQuote) {
				// put original text in place of placeholder
				var a:Array = components[i].split(placeholder);
				var j:Number, jlen:Number = a.length;
				s = "";
				for (j=0; j<jlen; ++j) {
					if (j%2 == 0) {
						s += a[j];
					} else {
						s += QUOTE_CHAR + String(quoteContents.shift()) + QUOTE_CHAR;
					}
				}
				components[i] = s;
			}
		}
		return components;
	}

}