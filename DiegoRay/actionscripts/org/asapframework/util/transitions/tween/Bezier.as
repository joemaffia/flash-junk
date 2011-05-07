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
Bezier tween function.
@author Arthur Clemens
*/

class org.asapframework.util.transitions.tween.Bezier {

	// Cubic Bezier tween from b to b+c, influenced by p1 & p2
	// t: current time, b: beginning value, c: total change, d: duration
	// p1, p2: Bezier control point positions
	static function cubic (t:Number, b:Number, c:Number, d:Number, p1:Number, p2:Number) : Number {
		return ((t/=d)*t*c + 3*(1-t)*(t*(p2-b) + (1-t)*(p1-b)))*t + b;
	}
}