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
A collection of Boolean utility functions.
@author Martijn de Visser
*/

class org.asapframework.util.BooleanUtils {

	/**
	Attempts to convert a String or Number to a native Boolean.
	*/
	public static function getBoolean ( inValue:Object ) : Boolean {

		switch( inValue ) {

			case true :
			case "on" :
			case "true" :
			case "yes" :
			case "1" :
			case 1 :

				return true;
				break;

			case "off" :
			case "false" :
			case "no" :
			case "0" :
			case 0 :

				return false;
				break;

			default :

				return false;
				break;

		}
	}
}
