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

import org.asapframework.util.debug.Log;
import org.asapframework.util.forms.validate.IValidationRule;
import org.asapframework.util.forms.validate.ValidationError;
import org.asapframework.util.forms.validate.ValidationResult;

/**	
Validator class checks if its targets contain valid data.
@author Martijn de Visser
@usage
<code>
myValidator = new Validator();
myValidator.addValidation(new StringValidator(to_name));
myValidator.addValidation(new EmailValidator(to_email));
</code>
To validate the rules added above:
<code>
var formResult:ValidationResult = myValidator.validate();
</code>
This will return a {@link org.asapframework.util.forms.validate.ValidationResult} object with:
<ul>
	<li>{@link ValidationResult#success} : boolean indicating success or not.</li>
	<li>{@link ValidationResult#errors} : if 'success' is false, an array named 'errors' will be present with {@link org.asapframework.util.forms.validate.ValidationError} objects in it:
		<ul>
			<li>{@link ValidationError#target} : reference to failing target (IValidate object or TextField)</li>
			<li>{@link ValidationError#rule} : failing rule for this target (IValidationRule)</li>
		</ul>
	</li>
</ul>
 */

class org.asapframework.util.forms.validate.Validator {

	private var mRules:Array;
	
	public function Validator () {
		
		mRules = new Array();
	}

	/**
	Adds a validation condition for this target. You can add more rules for one target.
	@param rule: Validation rule. Currently, the following rules are available:	
	{@link StringValidator}
	{@link NumericValidator}
	{@link SelectedValidator}
	{@link EmailValidator}
	{@link NotValidator}
	{@link GTValidator}
	{@link LTValidator}
	{@link DutchPostcodeValidator}
	{@link PhoneValidator}
	 */
	public function addValidation ( inRule:IValidationRule ) : IValidationRule {

		// valid rule?
		if (inRule != undefined) {
			
			mRules.push(inRule);
			return inRule;
				
		} else {
			
			Log.warn("addValidation: No rule specified!", toString());
			return null;
		}
	}

	/**
	Validates the value of all targets, or just one target object when specified.
	@returns {@link ValidationResult}, indicating successfull validation and error messages.
	*/
	public function validate ( inTarget:Object ) : ValidationResult {

		var result:ValidationResult = new ValidationResult();
		var success:Boolean = true;
		var tOK:Number = -1;

		// loop all validations and store all non-valid rules
		for (var i:Number=0; i<mRules.length; ++i) {

			// get rule
			var rule:IValidationRule = IValidationRule(mRules[i]);

			// target undefined, or, if defined, same as current target?
			if (inTarget == undefined || (inTarget == rule.getTarget() && tOK != -1)) {

				// test rule...
				if (!rule.validate()) {

					result.addError(new ValidationError(rule.getTarget(), rule));
					success = false;
				}
			}
		}

		result.success = success;
		return result;
	}

	/**
	Returns an array of all targets.
	*/
	public function getTargets () : Array {

		var targets:Array = new Array();

		// loop all rules
		for (var i:Number=0; i<mRules.length; ++i) {

			var target:Object = IValidationRule(mRules[i]).getTarget();
			targets.push(target);
		}

		return targets;
	}
	
	/**
	Returns an array of all validation rules.
	*/
	public function getRules () : Array {

		return mRules;
	}

	/**
	Removes all validation rules.
	*/
	public function clear () : Void {

		mRules = [];
	}
	
	public function toString() : String {
		return ";org.asapframework.util.forms.validate.Validator";
	}
}