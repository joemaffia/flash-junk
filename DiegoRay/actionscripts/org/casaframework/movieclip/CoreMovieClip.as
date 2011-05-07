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

import org.casaframework.core.CoreInterface;
import org.casaframework.util.MovieClipUtil;

/**
	A core MovieClip to inherent from which extends Flash's built-in MovieClip class. All MovieClip classes should extend from here.
	
	@author Aaron Clinger
	@auther Mike Creighton
	@version 05/29/07
*/

class org.casaframework.movieclip.CoreMovieClip extends MovieClip implements CoreInterface {
	private var $instanceDescription:String;
	
	
	/**
		Creates an empty instance of the CoreMovieClip class. Use this instead of a traditional <code>new</code> constructor statement due to limitations of ActionScript 2.0.
		
		@param target: Location where the MovieClip should be attached.
		@param instanceName: A unique instance name for the MovieClip.
		@param depth: <strong>[optional]</strong> The depth level where the MovieClip is placed; defaults to next highest open depth.
		@param initObject: <strong>[optional]</strong> An object that contains properties with which to populate the newly attached MovieClip.
		@return Returns a reference to the created instance.
		@example <code>var myCore_mc:CoreMovieClip = CoreMovieClip.create(this, "example_mc");</code>
		@usageNote If you want to extend a non empty MovieClip you can either define the ActionScript 2.0 class in the Flash IDE library or use {@link MovieClipUtil#attachMovieRegisterClass}.
		@since Flash Player 7
	*/
	public static function create(target:MovieClip, instanceName:String, depth:Number, initObject:Object):CoreMovieClip {
		return CoreMovieClip(MovieClipUtil.createMovieRegisterClass('org.casaframework.movieclip.CoreMovieClip', target, instanceName, depth, initObject));
	}
	
	
	private function CoreMovieClip() {
		this.$setClassDescription('org.casaframework.movieclip.CoreMovieClip');
	}
	
	public function toString():String {
		return '[' + this.$instanceDescription + ']';
	}
	
	/**
		Removes the MovieClip after automatically calling {@link #destroy}.
		
		@usageNote <code>removeMovieClip</code> and {@link #destroy} work identically; you can call either method to destory and remove the MovieClip.
	*/
	public function removeMovieClip():Void {
		this.destroy();
	}
	
	public function destroy():Void {
		delete this.$instanceDescription;
		
		super.removeMovieClip();
	}
	
	private function $setClassDescription(description:String):Void {
		this.$instanceDescription = description;
	}
}
