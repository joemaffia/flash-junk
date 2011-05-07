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

import org.casaframework.textfield.CoreTextField;

/**
	Utilities for determining an object's type.
	
	@author Aaron Clinger
	@author David Nelson
	@version 05/12/07
*/

class org.casaframework.util.TypeUtil {
	
	/**
		Evaluates an object and returns a string describing its type. This method is more versed than the <code>typeof</code> equivalent.
		
		@param obj: Object to evaluate.
		@return Returns a string describing the objects type.
		@usageNote {@link CoreTextField} and {@link CoreMovieClip} will return types of <code>"textfield"</code> and <code>"movieclip"</code> respectively.
	*/
	public static function getTypeOf(obj:Object):String {
		if (obj instanceof CoreTextField)
			return 'textfield';
		var t:String = typeof obj;
		if (t != 'object')
			return t;
		if (obj instanceof Array)
			return 'array';
		if (obj instanceof Button)
			return 'button';
		if (obj instanceof Color)
			return 'color';
		if (obj instanceof ContextMenu)
			return 'contextmenu';
		if (obj instanceof ContextMenuItem)
			return 'contextmenuitem';
		if (obj instanceof Date)
			return 'date';
		if (obj instanceof Error)
			return 'error';
		if (obj instanceof LoadVars)
			return 'loadvars';
		if (obj instanceof LocalConnection)
			return 'localconnection';
		if (obj instanceof MovieClipLoader)
			return 'moviecliploader';
		if (obj instanceof NetConnection)
			return 'netconnection';
		if (obj instanceof NetStream)
			return 'netstream';
		if (obj instanceof PrintJob)
			return 'printjob';
		if (obj instanceof Sound)
			return 'sound';
		if (obj instanceof TextField)
			return 'textfield';
		if (obj instanceof TextFormat)
			return 'textformat';
		if (obj instanceof TextSnapshot)
			return 'textsnapshot';
		if (obj instanceof Video)
			return 'video';
		if (obj instanceof XML)
			return 'xml';
		if (obj instanceof XMLNode)
			return 'xmlnode';
		if (obj instanceof XMLSocket)
			return 'xmlsocket';
		if (obj instanceof XML)
			return 'xml';
		
		return 'object';
	}
	
	/**
		Evaluates if an object is of a certain type. Can detect any types that {@link #getTypeOf} can describe.
		
		@param obj: Object to evaluate.
		@param type: String describe the objects type.
		@return Returns <code>true</code> if object matches type; otherwise <code>false</code>.
	*/
	public static function isTypeOf(obj:Object, type:String):Boolean {
		return TypeUtil.getTypeOf(obj) == type.toLowerCase();
	}
	
	private function TypeUtil() {} // Prevents instance creation
}