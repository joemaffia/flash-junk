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
import org.asapframework.util.StringUtilsTrim;
import org.asapframework.ui.input.InputField;

/**
	@author Martijn de Visser
	@description Class to create a hinted input field with. The hint is shown in the field. As soon as the field gets focus, the hint is removed. If no text is entered or the same text as the hint text is entered, the hint will re-appear as soon as the textfield looses focus.
	@usage
	<code>	
	var mHintFormat:TextFormat = new TextFormat();
	mHintFormat.color = 0x067ADD;

	var mTextFormat:TextFormat = new TextFormat();
	mTextFormat.color = 0x001E69;
	
	msg_txt.textFormat = mTextFormat;
	msg_txt.hintFormat = mHintFormat;
	msg_txt.hint = "(your message)";
	</code>
*/

class org.asapframework.ui.input.HintedInputField extends InputField implements org.asapframework.util.forms.validate.IValidate, org.asapframework.management.focus.IFocus {

	private var mHint:String;
	private var mTrimmedHint:String;
	private var mHintFormat:TextFormat;

	public function HintedInputField () {

		super();
		
		mHintFormat = mInput.getTextFormat();
	}

	// EVENTS

	/**
	Triggered by input field.
	@param inFocus: 
	*/
	public function onChangeTextFocus ( inFocus:Boolean ) : Void {

		super.onChangeTextFocus(inFocus);
		var input:String = StringUtilsTrim.trim(mInput.text);

		if (mHasFocus) {

			// received focus
			if (input == mTrimmedHint) {
				// text same as hint, clear field
				text = "";
			}

		} else {

			// lost focus
			if (input == "" || input == mTrimmedHint) {

				// nothing or hint itself typed, show hint
				if (mHint != null) {
					hint = mHint;
				} else {
					hint = "";
				}
			}
		}
	}
	
	// IVALIDATE IMPLEMENTATION

	/**
	IValidate implementation: Returns the contents of the text field.
	*/
	public function getValue () : Object {

		return (mInput.text == mTrimmedHint)? "" : mInput.text;
	}

	// GETTERS / SETTERS

	/**
	The hint text.
	*/
	public function set hint ( inHint:String ) {

		mHint = inHint;
		mTrimmedHint = StringUtilsTrim.trim(mHint);

		mInput.setTextFormat(mHintFormat);
		mInput.setNewTextFormat(mHintFormat);
		mInput.text = mHint;
		maxChars = mMaxChars;
		restrict = mRestrict;
	}
	public function get hint () : String {

		return mHint;
	}
	
	/**
	The text of the HintedInputField.
	*/
	public function set text ( inText:String ) {

		if (inText != undefined) {
			mInput.setTextFormat(mTextFormat);
			mInput.setNewTextFormat(mTextFormat);
			mInput.text = inText;
			maxChars = mMaxChars;
			restrict = mRestrict;
		}
	}
	public function get text () : String {

		if (mInput.text == mHint) {
			return "";
		} else {
			return mInput.text;
		}
	}

	/**
	The TextFormat of the hint state.
	*/
	public function set hintFormat ( inFormat:TextFormat ) {

		mHintFormat = inFormat;
	}
}
