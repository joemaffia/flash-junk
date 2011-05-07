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
	@version 02/11/07
*/

class org.casaframework.util.FunctionUtil {
	
	/**
		Determines if object has minimum number of arguments.
		
		@param arguments: The argument object.
		@param min: The amount of arguments.
		@return Returns <code>true</code> if the objects length is equal to, or greater than the minimum amount of arguments; otherwise <code>false</code>.
		@usage
			<code>
				function myMethod(firstValue:String, secondValue:Number, optionalValue:Number):Void {
					if (!FunctionUtil.hasMinArguments(arguments, 2))
						return;
						
					trace("Has minimum arguments.");
				}
			</code>
	*/
	public static function hasMinArguments(args:Object, min:Number):Boolean {
		return args.length >= min;
	}
	
	private function FunctionUtil() {} // Prevents instance creation
}