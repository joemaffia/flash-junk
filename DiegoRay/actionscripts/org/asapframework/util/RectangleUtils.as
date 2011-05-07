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

/**
{@link Rectangle} util methods.
@author Arthur Clemens
*/

class org.asapframework.util.RectangleUtils {
	
	/**
	The center Point of the rectangle relative to its parent.
	@param inRectangle : the Rectangle to get the center point of
	@example
	<code>
	var rectangle:Rectangle = new Rectangle(1,2,4,8);
	// the rectangle has width:4 and height:8
	var center:Point = RectangleUtils.getCenter(rectangle);
	trace(center);
	// (x=3, y=6)
	</code>
	*/
	public static function getCenter (inRectangle:Rectangle) : Point {
		return new Point(inRectangle.x + inRectangle.width / 2.0, inRectangle.y + inRectangle.height / 2.0);
	}
	public static function setCenter (inRectangle:Rectangle, inPoint:Point) : Void {
		inRectangle.x = inPoint.x - inRectangle.width/2.0;
		inRectangle.y = inPoint.y - inRectangle.height/2.0;
	}
	
	/**
	Returns the rectangle of the MovieClip's unscaled contents as a new Rectangle. When a movieclip is scaled, this method returns the unscaled clip sizes.
	@see #boundsOfMovieClip
	@param inMc: the MovieClip to be measured
	@return A new Rectangle that has the size of the MovieClip and the position of its contents. Returns an empty Rectangle when an empty movieclip without any contents is passed.
	@implementationNote Calls {@link #boundsOfMovieClip} with (inMC, inMC)
	*/
	public static function rectOfMovieClip (inMC:MovieClip) : Rectangle {
		var rect:Rectangle = RectangleUtils.boundsOfMovieClip(inMC, inMC);
		if (rect.isEmpty()) {
			return new Rectangle();
		}
		return rect;
	}
	
	/**
	Returns the bounds (Stage coordinates) of a MovieClip as a new Rectangle - see MovieClip.getBounds. When a movieclip is scaled, this method returns the scaled clip sizes.
	@deprecated As of Flash 8: use <code>var trans:Transform = new Transform(my_mc).pixelBounds</code> to get the Rectangle bounds of a movieclip.
	@param inMc: the MovieClip to be measured
	@param inTargetSpace: the target path of the Timeline whose coordinate system you want to use as a reference point; if null, <code>_level0</code> is assumed
	@return A new Rectangle that has the size of the MovieClip and the position of the clip on the Stage.
	@implementationNote Calls MovieClip.getBounds.
	@usageNote A newly created movieclip without any contents has these bounds: (x=6710886.35, y=6710886.35, w=0, h=0)
	*/
	public static function boundsOfMovieClip (inMC:MovieClip, inTargetSpace:MovieClip) : Rectangle {
		var targetSpace = (inTargetSpace != undefined) ? inTargetSpace : _level0;
		var mcBounds = inMC.getBounds(targetSpace);
		var boundsRect:Rectangle = new Rectangle();
		boundsRect.left = mcBounds.xMin;
		boundsRect.right = mcBounds.xMax;
		boundsRect.top = mcBounds.yMin;
		boundsRect.bottom = mcBounds.yMax;
		return boundsRect;
	}
	
	/**
	Sets the size and origin of a movieclip to the bounds of a Rectangle.
	@param inMC: the movieclip to set the size and origin of
	@param inBounds: the Rectangle which size and origin to use
	*/
	public static function setToBounds (inMC:MovieClip, inBounds:Rectangle) : Void {
		inMC._width = inBounds.width;
		inMC._height = inBounds.height;
		inMC._x = inBounds.x;
		inMC._y = inBounds.y;
	}
	
	/**
	Returns the center point of the MovieClip's bounds.
	@param inMc: the MovieClip to be measured
	@param inTargetSpace: the target path of the Timeline whose coordinate system you want to use as a reference point; if null, <code>_level0</code> is assumed; pass the movieclip to get the center of its contents
	@return A new Point that has the position of the center of the MovieClip bounds. Returns Point(0,0) if the clip bounding rectangle has no width or heigth.
	@implementationNote Calls {@link #boundsOfMovieClip}.
	@usageNote A newly created movieclip without any contents has these bounds: (x=6710886.35, y=6710886.35, w=0, h=0); the center of this movieclip will be returned as Point (0,0)
	@usageNote To get the relative center point (the center of a movieclip's contents), write <code>centerPointOfMovieClip(my_mc, my_mc)</code>
	@example
	<code>
	var mc:MovieClip = _level0.createEmptyMovieClip("box", 1);
	var size:Number = 100;
	with (mc) {
		lineStyle( 0, 0x000000, 100 );
		moveTo( 0, 0 );
		lineTo( 0, size );
		lineTo( size, size );
		lineTo( size, 0 );
		lineTo( 0, 0 );
	}
	mc._x = 300;
	mc._y = 200;
	trace(RectangleUtils.centerPointOfMovieClip(mc); // ((x=350, y=250)
	trace(RectangleUtils.centerPointOfMovieClip(mc,mc); // (x=50, y=50)
	</code>
	*/
	public static function centerPointOfMovieClip (inMC:MovieClip, inTargetSpace:MovieClip) : Point {
		var rectangle:Rectangle = RectangleUtils.boundsOfMovieClip(inMC, inTargetSpace);
		if (rectangle.isEmpty()) {
			return new Point(0,0);
		}
		return RectangleUtils.getCenter(rectangle);
	}
		
	/**
	Utility fuction to set the center to another rectangle's center.
	@param r1: the rectangle to set the center to
	@param r2: the rectangle to get the center of
	@example
	<code>
	var rect1:Rectangle = new Rectangle(0,0,20,20);
	var rect2:Rectangle = new Rectangle(50,50,40,40);

	trace("rect1 = " + rect1); // (x=0, y=0, w=20, h=20)
	trace("rect2 = " + rect2); // (x=50, y=50, w=40, h=40)

	RectangleUtils.centerToRectangle(rect1, rect2);

	trace("rect1 = " + rect1); // (x=60, y=60, w=20, h=20)
	trace("rect2 = " + rect2); // (x=50, y=50, w=40, h=40)
	</code>
	*/
	public static function centerToRectangle (r1:Rectangle, r2:Rectangle) : Void {
		RectangleUtils.setCenter(r1, RectangleUtils.getCenter(r2));
	}
	
	/**
	Utility function to flatten the height of the Rectangle to a new given height. In contrast to {@link Rectangle#height} flattenHeight originates from the center.
	@param inRectangle: the Rectangle to flatten the height of
	@param inNewHeight: the new height of the Rectangle
	*/
	public static function flattenHeight (inRectangle:Rectangle, inNewHeight:Number) : Void {
		var oldHeight:Number = inRectangle.height;
		inRectangle.height = (inNewHeight != undefined) ? inNewHeight : 0;
		inRectangle.y += (oldHeight - inRectangle.height) / 2;
	}
	
	/**
	Utility function to flatten the width of the Rectangle to a new given width. In contrast to {@link Rectangle#width} flattenWidth originates from the center.
	@param inRectangle: the Rectangle to flatten the width of
	@param inNewWidth: the new width of the Rectangle
	*/
	public static function flattenWidth (inRectangle:Rectangle, inNewWidth:Number) : Void {
		var oldWidth:Number = inRectangle.width;
		inRectangle.width = (inNewWidth != undefined) ? inNewWidth : 0;
		inRectangle.x += (oldWidth - inRectangle.width) / 2;
	}
	
}