/*
Copyright 2005-2006 by the authors of asapframework, http://asapframework.org

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

// Adobe classes
//import flash.geom.*;
// Still support Flash 7:
import org.asapframework.util.types.*;

// ASAP classes
import org.asapframework.util.MovieClipUtils;


/**
ActionQueue methods to set various parameters/states of a movieclip.
Some of these methods use {@link MovieClipUtils}.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQSet {
	
	/**
	Sets the visible state of a movieclip.
	@param inMC : movieclip to set visible or invisible
	@param inFlag : true: visible; false: invisible
	@example
	This example hides a movieclip:
	<code>
	queue.addAction( AQSet.setVisible, my_mc, false );
	</code>
	*/
	public static function setVisible (inMC:MovieClip,
									   inFlag:Boolean) : Void {
		inMC._visible = inFlag;
	}

	/**
	Sets the alpha value of a movieclip.
	@param inMC : movieclip to set the alpha value of
	@param inAlpha : new alpha value
	@example
	This example sets the alpha of a movieclip to 50:
	<code>
	queue.addAction( AQSet.setAlpha, my_mc, 50 );
	</code>
	*/
	public static function setAlpha (inMC:MovieClip,
							  		 inAlpha:Number) : Void {
		inMC._alpha = inAlpha;
	}
	
	/**
	Sets the scale of a movieclip.
	@param inMC : movieclip to set the scale of
	@param inXScale : new xscale value
	@param inYScale : new yscale value
	@example
	This example sets only the xscale of a movieclip:
	<code>
	queue.addAction( AQSet.setScale, my_mc, 200, null );
	</code>
	*/
	public static function setScale (inMC:MovieClip,
							  		 inXScale:Number,
							  		 inYScale:Number) : Void {
		if (inXScale != undefined) {
			inMC._xscale = inXScale;
		}
		if (inYScale != undefined) {
			inMC._yscale = inYScale;
		}
	}
	
	/**
	Sets a movieclip to a location.
	@param inMC : movieclip to move
	@param inX : new x location
	@param inY : new y location
	@param inOtherMC : (optional) movieclip inMC is set to the location of movieclip 'inOtherMC' with values of x and y as offset
	@example
	This example sets the position of a movieclip:
	<code>
	queue.addAction( AQSet.setLoc, my_mc, 100, 150 );
	</code>
	This example sets the position of the movieclip to another movieclip with an offset of (10, 10):
	<code>
	queue.addAction( AQSet.setLoc, my_mc, 10, 10, my_other_mc );
	</code>
	*/
	public static function setLoc (inMC:MovieClip,
								   inX:Number,
								   inY:Number,
								   inOtherMC:MovieClip) : Void {
		var x:Number = (inX != undefined) ? inX : inMC._x;
		var y:Number = (inY != undefined) ? inY : inMC._y;
		if (inOtherMC != undefined) {
			x = (inX != undefined) ? inOtherMC._x + inX : inOtherMC._x;
			y = (inY != undefined) ? inOtherMC._y + inY : inOtherMC._y;
		}
		inMC._x = x;
		inMC._y = y;
	}
	
	/**
	Sets a movieclip to the mouse location at moment of call.
	@param inMC : movieclip to set to the mouse location
	@example
	This example sets the position of a movieclip to the mouse coordinates:
	<code>
	queue.addAction( AQSet.setToMouse, my_mc );
	</code>
	*/
	public static function setToMouse (inMC:MovieClip) : Void {
		inMC._x = inMC._parent._xmouse;
		inMC._y = inMC._parent._ymouse;
	}
	
	/**
	Sets a movieclip to the center of the stage.
	@param inMC : movieclip to set
	@param inOffset : (optional) the number of pixels to offset the clip from the center, defined as a Point object
	@example
	This example centers the movieclip on the stage, with an offset of (50, 0):
	<code>
	queue.addAction( AQSet.centerOnStage, my_mc, new Point(50,0) );
	</code>
	@implementationNote Calls {@link MovieClipUtils#centerOnStage}.
	*/
	public static function centerOnStage (inMC:MovieClip,
								   		  inOffset:Point) : Void {
		MovieClipUtils.centerOnStage(inMC, inOffset);
	}

	/**
	Sets enabled state of movieclip.
	@param inMC : movieclip to set enabled or disabled
	@param inFlag : enabled true or false
	@example
	This example disables a movieclip:
	<code>
	queue.addAction( AQSet.setEnabled, my_mc, false );
	</code>
	*/	
	public static function setEnabled (inMC:MovieClip,
							  		   inFlag:Boolean) : Void {
		inMC.enabled = inFlag;
	}
	
	/**
	Inactivates and activates the contents of a movieclip (including buttons and button clips).
	@param inMC : movieclip whose contents should be inactivated or activated
	@param inFlag : false: make inactive; true: make active
	@example
	Disable all menu buttons by calling:
	<code>
	queue.addAction( AQSet.setActive, menu_mc, false );
	</code>
	To activate the menu buttons again, use:
	<code>queue.addAction( AQSet.setActive, my_mc, true );
	</code>
	@implementationNote Calls {@link MovieClipUtils#setActive}.
	*/
	public static function setActive (inMC:MovieClip,
							   		  inFlag:Boolean) : Void {
		MovieClipUtils.setActive( inMC, inFlag );
	}
	
	/**
	@param inMC : movieclip to unload
	@example
	This example unloads the movieclip:
	<code>
	queue.addAction( AQSet.unload, my_mc );
	</code>
	@implementationNote Calls MovieClip.unloadMovie().
	*/
	public static function unload (inMC:MovieClip) : Void {
		inMC.unloadMovie();
	}
	
	/**
	@param inMC : movieclip to remove
	@example
	This example removes the movieclip:
	<code>
	queue.addAction( AQSet.remove, my_mc );
	</code>
	@implementationNote Calls removeMovieClip().
	*/
	public static function remove (inMC:MovieClip) : Void {
		inMC.removeMovieClip();
	}
	
	/**
	@deprecated Use {@link AQColor#setColor}.
	*/
	public static function setColor (inMC:MovieClip,
									 inColorNumberValue:Number) : Void {
		var col:Color = new Color(inMC);
		col.setRGB(inColorNumberValue);
	}
	
	/**
	Sets a mask to a movieclip.
	@param inMC : movieclip to set mask to
	@param inMaskMC : mask clip
	@example
	This example sets mask clip my_mask_mc to my_mc:
	<code>
	queue.addAction( AQSet.setMask, my_mc, my_mask_mc );
	</code>
	*/
	public static function setMask (inMC:MovieClip,
							   		inMaskMC:MovieClip) : Void {
		inMC.setMask(inMaskMC);
	}
	
}