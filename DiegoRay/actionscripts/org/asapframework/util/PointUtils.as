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
//import flash.geom.Point;
// Still support Flash 7:
import org.asapframework.util.types.*;

/**
Point utility methods.
*/

class org.asapframework.util.PointUtils {

	/**
	Mutliplies the coordinates of the given Point and creates a new Point with the result.
	@param inPoint: the Point to multiply
	@param inFactor: the multiply factor
	@return The new Point.
	@use
	<code>
	var point:Point = new Point(100,200);
	var newPoint:Point = PointUtils.multiply(point, 0.5); // (50,100)
	</code>
	*/
	public static function multiply (inPoint:Point, inFactor:Number) : Point {
		return new Point(inPoint.x * inFactor, inPoint.y * inFactor);
	}
	
		
	/**
	Calculates the average of two points and creates a new Point with the result.
	@param a: the first Point
	@param b: the second Point
	@return A new Point with the average of Point a and Point b.
	*/
	public static function average (a:Point, b:Point) : Point {
		return new Point((a.x + b.x) * 0.5, (a.y + b.y) * 0.5);
	}
	
}
