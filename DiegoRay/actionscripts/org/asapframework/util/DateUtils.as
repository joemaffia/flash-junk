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

import org.asapframework.util.debug.Log;

/**
*	A collection of utility methods for the Date class.
*	@example DateUtils has static methods. To use them, import the class and write for instance: <code>var d:Date = DateUtils.stringToDate( "23-3-2004" );</code>
*/

class org.asapframework.util.DateUtils {

	private static var sMonthsLoCase:Object = {
			eng : ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
			fre : ["janvier", "f\u00EBvrier", "marche", "avril", "mai", "juin", "juillet", "ao\u00FBt", "septembre", "octobre", "novembre", "d\u00EBcembre"],
			ger : ["Januar", "Februar", "M\u00E4rz", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
			ita : ["gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto", "settembre", "ottobre", "novembre", "dicembre"],
			spa : ["enero", "febrero", "marcha", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"],
			dut : ["januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober", "november", "december"]
	};
	private static var sMonthsUpCase:Object = {
			eng : ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"],
			fre : ["JANVIER", "F\u00C9VRIER", "MARCHE", "AVRIL", "MAI", "JUIN", "JUILLET", "AO\u00DBT", "SEPTEMBRE", "OCTOBRE", "NOVEMBRE", "D\u00C9CEMBRE"],
			ger : ["JANUAR", "FEBRUAR", "M\u00C4RZ", "APRIL", "MAI", "JUNI", "JULI", "AUGUST", "SEPTEMBER", "OKTOBER", "NOVEMBER", "DEZEMBER"],
			ita : ["GENNAIO", "FEBBRAIO", "MARZO", "APRILE", "MAGGIO", "GIUGNO", "LUGLIO", "AGOSTO", "SETTEMBRE", "OTTOBRE", "NOVEMBRE", "DICEMBRE"],
			spa : ["ENERO", "FEBRERO", "MARCHA", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"],
			dut : ["JANUARI", "FEBRUARI", "MAART", "APRIL", "MEI", "JUNI", "JULI", "AUGUSTUS", "SEPTEMBER", "OKTOBER", "NOVEMBER", "DECEMBER"]
	};
	private static var sShortMonths:Object = {
			eng : ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
			dut : ["jan", "feb", "mar", "apr", "mei", "jun", "jul", "aug", "sep", "okt", "nov", "dec"]
	};

	/**
	*	Creates a Date object from a string.
	*	@param string A string with the format "day-month-year".
	*	@param delimiter Optional, the delimiter used to seperate the day, month and year parts. When left empty, the default is "-".
	*	@return A Date object
	*	@use <code>var d:Date = DateUtils.stringToDate( "23-3-2004" );</code> <br/>This returns (when traced): <code>Tue Mar 23 18:09:14 GMT+0100 2004</code>.<br/>Hours, minutes and seconds are set to 0.
	*	@todo International date format (order of date parts)
	*	@todo UTC date format
	*/
	static public function stringToDate (inString:String,inDelimiter:String) : Date
	{
		var delim:String = (inDelimiter == undefined)? "-" : inDelimiter;
		var endSubscriptionDateParts:Array = inString.split(delim);
		var day:Number = Number(endSubscriptionDateParts[0]);
		var month:Number = Number(endSubscriptionDateParts[1]) - 1;
		var year:Number = Number(endSubscriptionDateParts[2]);

		var hours:Number = 0;
		var minutes:Number = 0;
		var seconds:Number = 0;
		var ms:Number = 0;

		return new Date( year, month, day, hours, minutes, seconds, ms );
	}

	/**
	Returns the number of days elapsed since the current moment.
	@param date Another moment in the past or future.
	@return A float value of the difference in days.
	@use
	<code>
	var daysPassed:Number = DateUtils.getDaysSinceNow( myOtherDateObj );
	</code>
	To get the positive number of days up till a moment in the future ("getDaysFromNow"), use:
	<code>
	var myFutureDate:Date = DateUtils.stringToDate( "31-12-2040" );
	var daysLeft:Number = -DateUtils.getDaysSinceNow( myFutureDate );
	</code>
	*/
	static public function getDaysSinceNow (inDate:Date) : Number
	{
		var DAY:Number = 86400000;
		var now:Date = new Date();
		var elapsed:Number = now.getTime() - inDate.getTime();
		var daysCount:Number = elapsed / DAY;
		return daysCount;
	}

	/**
	*	Returns the full name of the month for a given month number and language.
	*	@param month Number indicating which month to get (zero based).
	*	@param language The language in which the month name should be returned. Supported: "eng", "ger", "fre", "spa", "ita" and "dut"; "eng" is default when no language is given.
	*	@param caps Optional, set to 'true' to receive month name in capitals.
	*	@return The name of the month, for example "March" for month 2, or null if none was found
	*/
	static public function getMonthAsString (inMonth:Number, inLang:String, inCaps:Boolean ) : String
	{
		if (inMonth < 0 || inMonth > 11) {
			Log.error("getMonthAsString -- invalid month number '" + inMonth + "'", "DateUtils");
			return null;
		}
		var upcase:Boolean = (inCaps == undefined)? false : inCaps;
		var lang:String = (inLang == undefined) ? "eng" : inLang;
		var monthName:String = (upcase)? sMonthsUpCase[lang][inMonth] : sMonthsLoCase[lang][inMonth];
		if (monthName == undefined) {
			Log.error("getMonthAsString -- language '" + inLang + "' is not supported", "DateUtils");
			return null;
		} else {
			return monthName;
		}
	}

	/**
	*	Returns the short name of the month for a given month number and language.
	*	@param month Number indicating which month to get (zero based).
	*	@param language The language in which the month name should be returned. Supported: "eng" and "dut"; "eng" is default when no language is given.
	*	@return The short name of the month, for example "Mar" for month 2, or null if none was found
	*/
	static public function getShortMonthAsString (inMonth:Number, inLang:String) : String
	{
		if (inMonth < 0 || inMonth > 11) {
			Log.error("getShortMonthAsString -- invalid month number '" + inMonth + "'", "DateUtils");
			return null;
		}
		var lang:String = (inLang == undefined) ? "eng" : inLang;
		var monthName:String = sShortMonths[lang][inMonth];
		if (monthName == undefined) {
			Log.error("getShortMonthAsString -- language '" + inLang + "' is not supported", "DateUtils");
		} else {
			return monthName;
		}
	}
	
	/**
	Compares two Dates.
	@param a : first Date to compare
	@param b : second Date to compare
	@return True is both Dates are equal; false if they are not.
	*/
	static public function isEqual (a:Date, b:Date) : Boolean {
		if (a.valueOf() == b.valueOf()) {
			return true;
		}
		return false;
	}
}