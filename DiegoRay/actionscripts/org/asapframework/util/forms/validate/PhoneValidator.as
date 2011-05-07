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

import org.asapframework.util.StringUtilsTrim;
import org.asapframework.util.forms.validate.IValidationRule;
import org.asapframework.util.forms.validate.ValidationRule;

/**
Validates if target's value is a (Dutch) phone number. That means that it should have 10 digits in a row and start with 0 (zero), example: 0204604500
@author Martijn de Visser
@implementationNote Please note that any leading and trailing spaces will be ignored. 
*/

class org.asapframework.util.forms.validate.PhoneValidator extends ValidationRule implements IValidationRule {
	
	/**	
	@param inTarget: Object to validate, has to implement the {@link org.asapframework.util.forms.validate.IValidate} interface. Except TextFields, these will be accessed through .text.
	*/
	public function PhoneValidator( inTarget:Object ) {		
		super(inTarget, null);
	}
	
	/**
	Validates rule.
	@todo: Implement extended patterns, so international numbers can be validated as well (start with '+', may be more or less than 10 digits).
	*/
	public function validate () : Boolean {
		
		var s:String = StringUtilsTrim.trim(String(getValue()));
	
		if (s.length != 10) {
			
			return false;
			
		} else if (isNaN(s)) {
			
			return false;
			
		} else if (s.charAt(0) != "0") {
			
			return false;
		}
		return true;
	}
	
	/**
	Returns readable name of rule.
	*/
	public function toString () : String {
		return "PhoneValidator";
	}
}