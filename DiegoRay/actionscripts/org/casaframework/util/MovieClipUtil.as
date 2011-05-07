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
	Provides utility functions for attaching and creating MovieClips.
	
	@author Aaron Clinger
	@auther Mike Creighton
	@version 04/09/07
	@since Flash Player 7
*/

class org.casaframework.util.MovieClipUtil {
	
	/**
		Makes it easier to change or assign classes to library MovieClips without having to change the item's linkage AS 2.0 class settings in the Flash IDE environment. An added benefit is that it allows multiple classes to use a single MovieClip in the library.
		
		@param className: The fully qualified name of a class you have defined in an external class file to extend the MovieClip instance.
		@param target: Location where the MovieClip should be attached.
		@param linkageId: The linkage name of the MovieClip in the library.
		@param instanceName: A unique instance name for the MovieClip.
		@param depth: <strong>[optional]</strong> The depth level where the MovieClip is placed; defaults to next highest open depth.
		@param initObject: <strong>[optional]</strong> An object that contains properties with which to populate the newly attached MovieClip.
		@return Returns a reference to the created MovieClip instance.
		@example
			<code>
				import com.example.MyClass;
				
				var myMc:MyClass = MyClass(MovieClipUtil.attachMovieRegisterClass(MyClass, this, "libraryIdentifier", "myMovieClip_mc", 100, {_x:100, _alpha:75});
			</code>
		@usageNote Be sure to always cast the returned MovieClip reference as the class type to get error notifcation and a valid reference.
	*/
	public static function attachMovieRegisterClass(className:Function, target:MovieClip, linkageId:String, instanceName:String, depth:Number, initObject:Object):MovieClip {
		Object.registerClass(linkageId, className);
		
		var mc:MovieClip = MovieClipUtil.attachMovie(target, linkageId, instanceName, depth, initObject);
		
		Object.registerClass(linkageId, null);
		
		return mc;
	}
	
	/**
		Creates an empty subclassed MovieClip extended by a specified class without requiring an empty MovieClip in the Flash IDE library with a linkage identifier and AS 2.0 class specification. 
		
		@param classPath: The fully qualified name of a class you have defined in an external class file to extend the MovieClip instance.
		@param target: Location where the MovieClip should be attached.
		@param instanceName: A unique instance name for the MovieClip.
		@param depth: <strong>[optional]</strong> The depth level where the MovieClip is placed; defaults to next highest open depth within the <code>target</code> MovieClip.
		@param initObject: <strong>[optional]</strong> An object that contains properties with which to populate the newly attached MovieClip.
		@return Returns a reference to the created MovieClip subclass instance.
		@example
			<code>
				import com.example.MyClass;
				
				var myMc:MyClass = MyClass(MovieClipUtil.createMovieRegisterClass("com.example.MyClass", this, "myMovieClip_mc", 100, {_x:100, _alpha:75});
			</code>
		@usageNote Be sure to always cast the returned MovieClip reference as the class type to get error notifcation and a valid reference.
	*/
	public static function createMovieRegisterClass(classPath:String, target:MovieClip, instanceName:String, depth:Number, initObject:Object):MovieClip {
		return MovieClipUtil.attachMovieRegisterClass(eval(classPath), target, '__Packages.' + classPath, instanceName, depth, initObject);
	}	
	
	/**
		Mimics the abilities of {@link #attachMovie} by providing the option to pass an object that contains properties with which to populate the created MovieClip.
		
		@param target: Location where the MovieClip should be attached.
		@param instanceName: A unique instance name for the MovieClip.
		@param depth: <strong>[optional]</strong> The depth level where the MovieClip is placed; defaults to next highest open depth.
		@param initObject: <strong>[optional]</strong> An object that contains properties with which to populate the newly attached MovieClip.
		@return Returns a reference to the created MovieClip instance.
		@example
			<code>
				var myMc:MovieClip = MovieClipUtil.createEmptyMovieClip(this, "myMovieClip_mc", 100, {_x:15, _alpha:70});
			</code>
	*/
	public static function createEmptyMovieClip(target:MovieClip, instanceName:String, depth:Number, initObject:Object):MovieClip {
		var mc:MovieClip = target.createEmptyMovieClip(instanceName, (depth == undefined) ? target.getNextHighestDepth() : depth);
		
		for (var prop:String in initObject)
			mc[prop] = initObject[prop];
		
		return mc;
	}
	
	/**
		Mirrors the abilities of the <code>MovieClip.attachMovie</code> but defaults <code>depth</code> to the next highest open depth.
		
		@param target: Location where the MovieClip should be attached.
		@param linkageId: The linkage name of the MovieClip in the library.
		@param instanceName: A unique instance name for the MovieClip.
		@param depth: <strong>[optional]</strong> The depth level where the MovieClip is placed; defaults to next highest open depth.
		@param initObject: <strong>[optional]</strong> An object that contains properties with which to populate the newly attached MovieClip.
		@return Returns a reference to the created MovieClip instance.
		@example
			<code>
				var myMc:MovieClip = MovieClipUtil.attachMovie(this, "libraryIdentifier", "myMovieClip_mc", 100, {_x:100, _alpha:75});
			</code>
	*/
	public static function attachMovie(target:MovieClip, linkageId:String, instanceName:String, depth:Number, initObject:Object):MovieClip {
		return target.attachMovie(linkageId, instanceName, (depth == undefined) ? target.getNextHighestDepth() : depth, initObject);
	}
	
	private function MovieClipUtil() {} // Prevents instance creation
}