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
	@author Toby Boudreaux
	@author David Nelson
	@author Aaron Clinger
	@version 02/06/07
*/

interface org.casaframework.core.CoreInterface {
	
	/**
		Returns class description name.
		
		@return Returns class path.
	*/
	public function toString():String;
	
	
	/**
		Removes any internal variables, intervals, enter frames, internal MovieClips and event observers to allow the object to be garbage collected.
		
		<strong>Always call <code>destroy()</code> before deleting last object pointer.</strong>
	*/
	public function destroy():Void;
}