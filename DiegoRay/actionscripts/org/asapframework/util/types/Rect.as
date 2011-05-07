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
Basic rectangle class. For more options see {@link Rectangle}.
@deprecated Flash 7 projects: use {@link Rectangle}; projects that use Flash 8 or higher: use the Adobe Rectangle class.
*/

class org.asapframework.util.types.Rect {

	public var tl:Point;
	public var br:Point;

	/**
	Creates a rectangle that consists of four points
	@param inX1, Number defines the left corner
	@param inY1, Number defines the top corner
	@param inX2, Number defines the right corner
	@param inY1, Number defines the bottom corner
	*/
	public function Rect ( inX1:Number, inY1:Number, inX2:Number, inY2:Number ) {

		tl = new Point(inX1,inY1);
		br = new Point(inX2,inY2);
	}

	public function set x1 ( inPos:Number ) { tl.x = inPos; };
	public function set y1 ( inPos:Number ) { tl.y = inPos; };
	public function set x2 ( inPos:Number ) { br.x = inPos; };
	public function set y2 ( inPos:Number ) { br.y = inPos; };

	public function get x1 () : Number { return tl.x; };
	public function get y1 () : Number { return tl.y; };
	public function get x2 () : Number { return br.x; };
	public function get y2 () : Number { return br.y; };


	/**
	Determines whether the point lies inside the rectangle
	@param inPoint:Point
	@returns Boolean, true if the point lies inside the rectangle
	*/
	public function containsPoint (inPoint:Point) : Boolean {
		return (inPoint.x >= tl.x) && (inPoint.x <= br.x) && (inPoint.y >= tl.y) && (inPoint.y <= br.y);
	}

	/**
	Determines whether the rectangles overlap
	@param inRect:Rect
	@returns Boolean, true if the rectangles overlap
	*/
	public function overlaps (inRect:Rect) : Boolean {
		return (containsPoint(inRect.tl) || containsPoint(inRect.br) || containsPoint(new Point(inRect.x1, inRect.y2)) || containsPoint(new Point(inRect.x2, inRect.y1)));
	}

	public function toString () : String {
		return "[" + x1 + "," + y1 + "," + x2 + "," + y2 + "]";
	}
}