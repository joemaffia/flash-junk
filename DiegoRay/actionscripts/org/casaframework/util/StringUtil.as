/*
	CASA Framework for ActionScript 2.0
	Copyright (C) 2007  CASA Framework
	http://casaframework.org
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

/**
	@author Aaron Clinger
	@author Mike Creighton
	@version 05/09/07
*/

class org.casaframework.util.StringUtil {
	
	/**
		Transforms source string to per word capitalization.
		
		@param source: String to return as title cased.
		@return String with capitalized words.
	*/
	public static function toTitleCase(source:String):String {
		var w:Array  = source.split(' ');
		var i:Number = -1;
		
		while (++i < w.length)
			w[i] = StringUtil.replaceAt(w[i], 0, w[i].charAt(0).toUpperCase());
		
		return w.join(' ');
	}
	
	/**
		Removes all numeric characters from string.
		
		@param source: String to remove numbers from.
		@return String with numbers removed.
	*/
	public static function removeNumbersFromString(source:String):String {
		var i:Number = -1;
		
		while (++i < source.length) {
			if (!isNaN(source.charAt(i))) {
				source = StringUtil.removeAt(source, i);
				i--;
			}
		}
		
		return source;
	}
	
	/**
		Removes all non numeric characters from string.
		
		@param source: String to return numbers from.
		@return String containing only numbers.
	*/
	public static function getNumbersFromString(source:String):String {
		var i:Number = -1;
		
		while (++i < source.length) {
			if (isNaN(source.charAt(i))) {
				source = StringUtil.removeAt(source, i);
				i--;
			}
		}
		
		return source;
	}
	
	/**
		Determines if string contains search string.
		
		@param source: String to search in.
		@param search: String to search for.
		@return Returns the frequency of the search term found in source string.
	*/
	public static function contains(source:String, search:String):Number {
		var i:Number     = source.indexOf(search);
		var total:Number = 0;
		
		while (i > -1) {
			i = source.indexOf(search, i + 1);
			total++;
		}
		
		return total;
	}
	
	/**
		Strips whitespace (or other characters) from the beginning of a string.
		
		@param source: String to remove characters from.
		@param removeChars: <strong>[optional]</strong> Characters to strip (case sensitive); defaults to all whitespace characters.
		@return String with characters removed.
	*/
	public static function trimLeft(source:String, removeChars:String):String {
		removeChars = (removeChars == undefined) ? ' \n\r\t' : removeChars;
		
		var i:Number = -1;
		while (++i < source.length)
			if (removeChars.indexOf(source.charAt(i)) == -1)
				break;
		
		return source.slice(i);
	}
	
	/**
		Strips whitespace (or other characters) from the end of a string.
		
		@param source: String to remove characters from.
		@param removeChars: <strong>[optional]</strong> Characters to strip (case sensitive); defaults to all whitespace characters.
		@return String with characters removed.
	*/
	public static function trimRight(source:String, removeChars:String):String {
		removeChars = (removeChars == undefined) ? ' \n\r\t' : removeChars;
		
		var i:Number = source.length;
		while (i--)
			if (removeChars.indexOf(source.charAt(i)) == -1)
				break;
		
		return source.slice(0, i + 1);
	}
	
	/**
		Strips whitespace (or other characters) from the beginning and end of a string.
		
		@param source: String to remove characters from.
		@param removeChars: <strong>[optional]</strong> Characters to strip (case sensitive); defaults to all whitespace characters.
		@return String with characters removed.
	*/
	public static function trim(source:String, removeChars:String):String {
		return StringUtil.trimLeft(StringUtil.trimRight(source, removeChars), removeChars);
	}
	
	/**
		Removes additional spaces from string.
		
		@param source: String to remove extra spaces from.
		@return String with additional spaces removed.
	*/
	public static function removeExtraSpaces(source:String):String {
		while (source.indexOf('  ') > -1)
			source = StringUtil.replace(source, '  ', ' ');
		
		return source;
	}
	
	/**
		Removes tabs, linefeeds, carriage returns and spaces from string.
		
		@param source: String to remove whitespace from.
		@return String with whitespace removed.
	*/
	public static function removeWhitespace(source:String):String {
		return StringUtil.remove(StringUtil.remove(StringUtil.remove(StringUtil.remove(source, ' '), '\n'), '\t'), '\r');
	}
	
	/**
		Removes characters from a source string.
		
		@param source: String to remove characters from.
		@param remove: String describing characters to remove.
		@return String with characters removed.
	*/
	public static function remove(source:String, remove:String):String {
		return StringUtil.replace(source, remove, '');
	}
	
	/**
		Replaces target characters with new characters.
		
		@param source: String to replace characters from.
		@param remove: String describing characters to remove.
		@param replace: String to replace removed characters.
		@return String with characters replaced.
	*/
	public static function replace(source:String, remove:String, replace:String):String {
		return source.split(remove).join(replace);
	}
	
	/**
		Removes a character at a specific index.
		
		@param source: String to remove character from.
		@param position: Position of character to remove.
		@return String with character removed.
	*/
	public static function removeAt(source:String, position:Number):String {
		return StringUtil.replaceAt(source, position, '');
	}
	
	/**
		Replaces a character at a specific index with new characters.
		
		@param source: String to replace characters from.
		@param position: Position of character to replace.
		@param replace: String to replace removed character.
		@return String with character replaced.
	*/
	public static function replaceAt(source:String, position:Number, replace:String):String {
		var parts:Array = source.split('');
		parts.splice(position, 1, replace);
		return parts.join('');
	}
	
	/**
		Adds characters at a specific index.
		
		@param source: String to add characters to.
		@param position: Position in which to add characters.
		@param addition: String to add.
		@return String with characters added.
	*/
	public static function addAt(source:String, position:Number, addition:String):String {
		var parts:Array = source.split('');
		parts.splice(position, 0, addition);
		return parts.join('');
	}
	
	/**
		Extracts all the unique characters from a source String.
		
		@param source: String to find unique characters within.
		@return String containing unique characters from source String.
	*/
	public static function getUniqueCharacters(source:String) : String {
		var unique:String = '';
		var i:Number      = -1;
		var char:String;
		
		while (++i < source.length){
			char = source.charAt(i);
			
			if (unique.indexOf(char) == -1)
				unique += char;
		}
		
		return unique;
	}
	
	private function StringUtil() {} // Prevents instance creation
}
