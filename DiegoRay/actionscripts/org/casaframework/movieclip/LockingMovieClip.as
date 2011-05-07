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

import org.casaframework.state.LockableInterface;
import org.casaframework.movieclip.StatedMovieClip;
import org.casaframework.util.MovieClipUtil;

/**
	Extends {@link StatedMovieClip} and creates a locking interface for MovieClips.
	
	This is different then using the <code>enabled</code> property because it completly removes all MovieClip event handlers and properties specified; does not only disable button events. 
	
	@author Toby Boudreaux
	@author Aaron Clinger
	@version 05/13/07
	@example
		<code>
			import org.casaframework.util.MovieClipUtil;
			
			MovieClipUtil.attachMovieRegisterClass(org.casaframework.movieclip.LockingMovieClip, this, "linkageMovieClip", "locking_mc");
			
			this.locking_mc.onRelease = function():Void {
				trace("I am unlocked.");
			}
			
			this.locking_mc.lock();
		</code>
		
		or is you only want to lock certain event handlers:
		<code>
			import org.casaframework.util.MovieClipUtil;
			
			MovieClipUtil.attachMovieRegisterClass(org.casaframework.movieclip.LockingMovieClip, this, "linkageMovieClip", "locking_mc");
			
			this.locking_mc.onRelease = function():Void {
				trace("I am unlocked.");
			}
			
			this.locking_mc.onRollOver = function():Void {
				this.gotoAndStop("rollOver");
			}
			
			this.locking_mc.onRollOut = this.locking_mc.onReleaseOutside = function():Void {
				this.gotoAndStop("rollOut");
			}
			
			this.locking_mc.lock(new Array("onRelease"));
		</code>
*/

class org.casaframework.movieclip.LockingMovieClip extends StatedMovieClip implements LockableInterface {
	private var $locked:Boolean;
	
	
	/**
		Creates an empty instance of the LockingMovieClip class. Use this instead of a traditional <code>new</code> constructor statement due to limitations of ActionScript 2.0.
		
		@param target: Location where the MovieClip should be attached.
		@param instanceName: A unique instance name for the MovieClip.
		@param depth: <strong>[optional]</strong> The depth level where the MovieClip is placed; defaults to next highest open depth.
		@param initObject: <strong>[optional]</strong> An object that contains properties with which to populate the newly attached MovieClip.
		@return Returns a reference to the created instance.
		@example <code>var myLocking_mc:LockingMovieClip = LockingMovieClip.create(this, "example_mc");</code>
		@usageNote If you want to extend a non empty MovieClip you can either define the ActionScript 2.0 class in the Flash IDE library or use {@link MovieClipUtil#attachMovieRegisterClass}.
		@since Flash Player 7
	*/
	public static function create(target:MovieClip, instanceName:String, depth:Number, initObject:Object):LockingMovieClip {
		return LockingMovieClip(MovieClipUtil.createMovieRegisterClass('org.casaframework.movieclip.LockingMovieClip', target, instanceName, depth, initObject));
	}
	
	
	private function LockingMovieClip() {
		super();
		
		this.$locked = false;
		
		this.$setClassDescription('org.casaframework.movieclip.LockingMovieClip');
	}
	
	public function lock(inclusionList:Array):Void {
		if (this.$locked)
			return;
		
		this.enabled = false;
		this.$locked = true;
		
		this.createState('unlocked', inclusionList);
		this.switchState('blank', inclusionList);
	}
	
	public function unlock():Void {
		if (!this.$locked)
			return;
		
		this.enabled = true;
		this.$locked = false;
		
		this.switchState('unlocked');
	}
	
	public function toggle():Void {
		if (this.$locked)
			this.unlock();
		else
			this.lock();
	}
	
	public function isLocked():Boolean {
		return this.$locked;
	}
	
	public function destroy():Void {
		delete this.$locked;
		super.destroy();
	}
}