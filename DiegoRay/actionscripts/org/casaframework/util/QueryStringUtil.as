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

import org.casaframework.util.TypeUtil;

/**
	Utilities for converting field-value query strings to and from Objects.
	
	@author Aaron Clinger
	@version 05/30/07
*/

class org.casaframework.util.QueryStringUtil {
	
	/**
		Converts an Object's first level variables into field-value pairs.
		
		@param data: Object that contains variables to convert to field-value pairs.
		@param separator: <strong>[optional]</strong> The string that separates the field-value pairs; defaults to <code>"&"</code>.
		@return Returns a query string.
		@usage
			<code>
				var dataToSend:Object = new Object();
				dataToSend.id = 13;
				dataToSend.name = 'Aaron';
				
				trace(QueryStringUtil.encode(dataToSend));
			</code>
	*/
	public static function encode(data:Object, separator:String):String {
		if (separator == undefined)
			separator = '&';
		
		var query:String = '';
		var val:Object;
		
		for (var i:String in data) {
			val = data[i];
			
			switch (TypeUtil.getTypeOf(val)) {
				case 'boolean' :
					query += i + '=' + (val ? 'true' : 'false') + '&';
					break;
				case 'string' :
					query += i + '=' + val + '&';
					break;
				case 'number' :
					query += i + '=' + val.toString() + '&';
					break;
			}
		}
		
		return query.slice(0, -1);
	}
	
	/**
		Converts a query string of field-value pairs to an Object.
		
		@param query: String composed of a series of field-value pairs.
		@param separator: <strong>[optional]</strong> The string that separates the field-value pairs; defaults to <code>"&"</code>.
		@return Returns Object composed of defined variables Strings.
		@usageNote Method automatically <code>unescape</code>'s values.
		@usage
			<code>
				var fieldValues:Object = QueryStringUtil.decode("name=Aaron&id=13");
				trace(fieldValues.name);
				trace(fieldValues.id);
			</code>
	*/
	public static function decode(query:String, separator:String):Object {
		if (separator == undefined)
			separator = '&';
		
		var index:Number = query.indexOf('?');
		if (index != -1)
			query = query.slice(index + 1);
		
		var fieldValues:Object = new Object();
		var pairs:Array        = query.split(separator);
		var i:Number           = -1;
		var pair:String;
		
		while (++i < pairs.length) {
			pair  = pairs[i];
			index = pair.indexOf('=');
			
			if (index > -1)
				fieldValues[pair.slice(0, index)] = unescape(pair.slice(index + 1));
		}
		
		return fieldValues;
	}
	
	private function QueryStringUtil() {} // Prevents instance creation
}
