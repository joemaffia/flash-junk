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

/**
This Point class copies the interface of the same class in Flash 8, so Point can be used in Flash 7 projects.

The Point object represents a location in a two-dimensional coordinate system, where x represents the horizonal axis and y represents the vertical axis.
The following code creates a point at (0,0):
<code>
var p:Point = new Point();
</code>
@todo <code>public static function polar (len:Number, angle:Number) : Point</code>
@todo <code>public static function interpolate (pt1:Point, pt2:Point, f:Number) : Point</code>
@deprecated Use this class for Flash 7 projects; projects that use Flash 8 or higher use the Adobe Point class.
*/

class org.asapframework.util.types.Point {

	private var mX:Number; /**< The horizontal coordinate of the point. */
	private var mY:Number; /**< The vertical coordinate of the point. */

	/**
	The x coordinate of the point.
	*/
	public function get x () : Number {
		return mX;
	}
	public function set x (inValue:Number) : Void {
		mX = inValue;
	}
	
	/**
	The y coordinate of the point.
	*/
	public function get y () : Number {
		return mY;
	}
	public function set y (inValue:Number) : Void {
		mY = inValue;
	}
	/**
	Creates a new Point with coordinates x and y.
	@param inX: (optional) the horizontal coordinate of the new point; default 0 is used.
	@param inY: (optional) the horizontal coordinate of the new point; default 0 is used.
	@use
	<code>
	var p1:Point = new Point();
	var p2:Point = new Point(100,200);
	</code>
	*/
	public function Point (inX:Number, inY:Number) {
		mX = inX; //(inX != undefined && !isNaN(inX)) ? inX : 0;
		mY = inY; //(inY != undefined && !isNaN(inY)) ? inY : 0;
	}
	
	/**
	Returns the distance between inPoint1 and inPoint2.
	@param inPoint1: the first point
	@param inPoint2: the second point
	@return The distance between the first and second point.
	*/
	public static function distance (inPoint1:Point, inPoint2:Point) : Number {
		var dx:Number = inPoint2.x - inPoint1.x;
		var dy:Number = inPoint2.y - inPoint1.y;
		return Math.sqrt( dx*dx+dy*dy );
	}
	
	/**
	Creates a copy of this Point object.
	@return The new Point object.
	*/
	public function clone () : Point {
		return new Point(mX, mY);
	}
	
	/**
	Offsets the current Point coordinates with given values.
	@param inX: the number to add to the x coordinate
	@param inY: the number to add to the y coordinate
	*/
	public function offset (inX:Number, inY:Number) : Void {
		mX += inX;
		mY += inY;
	}
	
	/**
	Determines whether two points are equal. Two points are equal if they have the same x and y values.
	@param inPoint: the Point to be compared
	@return True if the object is equal to this Point object; false if it is not equal.
	*/
	public function equals (inPoint:Point) : Boolean {
		return inPoint.x == mX && inPoint.y == mY;
	}
	
	/**
	Subtracts the coordinates of another point from the coordinates of this point to create a new point.
	@param inPoint: the Point to be subtracted
	@return The new Point.
	@use
	<code>
	var p1:Point = new Point(100,100);
	var p2:Point = new Point(0,10);
	var p3:Point = p1.subtract(p2);
	</code>
	*/
	public function subtract (inPoint:Point) : Point {
		return new Point(mX - inPoint.x, mY - inPoint.y);
	}
	
	/**
	Adds the coordinates of another point to the coordinates of this point to create a new point.
	@param inPoint: the point to be added
	@return A new Point with the coordinates of inAddPoint added to the current Point.
	@implementationNote This method is called <code>add</code> in Flash 8. Unfortunately <code>add</code> is a reserved name in Flash 7, and cannot be used.
	@use
	<code>
	var p1:Point = new Point(100,100);
	var p2:Point = new Point(0,10);
	var p3:Point = p1.addPoint(p2);
	</code>
	Or write shorthand:
	<code>
	var p1:Point = new Point(100,100);
	var p2:Point = p1.addPoint(new Point(0,10));
	</code>
	*/
	public function addPoint (inPoint:Point) : Point {
		return new Point(mX + inPoint.x, mY + inPoint.y);
	}
	
	/**
	Scales the line segment between (0,0) and the current point to a set length.
	@param inLength: the scaling value; or example, if the current point is (0,5), and you normalize it to 1, the point returned is at (0,1)
	*/
	public function normalize (inLength:Number) : Void {
		var greatest:Number = (Math.abs(mX) > Math.abs(mY)) ? Math.abs(mX) : Math.abs(y);
		var factor:Number = (greatest != 0) ? (inLength / greatest) : 0;
		mX *= factor;
		mY *= factor;
	}
	
	/**
	Returns a string that contains the values of the x and y coordinates. The string has the form (x=x, y=y), so a Point at 23,17 would return "(x=23, y=17)".
	*/
	public function toString  () : String {
		return "(x=" + mX + ", y=" + mY + ")";
	}
}
