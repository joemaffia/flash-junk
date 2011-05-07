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
import org.asapframework.management.focus.IFocus;
import org.asapframework.ui.EventMovieClip;
import org.asapframework.ui.input.InputEvent;
import org.asapframework.util.forms.validate.IValidate;

/**
	@author Martijn de Visser
	@description Class to create an input field with. Class assumes there's a texfield named 'input_txt' present in MovieClip to read/write values
*/

class org.asapframework.ui.input.InputField extends EventMovieClip implements IValidate, IFocus {

	private var mHasFocus:Boolean;
	private var mEnabled:Boolean;
	private var mMc:MovieClip;
	private var mInput:TextField;
	private var mMaxChars:Number;
	private var mRestrict:String;
	private var mTextFormat:TextFormat;

	public function InputField () {

		super();
		
		// set vars
		mMc = MovieClip(this);
		mInput = TextField(mMc.input_txt);

		// catch input text field change event
		var owner:InputField = this;
		mInput.onChanged = function( ) : Void { 
			owner.onTextChange(this.text);
		};
		mInput.onSetFocus = function( ) : Void {
			owner.onChangeTextFocus(true);
		};
		mInput.onKillFocus = function( ) : Void {
			owner.onChangeTextFocus(false);
		};
	}

	public function onLoad () : Void {

		// set default values
		mHasFocus = false;
		mEnabled = true;
		tabEnabled = false;
		tabChildren = false;
	}

	public function onUnload () : Void {

		mHasFocus = false;
	}

	// EVENTS

	/**
	*	Triggered by input field
	*/
	public function onChangeTextFocus ( inFocus:Boolean ) : Void {

		mHasFocus = inFocus;
	}

	/**
	Triggered by input field
	@sends InputEvent#ON_CHANGED
	*/
	public function onTextChange ( inText:String ) : Void {

		// dispatch onInputFieldChanged event
		dispatchEvent(new InputEvent(InputEvent.ON_CHANGED, this, mInput.text) );
	}

	// IFOCUS IMPLEMENTATION

	/**
	IFocus implementation: Triggered by input field
	*/
	public function setFocus () : Void {
		// sets focus to inputfield
		Selection.setFocus(mInput);
		onChangeTextFocus(true);
	}

	/**
	IFocus implementation: Triggered by input field
	*/
	public function hasFocus () : Boolean {

		// sets focus to inputfield
		return mHasFocus;
	}

	// IVALIDATE IMPLEMENTATION

	/**
	IValidate implementation: Returns the contents of the text field.
	*/
	public function getValue () : Object {

		return mInput.text;
	}

	/**
	Gets the enabled state of the InputField
	*/
	public function getEnabled () : Boolean {

		return mEnabled;
	}

	/**
	Sets the enabled state of the InputField
	*/
	public function setEnabled ( inValue:Boolean ) : Void {

		mEnabled = inValue;
		mInput.selectable = inValue;
	}
	
	// GETTER / SETTER

	/**
	*	Sets / gets the text of the InputField
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

		return mInput.text;
	}

	/**
	The actual input text field.
	*/
	public function get field () : TextField {
		return mInput;
	}

	/**
	The TextFormat of the text-input state.
	*/
	public function set textFormat ( inFormat:TextFormat ) {

		mTextFormat = inFormat;
		mInput.setTextFormat(mTextFormat);
		mInput.setNewTextFormat(mTextFormat);
	}
	
	/**
	Same as TextField.maxChars
	*/
	public function set maxChars ( inChars:Number ) {

		if (inChars > 0 && inChars != null) {
			mMaxChars = inChars;
			mInput.maxChars = inChars;
		}
	}
	
	/**
	Same as TextField.restrict.
	*/
	public function set restrict ( inChars:String ) {

		if (inChars != "" && inChars != null) {
			mRestrict = inChars;
			mInput.restrict = inChars;
		}
	}
}
