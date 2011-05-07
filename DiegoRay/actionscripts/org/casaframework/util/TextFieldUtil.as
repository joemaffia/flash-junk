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
	@version 08/02/07
*/

class org.casaframework.util.TextFieldUtil {
	
	/**
		Determines if textfield has more text than can be displayed at once.
		
		@param target_txt: Textfield or {@link CoreTextField} to check for text overflow.
		@return Returns <code>true</code> if textfield has overflow text; otherwise <code>false</code>.
	*/
	public static function hasOverFlow(target_txt:Object):Boolean {
		return target_txt.maxscroll > 1;
	}
	
	/**
		Removes text overflow on a plain text textfield with the option of an ommission indicator.
		
		@param target_txt: Textfield or {@link CoreTextField} to remove overflow.
		@param omissionIndicator: <strong>[optional]</strong> Text indication that an omission has occured; normally <code>"..."</code>; defaults to no indication.
		@return Returns the omitted text; if there was no text ommitted function returns a empty String (<code>""</code>).
	*/
	public static function removeOverFlow(target_txt:Object, omissionIndicator:String):String {
		if (!TextFieldUtil.hasOverFlow(target_txt))
			return '';
		
		if (omissionIndicator == undefined)
			omissionIndicator = '';
		
		var originalCopy:String        = target_txt.text;
		var lines:Array                = target_txt.text.split('. ');
		var isStillOverflowing:Boolean = false;
		var words:Array;
		var lastSentence:String;
		var sentences:String;
		var overFlow:String;
		
		while (TextFieldUtil.hasOverFlow(target_txt)) {
			lastSentence    = String(lines.pop());
			target_txt.text = (lines.length == 0) ? '' : lines.join('. ') + '. ';
		}
		
		sentences         = (lines.length == 0) ? '' : lines.join('. ') + '. ';
		words             = lastSentence.split(' ');
		target_txt.text  += lastSentence;
		
		while (TextFieldUtil.hasOverFlow(target_txt)) {
			if (words.length == 0) {
				isStillOverflowing = true;
				break;
			} else {
				words.pop();
				
				if (words.length == 0)
					target_txt.text = sentences.substr(0, -1) + omissionIndicator;
				else
					target_txt.text = sentences + words.join(' ') + omissionIndicator;
			}
		}
		
		if (isStillOverflowing) {
			words = target_txt.text.split(' ');
			
			while (TextFieldUtil.hasOverFlow(target_txt)) {
				words.pop();
				target_txt.text = words.join(' ') + omissionIndicator;
			}
		}
		
		overFlow = originalCopy.substring(target_txt.text.length);
		
		return (overFlow.charAt(0) == ' ') ? overFlow.substring(1) : overFlow;
	}
	
	private function TextFieldUtil() {} // Prevents instance creation
}
