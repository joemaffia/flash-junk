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
String trimmming methods.
More string manipulation methods in {@link StringUtils}.
@author Arthur Clemens
*/

class org.asapframework.util.StringUtilsTrim {

	public static var QUOTE_CHAR:String = "\"";
	public static var TAB_CHAR:String = "\t";
	public static var LINEFEED_CHAR:String = "\n";
	public static var CARRIAGE_CHAR:String = "\r";
	public static var SPACE_CHAR:String = " ";
	public static var WHITESPACE_CHARS:String = StringUtilsTrim.TAB_CHAR + StringUtilsTrim.LINEFEED_CHAR + StringUtilsTrim.CARRIAGE_CHAR + StringUtilsTrim.SPACE_CHAR; /**< All whitespace characters: tab, linefeed, carriage return, space. */

	/**
	Removes specified characters at the left side of a string.
	@param inString : String to convert
	@param inRemoveChars : characters to remove
	@return The trimmed string.
	*/
	public static function leftTrimForChars (inString:String, inRemoveChars:String) : String {
		var from:Number = 0;
		var to:Number = inString.length;
		while (from < to && inRemoveChars.indexOf(inString.charAt(from)) >= 0) {
			from++;
		}
		return (from > 0 ? inString.substr(from, to) : inString);
	}
	
	/**
	Removes specified characters at the right side of a string.
	@param inString : String to convert
	@param inRemoveChars : characters to remove
	@return The trimmed string.
	*/
	public static function rightTrimForChars (inString:String, inRemoveChars:String) : String {
		var from:Number = 0;
		var to:Number = inString.length - 1;
		while (from < to && inRemoveChars.indexOf(inString.charAt(to)) >= 0) {
			to--;
		}
		return (to >= 0 ? inString.substr(from, to+1) : inString);
	}
	
	/**
	Removes whitespace characters ({@link #WHITESPACE_CHARS}) at the right side of a string.
	@return The trimmed string.
	*/
	public static function rtrim (inString:String) : String {
							
		return StringUtilsTrim.rightTrimForChars(inString, StringUtilsTrim.WHITESPACE_CHARS);
	}
	
	/**
	Removes whitespace characters ({@link #WHITESPACE_CHARS}) at the left side of a string.
	@return The trimmed string.
	*/
	public static function ltrim (inString:String) : String {

		return StringUtilsTrim.leftTrimForChars(inString, StringUtilsTrim.WHITESPACE_CHARS);
	}
	
	/**
	Removes whitespace characters ({@link #WHITESPACE_CHARS}) at both sides of a string.
	@param inString : String to convert
	@return The trimmed string.
	*/
	public static function trim (inString:String) : String {

		return StringUtilsTrim.ltrim(StringUtilsTrim.rtrim(inString));
	}

}