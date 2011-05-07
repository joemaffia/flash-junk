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

import org.asapframework.util.types.Point;

/**
This Rectangle class copies the interface of the Rectangle class distributed with Flash 8, to make Rectangle usable for Flash 7 projects.

The Rectangle class is used to create and modify Rectangle objects. A Rectangle object is an area defined by its position, as indicated by its top-left corner point (x, y), and by its width and its height. Be careful when you design these areas--if a rectangle is described as having its upper-left corner at 0,0 and has a height of 10 and a width of 20, the lower-right corner is at 9,19, because the count of width and height began at 0,0.

The x, y, width, and height properties of the Rectangle class are independent of each other; changing the value of one property has no effect on the others. However, the right and bottom properties are integrally related to those four--if you change right, you are changing width; if you change bottom, you are changing height, and so on. And you must have the left or x property established before you set width or right property.
@author Arthur Clemens
@deprecated Use this class for Flash 7 projects; projects that use Flash 8 or higher use the Adobe Rectangle class.
*/

class org.asapframework.util.types.Rectangle {

	private var mX:Number, mY:Number, mWidth:Number, mHeight:Number;
	
	/**
	The sum of the y and height properties.
	*/
	public function get bottom () : Number {
		return mY + mHeight;
	}
	public function set bottom (inValue:Number) : Void {
		mHeight = inValue - mY;
	}
	
	/**
	The location of the Rectangle object's bottom-right corner, determined by the values of the x and y properties.
	*/
	public function get bottomRight () : Point {
		return new Point(mX + mWidth, mY + mHeight);
	}
	public function set bottomRight (inPoint:Point) : Void {
		mWidth = inPoint.x - mX;
		mHeight = inPoint.y - mY;
	}
	
	/**
	The height of the rectangle in pixels.
	*/
	public function get height () : Number {
		return mHeight;
	}
	public function set height (inValue:Number) : Void {
		mHeight = inValue;
	}
	
	/**
	The x coordinate of the top-left corner of the rectangle.
	*/
	public function get left () : Number {
		return mX;
	}
	public function set left (inValue:Number) : Void {
		mX = inValue;
	}

	/**
	The sum of the x and width properties.
	*/
	public function get right () : Number {
		return mX + mWidth;
	}
	public function set right (inValue:Number) : Void {
		mWidth = inValue - mX;
	}

	/**
	The size of the Rectangle object, expressed as a Point object with the values of the width and height properties.
	*/
	public function get size () : Point {
		return new Point(mWidth, mHeight);
	}
 	public function set size (inPoint:Point) : Void {
 		mWidth = inPoint.x;
 		mHeight = inPoint.y;
 	}

	/**
	The y coordinate of the top-left corner of the rectangle.
	*/
	public function get top () : Number {
		return mY;
	}
	public function set top (inValue:Number) : Void {
		mY = inValue;
	}

	/**
	The location of the Rectangle object's top-left corner determined by the x and y values of the point.
	*/
	public function get topLeft () : Point {
		return new Point(mX, mY);
	}
 	public function set topLeft (inPoint:Point) : Void {
 		mX = inPoint.x;
 		mY = inPoint.y;
 	}
 	
 	/**
	The width of the rectangle in pixels.
	*/
	public function get width () : Number {
		return mWidth;
	}
	public function set width (inValue:Number) : Void {
		mWidth = inValue;
	}

	/**
	The x coordinate of the top-left corner of the rectangle.
	*/
	public function get x () : Number {
		return mX;
	}
	public function set x (inValue:Number) : Void {
		mX = inValue;
	}
	
	/**
	The y coordinate of the top-left corner of the rectangle.
	*/
	public function get y () : Number {
		return mY;
	}
	public function set y (inValue:Number) : Void {
		mY = inValue;
	}
		
	/**
	Creates a new Rectangle object whose top-left corner is specified by the inX and inY parameters. If you call this constructor function without parameters, a rectangle with x, y, width, and height properties set to 0 is created.
	@param inX: the x coordinate of the top-left corner of the rectangle
	@param inY: the y coordinate of the top-left corner of the rectangle
	@param inWidth: the width of the rectangle in pixels
	@param inHeight: the height of the rectangle in pixels
	*/
	public function Rectangle (inX:Number, inY:Number, inWidth:Number, inHeight:Number) {
		mX = (inX != undefined && !isNaN(inX)) ? inX : 0;
		mY = (inY != undefined && !isNaN(inY)) ? inY : 0;
		mWidth = (inWidth != undefined && !isNaN(inWidth)) ? inWidth : 0;
		mHeight = (inHeight != undefined && !isNaN(inHeight)) ? inHeight : 0;
	}
	
	/**
	Returns a new Rectangle object with the same values for the x, y, width, and height properties as the original Rectangle object.
	@return A new Rectangle object with the same values for the x, y, width, and height properties as the original Rectangle object.
	*/
	public function clone () : Rectangle {
		return new Rectangle(mX, mY, mWidth, mHeight);
	}
	
	/**
	Determines whether the specified point is contained within the rectangular region defined by this Rectangle object.
	@param inX: the x-value (horizontal position) of the point
	@param inY: the y-value (vertical position) of the point
	@example
	<code>
	var rectangle:Rectangle = new Rectangle(10, 10, 50, 50);
	trace(rectangle.contains(59, 59)); // true
	trace(rectangle.contains(10, 10)); // true
	trace(rectangle.contains(60, 60)); // false
	</code>
	*/
	public function contains (inX:Number, inY:Number) : Boolean {
		return (inX >= mX) && (inX < (mX + mWidth)) && (inY >= mY) && (inY < (mY + mHeight));
	}
	
	/**
	Determines whether the specified point is contained within the rectangular region defined by this Rectangle object. This method is similar to the Rectangle.contains() method, except that it takes a Point object as a parameter.
	@param inPoint: the point, as represented by its x,y values
	@return If the specified point is contained within this Rectangle object, returns true; otherwise false.
	@example
	<code>
	var rectangle:Rectangle = new Rectangle(10, 10, 50, 50);
	trace(rectangle.containsPoint(new Point(10, 10))); // true
	trace(rectangle.containsPoint(new Point(59, 59))); // true
	trace(rectangle.containsPoint(new Point(60, 60))); // false
	</code>
	*/
	public function containsPoint (inPoint:Point) : Boolean {
		return (inPoint.x >= mX) && (inPoint.x < (mX + mWidth)) && (inPoint.y >= mY) && (inPoint.y < (mY + mHeight));
	}
	
	/**
	Determines whether the Rectangle object specified by the rect parameter is contained within this Rectangle object. A Rectangle object is said to contain another if the second Rectangle object falls entirely within the boundaries of the first.
	@param inRect: the Rectangle object being checked
	@return If the Rectangle object that you specify is contained by this Rectangle object, returns true; otherwise false.
	@example
	<code>
	var rectA:Rectangle = new Rectangle(10, 10, 50, 50);
	var rectB:Rectangle = new Rectangle(10, 10, 50, 50);
	var rectC:Rectangle = new Rectangle(10, 10, 51, 51);
	var rectD:Rectangle = new Rectangle(15, 15, 45, 45);
	
	trace(rectA.containsRectangle(rectB)); // true
	trace(rectA.containsRectangle(rectC)); // false
	trace(rectA.containsRectangle(rectD)); // true
	</code>
	*/
	public function containsRectangle (inRect:Rectangle) : Boolean {
		return (inRect.x >= mX) && (inRect.right <= (mX + mWidth)) && (inRect.y >= mY) && (inRect.bottom <= (mY + mHeight));
	}
	
	/**
	Determines whether inRectangle is equal to this Rectangle object. This method compares the x, y, width, and height properties of an object against the same properties of this Rectangle object.
	@param inRectangle: the rectangle to compare to this Rectangle object
	@return  If the object has exactly the same values for the x, y, width, and height properties as this Rectangle object, returns true; otherwise false.
	*/
	public function equals (inRectangle:Rectangle) : Boolean {
		return inRectangle.x == mX && inRectangle.y == mY && inRectangle.width == mWidth && inRectangle.height == mHeight;
	}
	
	/**
	Increases the size of the Rectangle object by the specified amounts. The center point of the Rectangle object stays the same, and its size increases to the left and right by the inX value, and to the top and the bottom by the inY value.
	@param inX: The value to be added to the left and the right of the Rectangle object. The following equation is used to calculate the new width and position of the rectangle: <code>x -= dx; width += 2 * dx;</code>
	@param inY: The value to be added to the top and the bottom of the Rectangle object. The following equation is used to calculate the new height and position of the rectangle: <code>y -= dy; height += 2 * dy;</code>
	*/
	public function inflate (inX:Number, inY:Number) : Void {
		mX -= inX;
		mWidth += (2 * inX);
		mY -= inY;
		mHeight += (2 * inY);
	}
	
	/**
	Increases the size of the Rectangle object. This method is similar to the Rectangle.inflate() method, except that it takes a Point object as a parameter.
	@param inPoint: resizes the rectangle by the x and y coordinate values of the point
	@example
	<code>
	var rect:Rectangle = new Rectangle(0, 0, 2, 5);
	trace(rect.toString()); // (x=0, y=0, w=2, h=5
	
	var myPoint:Point = new Point(2, 2);
	rect.inflatePoint(myPoint);
	trace(rect.toString()); // (x=-2, y=-2, w=6, h=9)
	</code>
	Similarly the Rectangle can be decreased. In the following example the Rectangle is decrease by 20 pixels at each side:
	<code>
	import org.asapframework.util.RectangleUtils;

	var viewPort:Rectangle = RectangleUtils.boundsOfMovieClip(world_mc);
	var margins:Point = new Point(-20, -20);
	viewPort.inflatePoint(margins);
	</code>
	*/
	public function inflatePoint (inPoint:Point) : Void {
		mX -= inPoint.x;
		mWidth += (2 * inPoint.x);
		mY -= inPoint.y;
		mHeight += (2 * inPoint.y);
	}
	
	/**
	If the Rectangle object specified in the inRectangle parameter intersects with this Rectangle object, the intersection() method returns the area of intersection as a Rectangle object. If the rectangles do not intersect, this method returns an empty Rectangle object with its properties set to 0.
	@param inRectangle: the Rectangle object to compare against to see if it intersects with this Rectangle object
	@return A Rectangle object that equals the area of intersection. If the rectangles do not intersect, this method returns an empty Rectangle object; that is, a rectangle with its x, y, width, and height properties set to 0.
	@example
	<code>
	var rectangle1:Rectangle = new Rectangle(0, 0, 50, 50);
	var rectangle2:Rectangle = new Rectangle(25, 25, 100, 100);
	var intersectingArea:Rectangle = rectangle1.intersection(rectangle2);
	trace(intersectingArea.toString()); // (x=25, y=25, w=25, h=25)
	</code>
	*/
	public function intersection (inRectangle:Rectangle) : Rectangle {
		var rectangle = getIntersectionRectangle(inRectangle);
		if (rectangle.width <= 0 || rectangle.height <= 0) {
			// does not intersect, return empty Rectangle
			return new Rectangle();
		}
		return rectangle;
	}
	
	private function getIntersectionRectangle (inRectangle:Rectangle) : Rectangle {
		var x:Number, y:Number;
		var largestX:Number = x = Math.max(inRectangle.x, mX);
		var largestY:Number = y = Math.max(inRectangle.y, mY);
		var smallestRight:Number = Math.min(inRectangle.right, right);
		var smallestBottom:Number = Math.min(inRectangle.bottom, bottom);
		var width:Number = smallestRight - largestX;
		var height:Number = smallestBottom - largestY;
		return new Rectangle(x, y, width, height); 
	}
	
	/**
	Determines whether the object specified in the toIntersect parameter intersects with this Rectangle object. This method checks the x, y, width, and height properties of the specified Rectangle object to see if it intersects with this Rectangle object.
	@param inRectangle: the Rectangle object to compare against this Rectangle object
	@return If the specified object intersects with this Rectangle object, returns true; otherwise false.
	@example
	<code>
	var rectA:Rectangle = new Rectangle(10, 10, 50, 50);
	var rectB:Rectangle = new Rectangle(59, 59, 50, 50);
	var rectC:Rectangle = new Rectangle(60, 60, 50, 50);
	var rectAIntersectsB:Boolean = rectA.intersects(rectB);
	var rectAIntersectsC:Boolean = rectA.intersects(rectC);
	trace(rectAIntersectsB); // true
	trace(rectAIntersectsC); // false
	
	var firstPixel:Rectangle = new Rectangle(0, 0, 1, 1);
	var adjacentPixel:Rectangle = new Rectangle(1, 1, 1, 1);
	var pixelsIntersect:Boolean = firstPixel.intersects(adjacentPixel);
	trace(pixelsIntersect); // false
	</code>
	*/
	public function intersects (inRectangle:Rectangle) : Boolean {
		var rectangle = getIntersectionRectangle(inRectangle);
		if (rectangle.width <= 0 || rectangle.height <= 0) {
			return false;
		}
		return true;
	}
	
	/**
	Adjusts the location of the Rectangle object, as determined by its top-left corner, by the specified amounts.
	@param inX: moves the x value of the Rectangle object by this amount
	@param inY: moves the y value of the Rectangle object by this amount
	*/
	public function offset (inX:Number, inY:Number) : Void {
		mX += inX;
		mY += inY;
	}
	
	/**
	Adjusts the location of the Rectangle object using a Point object as a parameter. This method is similar to the Rectangle.offset() method, except that it takes a Point object as a parameter.
	@param inPoint: a Point object to use to offset this Rectangle object
	*/
	public function offsetPoint (inPoint:Point) : Void {
		mX += inPoint.x;
		mY += inPoint.y;
	}
	
	/**
	Adds two rectangles together to create a new Rectangle object, by filling in the horizontal and vertical space between the two rectangles.
	@param inRectangle: a Rectangle object to add to this Rectangle object
	@return A new Rectangle object that is the union of the two rectangles.
	*/
	public function union (inRectangle:Rectangle) : Rectangle {
		var x:Number = Math.min(inRectangle.x, mX);
		var y:Number = Math.min(inRectangle.y, mY);
		var largestRight:Number = Math.max(inRectangle.right, right);
		var largestBottom:Number = Math.max(inRectangle.bottom, bottom);
		var width:Number = largestRight - x;
		var height:Number = largestBottom - y;
		return new Rectangle(x, y, width, height); 
	}
	
	/**
	Determines whether or not this Rectangle object is empty.
	@return If the Rectangle object's width or height is less than or equal to 0, returns true; otherwise false.
	*/
	public function isEmpty() : Boolean {
		return (mWidth <= 0) || (mHeight <= 0);
	}
	
	/**
	Sets all of the Rectangle object's properties to 0. A Rectangle object is empty if its width or height is less than or equal to 0. This method sets the values of the x, y, width, and height properties to 0.
	*/
	public function setEmpty() : Void {
		mX = mY = mWidth = mHeight = 0;
	}
	
	/**
	Builds and returns a string that lists the horizontal and vertical positions and the width and height of the Rectangle object.
	*/
	public function toString () : String {
		return "(x=" + mX + ", y=" + mY + ", w=" + mWidth + ", h=" + mHeight + ")";
	}
	
}