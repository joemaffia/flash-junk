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

// ASAP classes
import org.asapframework.ui.input.HintedInputField;

/**
Class to be used for text input in forms with validation.

Attach this class to a movieclip containing the following:
<ul>
<li>a textfield named "input_txt"</li>
<li>two frames with labels "ok" & "error"</li>
<li>some visible distinction between the content on the two labels, p.e. a red border or background on the "error" label that isn't there on the "ok" label</li>
</ul>

@example
This example shows how to initialize and perform validation and feedback.
Assume three ErrorInputField instance are present on the timeline, named "title_mc", "name_mc" & "email_mc".
Before posting the form, the fields are validated. The title & name will have to be non-empty, the email is checked for valid structure. 
<code>
class Form extends MovieClip {
	private var mValidator:Validator;
	private var mInputFields:Array; // all ErrorInputField instances
	
	private function onLoad () : Void {
		var timeline:MovieClip = MovieClip(this);

		// retrieve input fields from the timeline
		var titleField:ErrorInputField = ErrorInputField(timeline.title_mc);
		var nameField:ErrorInputField = ErrorInputField(timeline.name_mc);
		var emailField:ErrorInputField = ErrorInputField(timeline.email_mc);
		
		// store input fields in list
		mInputFields = [titleField, nameField, emailField];
		
		// create validator
		mValidator = new Validator();
		
		// add specific field validation
		mValidator.addValidation(new StringValidator(nameField));
		mValidator.addValidation(new StringValidator(titleField));
		mValidator.addValidation(new EmailValidator(emailField));
	}
	
	private function validate () : Void {
		// hide errors on input fields
		var len:Number = mInputFields.length;
		for (var i : Number = 0; i < len; i++) {
			ErrorInputField(mInputFields[i]).showError(false);
		}
		
		// do validation
		var result:ValidationResult = mValidator.validate();
		
		if (!result.success) {
			// loop through errors
			for (var i:Number=0; i<result.errors.length; ++i) {
				var error:ValidationError = ValidationError(result.errors[i]);
				
				// show visible error on input field
				if (error.target instanceof ErrorInputField) {
					ErrorInputField(error.target).showError(true);
				}
			}		
		}
	}
}
</code>
 */

class org.asapframework.ui.input.ErrorInputField extends HintedInputField {

	private var mText:String;

	private static var OK_FRAME:String = "ok";
	private static var ERROR_FRAME:String = "error";

	/**
	*	Constructor
	*/
	public function ErrorInputField () {

		super();
	}
	
	/**
	*	Show textfield in 'error' or 'ok' state
	*	@param inError: if true, the error state (frame labeled "error") will be shown; otherwise frame labeled "ok" will be shown
	*/
	public function showError ( inError:Boolean ) : Void {
	
		mText = mInput.text;
		
		if (inError) {			
			mMc.gotoAndStop(ERROR_FRAME);
		} else {			
			mMc.gotoAndStop(OK_FRAME);
		}
		
		updateTextField();
	}
	
	/**
	*	
	*/
	private function updateTextField (  ) : Void {
		if (mHasFocus) {
			// received focus
			if (mInput.text == mHint) {
				// text same as hint, clear field
				text = "";
			}
		} else {
			// lost focus
			if (mInput.text == "" || mInput.text == mHint) {
				// nothing or hint itself typed, show hint
				if (mHint != null) {
					hint = mHint;
				} else {
					hint = "";
				}
			}
		}
	}
}