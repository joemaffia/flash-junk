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
Sine tween functions.
@author Arthur Clemens
*/

class org.asapframework.util.transitions.tween.Sine {

	/**
	@param t : current time
	@param b : beginning value
	@param c : total change
	@param d : duration
	*/
	static function easeIn (t:Number, b:Number, c:Number, d:Number) : Number {
		return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
	}
	
	/**
	@param t : current time
	@param b : beginning value
	@param c : total change
	@param d : duration
	*/
	static function easeOut (t:Number, b:Number, c:Number, d:Number) : Number {
		return c * Math.sin(t/d * (Math.PI/2)) + b;
	}
	
	/**
	@param t : current time
	@param b : beginning value
	@param c : total change
	@param d : duration
	*/
	static function easeInOut (t:Number, b:Number, c:Number, d:Number) : Number {
		return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
	}

}