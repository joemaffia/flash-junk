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
A collection of String manipulation methods.
Specialized String methods can be found in {@link StringUtilsTrim} and {@link StringUtilsSplit}.
@author Stephan Bezoen
*/

class org.asapframework.util.StringUtils {

	private static var TAB:Number = 9;
	private static var LINEFEED:Number = 10;
	private static var CARRIAGE:Number = 13;
	private static var SPACE:Number = 32;

	/**
	@description Removes the specified string from a source string.
	@param source : Text to remove from
	@param remove : String to remove
	@returns : Modified string.
	@example <code>StringUtils.remove("This is my String","my "); // returns "This is String"</code>
	*/
	public static function remove ( inSource:String, inRemove:String ) : String {

		// use replace to replay 'inKey' with an empty string
		return replace(inSource, inRemove, "");
	}

	/**
	@description Replaces a string with another string.
	@param source : Text to remove from
	@param remove : String to remove
	@param replace : Replacement string
	@returns : Modified string.
	@example <code>StringUtils.replace("This is my String", "my", "not a"); // returns "This is not a String"</code>
	*/
	public static function replace (inSource:String, inRemove:String, inReplace:String) : String {
		var index:Number = inSource.indexOf(inRemove);
		var result:String = inSource;
		while (index >= 0) {
			result = result.substr(0, index) + inReplace + result.substr(index + inRemove.length);
			index += inReplace.length;
			index = result.indexOf(inRemove, index);
		}
		return result;
	}

	/**
	@description Formats a number to a specific format.
    @param inNumber : the number to format
	@param inThouDelim : (optional) the characters used to delimit thousands, millions, etcetera; "," if not specified
	@param inDecDelim : (optional) the characters used to delimit the fractional portion from the whole number; "." if not specified
	@param inFillLength : (optional) the number of leading characters to be added to the part *before* the decimals delimiter
	@param inFillChar : (optional) the character to use to fill with; zero ("0") if not specified
	@returns : A new formatted string.
	@example
	<code>
	StringUtils.format(169315625,"."); // returns 169.315.625
	
	StringUtils.format(1044.58364, ".", ",", 2); // returns 1.044,58364
	
	StringUtils.format(5234524.45, ".", ",", 9, "0"); // returns 005.234.524,45
	</code>				 
	*/
	public static function format (inNumber:Number,
								   inThouDelim:String,
								   inDecDelim:String,
								   inFillLength:Number,
								   inFillChar:String) : String {
		
		// Default to a comma for thousands, and a period for decimals
		var thouDelim:String = (inThouDelim != undefined) ? inThouDelim : ",";
		var decDelim:String = (inDecDelim != undefined) ? inDecDelim : ".";

		// Convert the number to a string, and split it at the decimal point.
		var numberAsString:String = String(inNumber);
		var parts:Array = numberAsString.split(".");
		
		// get first part
		var val:String = parts[0];
		
		// If inFillLength is defined, add the necessary number of leading characters first.
		if (inFillLength != undefined && inFillLength != null) {
			
			// what char to use?
			var char:String = (inFillChar == undefined)? "0" : inFillChar;
			
			// Store the original length before adding spaces.
			var origLength:Number = val.length;
			for (var i:Number=0; i<inFillLength-origLength; ++i) {
				val = char + val;
			}
		}

		// Take the whole number portion and store it as an array of single characters.
		// This makes it easier to insert the thousands delimiters, as needed.
		var partOneAr:Array = val.split("");

		// Reverse the array, so we can process the characters right-to-left.
		partOneAr.reverse();

		// Insert the thousands delimiter after every third character.
		var counter:Number = 0;
		for (var i:Number=0; i<partOneAr.length; ++i) {
			counter++;
			if (counter > 3) {
				counter = 0;
				partOneAr.splice(i, 0, thouDelim);
			}
		}

		// Reverse the array again so that it is back in the original order.
		partOneAr.reverse();

		// Create the formatted string, using the inDecDelim if necessary.
		val = partOneAr.join("");
		
		// join with decimals 
		if (parts[1] != undefined) {
			val += decDelim + parts[1];
		}

		// Return the value.
		return val;
	}
	
	/**
	Appends characters to a "stringified" number. For instance, "0" can have zeroes appended to 2 decimals after the fraction to make "0.00". 
	@param inString : the text to append to
	@param inAppendString : the text to append
	@param inDecimalPlaces : the number of characters to append after the fraction character
	@param inShouldDelimit : (optional) if true, the resulting appending string is limited to the number of inDecimalPlaces; default false
	@param inDecDelim : (optional) the fraction character; "." if not specified
	@example
	<code>
	var myString:String = StringUtils.appendDecimalString("0", "0", 2); // "0.00"
	
	var myString:String = StringUtils.appendDecimalString("3.1", "0", 2); // "3.10"

	var myString:String = StringUtils.appendDecimalString("3.123456789", "12", 2, true); // "3.12"
	
	var myString:String = StringUtils.appendDecimalString("3", "0", 2, null, ","); // "3,00"
	</code>
	*/
	public static function appendDecimalString (inString:String,
												inAppendString:String,
												inDecimalPlaces:Number,
												inShouldDelimit:Boolean,
												inDecDelim:String) : String {

		var decDelim:String = (inDecDelim != undefined) ? inDecDelim : ".";
		var parts:Array = inString.split(".");
		if (parts[1] == undefined) {
			parts[1] = "";
		}

		var places:Number = inDecimalPlaces - parts[1].length;

		if (places < 0) {
			// remove from decimal
			if (inShouldDelimit) {
				parts[1] = parts[1].substr(0, inDecimalPlaces);
			}
		}
		if (places > 0) {
			var appendString:String = inAppendString.substr(0, places);
			
			while (places-- && parts[1].length < inDecimalPlaces) {
				parts[1] += appendString;
			}
		}

		if (parts[1].length > 0) {
			return parts.join(decDelim);
		}
		return parts.join("");
	}

	/**
	Transforms specific characters of string to uppercase, leaves rest untouched.
	@param inString : String to convert
	@param inOffset : Number of character to convert to uppercase (zero based)
	@returns : Modified string.
	@example <code>StringUtils.capitalizeChar("this is a text", 8); // returns "this is A text"</code>
	*/
	public static function capitalizeChar ( inString:String, inOffset:Number ) : String {

		// return modified string
		return inString.substring(0, inOffset) + inString.charAt(inOffset).toUpperCase() + inString.substr(inOffset+1);
	}

	/**
	Transforms the first character of string to uppercase, all others lowercase.
	@param inString : String to convert
	@returns : Modified string.
	@example <code>StringUtils.capitalizeString("giMME a caP, pLEAsE"); // returns "Gimme a cap, please"</code>
	*/
	public static function capitalizeString ( inString:String ) : String {

		// return modified string
		return inString.charAt(0).toUpperCase() + inString.substr(1).toLowerCase();
	}

	/**
	Transforms the first character of all words in a string to uppercase.
	@param inString : String to convert
	@returns : Modified string.
	@example <code>StringUtils.capitalizeWords("gimme a CAP, please"); // returns "Gimme A Cap, Please"</code>
	*/
	public static function capitalizeWords ( inString:String ) : String {

		var words:Array = inString.split(" ");

		for (var i:Number = 0; i<words.length; ++i) {
			words[i] = capitalizeChar(words[i], 0);
		}

		// return modified string
		return (words.join(" "));
	}

	/**
	Checks if an email address is correctly formed. It only checks position of the '@' and last '.'
	@param inAddress : A String containing an email address to be validated
	@returns : a Boolean, true if the email address is valid, otherwise false.
	*/
	public static function validateEmail (inAddress:String) : Boolean {
				
		if ((inAddress == undefined) || (inAddress == "")) return false;

		// check '@'
		var indexOf_AtSign:Number = inAddress.indexOf("@");
		if (indexOf_AtSign < 1) return false;

		// check '.'
		var lastIndexOf_Dot:Number = inAddress.lastIndexOf(".");
		if ((lastIndexOf_Dot < indexOf_AtSign + 2) || (lastIndexOf_Dot >= inAddress.length - 2)) return false;

		return true;
	}

}
