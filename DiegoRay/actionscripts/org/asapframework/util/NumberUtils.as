/*
Copyright 2005-2006 by the authors of asapframework

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
Number utility functions.
@author Arthur Clemens
*/

class org.asapframework.util.NumberUtils {
	
	/**
	Creates a random number within a given range.
	@param inStartRange : lowest number of the range
	@param inEndRange : highest number of the range
	@return A new random number.
	@example
	This example creates a random number between 10 and 20:
	<code>
	var scale:Number = NumberUtils.randomInRange(10, 20);
	</code>
	*/
	public static function randomInRange (inStartRange:Number, inEndRange:Number) : Number {
		var d:Number = inEndRange - inStartRange;
		return inStartRange + (d - Math.random() * d);
	}
	
	/**
	Creates a random number within a list of ranges.
	Pass a list of Arrays, each one separated by a comma.
	@return A new random number.
	@example
	This example creates a random number in between -45 and 40, or between 40 and 45:
	<code>
	var rotation:Number = NumberUtils.randomInRanges([-45, -40], [40, 45]);
	</code>
	*/
	public static function randomInRanges (inRanges:Array) : Number {
		var args:Array = arguments;
		var item:Number = Math.floor(Math.random() * args.length);
		var range:Array = args[item];
		return NumberUtils.randomInRange(range[0], range[1]);
	}
	
	/**
	Truncates floating point digits.
	@param inNumber : the number to truncate
	@param inDigits : the number of digits to keep after truncating
	@return A new number with truncated floating point digits.
	@example
	<code>
	var pi:Number = 3.14159265;
	pi = NumberUtils.truncate(pi, 2);
	// 3.14
	</code>
	*/
	public static function truncate (inNumber:Number, inDigits:Number) : Number {
		if (inDigits < 0) {
			return inNumber;
		}
		var n:Number = 1;
		while (inDigits--) {
			n *= 10;
		}
		return Math.round(inNumber * n) / n;
	}
	
	/**
	Finds the x value of a point on a sine curve, of which only the y value is known. The closest x value is returned. This will range from -1 pi to 1 pi.
	@param inFindValue: y value of point to find on the sine curve
	@param inMinValue: min y value (bottom) of the sine curve
	@param inMaxValue: max y value (top) of the sine curve
	@return The offset value as multiplier of pi.
	@implementationNote Calls {@link #normalizedValue}.
	@example
	<code>
	NumberUtils.piOffset(1, -1, 1); // 1.5707963267949 ( = 0.5 * Math.PI )
	</code>
	*/
	public static function piOffset (inFindValue:Number,
									 inMinValue:Number,
									 inMaxValue:Number) : Number {
		return Math.asin( 2 * NumberUtils.normalizedValue(inFindValue, inMinValue, inMaxValue) - 1 );
	}
	
	/**
	Finds the normalized value (between 0 and 1) of the number inValueToNormalize, related to the normalized range, defined by lowest range value inMinValue and highest range value inMaxValue.
	Normalizes a value, making it a value between 0 and 1
	@param inValueToNormalize: value to normalize
	@param inMinValue: min value
	@param inMaxValue: max value
	@return The normalized y value: a value between 0 and 1.
	@example
	<code>
	NumberUtils.normalizedValue(25, 0, 100); // 0.25
	NumberUtils.normalizedValue(0, -1, 1); // 0.5
	</code>
	*/
	public static function normalizedValue (inValueToNormalize:Number,
											inMinValue:Number,
											inMaxValue:Number) : Number {
		var f:Number = 1 / (inMaxValue - inMinValue);
		return f * (inValueToNormalize - inMinValue);
	}
	
	/**
	Calculates the angle of a vector.
	@param inDx : the x component of the vector
	@param inDy : the y component of the vector
	@return The the angle of the passed vector in degrees.
	*/
	public static function angle (inDx:Number, inDy:Number) : Number {
		return Math.atan2(inDy, inDx) * 180/Math.PI;
	}
	
}