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

/**
Base class for validation rule classes, subclasses must implement the {@link org.asapframework.util.forms.validate.IValidationRule} interface.
@author Martijn de Visser
*/

class org.asapframework.util.forms.validate.ValidationRule implements IValidationRule {		

	private var mTarget:Object;
	private var mCondition:Object;

	/**	
	@param inTarget: Target object to validate, has to implement the {@link org.asapframework.util.forms.validate.IValidate} interface. Except TextFields, these will be accessed through .text.
	@param inCondition: sometimes needed to test against (for example in a greater than validation)
	*/
	public function ValidationRule ( inTarget:Object, inCondition:Object ) {

		mTarget = inTarget;
		mCondition = inCondition;
	}
	
	/**
	Validates this rule, implement in subclass.
	*/
	public function validate () : Boolean {
		return false;
	}

	/**
	The (untyped) validation target. Must either implement {@link org.asapframework.util.forms.validate.IValidate} or be a TextField.
	*/
	public function getTarget () : Object {
		return mTarget;
	}
	
	/**
	The (untyped) value of the validation target.
	*/
	public function getValue () : Object {

		var val:Object;
		
		// get value to test rule against
		if (mTarget instanceof TextField) {
			val = mTarget.text;
		} else {
			val = mTarget.getValue();
		}
		
		return val;
	}

	/**
	The (untyped) validation condition.
	*/
	public function getCondition () : Object {
		return mCondition;
	}
		
	public function toString () : String {
		return "ValidationRule";
	}
}