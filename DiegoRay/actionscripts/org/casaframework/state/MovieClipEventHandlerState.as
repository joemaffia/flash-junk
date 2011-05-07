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

import org.casaframework.state.ButtonEventHandlerState;

/**
	Defines all MovieClip event handlers.
	
	@author Toby Boudreaux
	@author Aaron Clinger
	@version 11/29/06
*/

class org.casaframework.state.MovieClipEventHandlerState extends ButtonEventHandlerState {
	
	public function MovieClipEventHandlerState() {
		super();
		
		this.setValueForKey('onData', undefined);
		this.setValueForKey('onEnterFrame', undefined);
		this.setValueForKey('onLoad', undefined);
		this.setValueForKey('onMouseDown', undefined);
		this.setValueForKey('onMouseMove', undefined);
		this.setValueForKey('onMouseUp', undefined);
		this.setValueForKey('onUnload', undefined);
		
		this.$setClassDescription('org.casaframework.state.MovieClipEventHandlerState');
	}
}