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

import org.asapframework.util.forms.validate.IValidationRule;
import org.asapframework.util.forms.validate.ValidationRule;

/**
Validates if target's value is String of at least specified length.
@author Martijn de Visser
*/

class org.asapframework.util.forms.validate.StringValidator extends ValidationRule implements IValidationRule {
	
	/**	
	@param inTarget: Target object to validate, has to implement the {@link org.asapframework.util.forms.validate.IValidate} interface. Except TextFields, these will be accessed through .text.
	@param inCondition: (optional) mimimal length of String. Defaults to 1 if omitted.
	*/
	public function StringValidator( inTarget:Object, inCondition:Number ) {		
		super(inTarget, inCondition);
		// check to see if no weird length was specified
		if (mCondition == undefined || mCondition < 0) mCondition = 1;
	}
	
	/**
	Validates rule.
	*/
	public function validate () : Boolean {
		return (String(getValue()).length) >= Number(getCondition());
	}
	
	/**
	Returns readable name of rule.
	*/
	public function toString () : String {
		return "StringValidator";
	}
}