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

import org.casaframework.util.StringUtil;
import org.casaframework.util.ArrayUtil;
import org.casaframework.util.ObjectUtil;

/**
	@author Aaron Clinger
	@version 05/02/07
*/

class org.casaframework.util.ValidationUtil {
	
	/**
		Determines if string is a valid email address.
		
		@param email: String to verify as email.
		@return Returns <code>true</code> if string is a valid email; otherwise <code>false</code>.
	*/
	public static function isEmail(email:String):Boolean {
		if (email.length < 6 || ValidationUtil.isEmpty(email))
			return false;
		
		if (StringUtil.contains(email, ' ') > 0)
			return false;
		
		if (StringUtil.contains(email, '@') != 1)
			return false;
		
		var atSign:Number  = email.indexOf('@');
		var lastDot:Number = email.lastIndexOf('.');
		
		if ((lastDot < atSign + 2) || (lastDot > email.length - 3))
			return false;
		
		return true;
	}
	
	/**
		Determines if numbers in string are equal to or greater than a valid phone number length.
		
		@param phone: String to verify the containing numbers are equal or above 10 numbers in length.
		@return Returns <code>true</code> if phone number; otherwise <code>false</code>.
	*/
	public static function isPhone(phone:String):Boolean {
		return StringUtil.getNumbersFromString(phone).length >= 10;
	}
	
	/**
		Determines if numbers in string are a valid US zip code length.
		
		@param zip: String to verify the containing numbers are either 5 or 9 numbers in length.
		@return Returns <code>true</code> if zip code; otherwise <code>false</code>.
	*/
	public static function isZip(zip:String):Boolean {
		var l:Number = StringUtil.getNumbersFromString(zip).length;
		return (l == 5 || l == 9);
	}
	
	/**
		Determines if string is a valid state abbreviation.
		
		@param state: String to verify as two letter state abbreviation (includes DC).
		@return Returns <code>true</code> if string is a state abbreviation; otherwise <code>false</code>.
	*/
	public static function isStateAbbreviation(state:String):Boolean {
		var states:Array = new Array('ak', 'al', 'ar', 'az', 'ca', 'co', 'ct', 'dc', 'de', 'fl', 'ga', 'hi', 'ia', 'id', 'il', 'in', 'ks', 'ky', 'la', 'ma', 'md', 'me', 'mi', 'mn', 'mo', 'ms', 'mt', 'nb', 'nc', 'nd', 'nh', 'nj', 'nm', 'nv', 'ny', 'oh', 'ok', 'or', 'pa', 'ri', 'sc', 'sd', 'tn', 'tx', 'ut', 'va', 'vt', 'wa', 'wi', 'wv', 'wy');
		return ArrayUtil.contains(states, state.toLowerCase()) == 1;
	}
	
	/**
		Determines if string contains search string.
		
		@param source: String to search in.
		@param search: String to search for.
		@return Returns <code>true</code> if source string contains search string; otherwise <code>false</code>.
	*/
	public static function contains(source:String, search:String):Boolean {
		return StringUtil.contains(source, search) > 0;
	}
	
	/**
		Determines if string is blank or contains only tabs, linefeeds, carriage returns and spaces.
		
		@param source: String to check if empty.
		@return Returns <code>true</code> if string is empty; otherwise <code>false</code>.
	*/
	public static function isEmpty(source:String):Boolean {
		return ObjectUtil.isEmpty(StringUtil.removeWhitespace(source));
	}
	
	/**
		Determines if credit card is valid using the Luhn formula.
		
		@param cardNumber: The credit card number.
		@return Returns <code>true</code> if string is a valid credit card number; otherwise <code>false</code>.
	*/
	public static function isCreditCard(cardNumber:String):Boolean {
		if (cardNumber.length < 7 || cardNumber.length > 19 || Number(cardNumber) < 1000000)
			return false;
		
		var pre:Number;
		var sum:Number  = 0;
		var alt:Boolean = true;
		
		var i:Number = cardNumber.length;
		while (--i > -1) {
			if (alt)
				sum += Number(cardNumber.substr(i, 1));
			else {
				pre =  Number(cardNumber.substr(i, 1)) * 2;
				sum += (pre > 8) ? pre -= 9 : pre;
			}
			
			alt = !alt;
		}
		
		return sum % 10 == 0;
	}
	
	/**
		Determines US credit card provider by card number.
		
		@param cardNumber: The credit card number.
		@return Returns name of the provider; values can be <code>"visa"</code>, <code>"mastercard"</code>, <code>"discover"</code>, <code>"amex"</code>, <code>"diners"</code>, <code>"other"</code> or <code>"invalid"</code>.
	*/
	public static function getCreditCardProvider(cardNumber:String):String {
		if (!ValidationUtil.isCreditCard(cardNumber))
			return 'invalid';
		
		if (cardNumber.length == 13 ||
			cardNumber.length == 16 &&
			cardNumber.indexOf('4') == 0)
		{
			return 'visa';
		} 
		else if (cardNumber.indexOf('51') == 0 ||
				 cardNumber.indexOf('52') == 0 ||
				 cardNumber.indexOf('53') == 0 ||
				 cardNumber.indexOf('54') == 0 ||
				 cardNumber.indexOf('55') == 0 &&
				 cardNumber.length == 16)
		{
			return 'mastercard';
		}
		else if (cardNumber.length == 16 &&
			     cardNumber.indexOf('6011') == 0)
		{
			 return 'discover';
		} 
		else if (cardNumber.indexOf('34') == 0 ||
				 cardNumber.indexOf('37') == 0 &&
				 cardNumber.length == 15)
		{
			return 'amex';
		}
		else if (cardNumber.indexOf('300') == 0 ||
				 cardNumber.indexOf('301') == 0 ||
				 cardNumber.indexOf('302') == 0 ||
				 cardNumber.indexOf('303') == 0 ||
				 cardNumber.indexOf('304') == 0 ||
				 cardNumber.indexOf('305') == 0 ||
				 cardNumber.indexOf('36') == 0 ||
				 cardNumber.indexOf('38') == 0 &&
				 cardNumber.length == 14)
		{
			return 'diners';
		}
		else return 'other';
	}
	
	private function ValidationUtil() {} // Prevents instance creation
}