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

import org.asapframework.ui.buttons.CheckBoxEvent;

/**
	@author Martijn de Visser
	@description CheckBox class to create checkboxes with. Class puts label in textfield named label_txt. Assumes the presence of the following framelabels to represent states:
	<ul>
		<li>'unselected_disabled'</li>
		<li>'unselected_normal'</li>
		<li>'unselected_rollover'</li>
		<li>'unselected_press'</li>
		<li>'selected_disabled'</li>
		<li>'selected_normal'</li>
		<li>'selected_rollover'</li>
		<li>'selected_press'</li>
	</ul>
*/

class org.asapframework.ui.buttons.CheckBox extends org.asapframework.ui.buttons.EventButton implements org.asapframework.util.forms.validate.IValidate {

	// publicly accessible framelabel names
	private var disabledUnselected:String;
	private var normalUnselected:String;
	private var rollOverUnselected:String;
	private var pressUnselected:String;
	private var disabledSelected:String;
	private var normalSelected:String;
	private var rollOverSelected:String;
	private var pressSelected:String;
	private var rollOverEvent:String;
	private var rollOutEvent:String;
	private var changeEvent:String;

	private var mc:MovieClip;
	private var mMask:MovieClip;
	private var mLabel:TextField;
	private var mEnabled:Boolean = true;
	private var mSelected:Boolean = false;
	private var mLabelText:String;

	public function CheckBox() {

		super();

		// set default frames names and events
		disabledUnselected	= "unselected_disabled";
		normalUnselected 	= "unselected_normal";
		rollOverUnselected	= "unselected_rollover";
		pressUnselected		= "unselected_press";
		disabledSelected	= "selected_disabled";
		normalSelected 		= "selected_normal";
		rollOverSelected	= "selected_rollover";
		pressSelected		= "selected_press";
	}

	/**
	*	
	*/
	public function onLoad () : Void {

		// set defaults
		mEnabled = true;
		mLabel = TextField(mMc.label_txt);

		// create clickable mask
		createMask();

		// set initial frame
		setSelected(mSelected);
	}

	/**
	*	Creates mask for clickable label text.
	*/
	private function createMask () : Void {

		if (mLabel != undefined) {

			mMask = mMc.createEmptyMovieClip("mask_mc", 10);

			// create the mask (to make text clickable)
			with(mMask)	{
				lineStyle(0,0x000000,0);
				beginFill(0x000000,0);
				moveTo(0, 0);
				lineTo(5, 0);
				lineTo(5, 5);
				lineTo(0, 5);
				lineTo(0, 0);
				endFill();
			}

			// align with textfield position
			mMask._x = mLabel._x;
			mMask._y = mLabel._y;
		}
	}

	public function onRollOver () : Void {
		
		super.onRollOver();

		if (mEnabled) {

			if (mSelected) {
				setFrame(rollOverSelected);

			} else {
				setFrame(rollOverUnselected);
			}
		}
	}

	public function onRollOut () : Void {

		super.onRollOut();

		if (mEnabled) {

			if (mSelected) {
				setFrame(normalSelected);

			} else {
				setFrame(normalUnselected);
			}
		}
	}

	public function onPress () : Void {

		super.onPress();

		if (mEnabled) {

			if (mSelected) {
				setFrame(pressSelected);

			} else {
				setFrame(pressUnselected);
			}
		}
	}

	/**
	@sends CheckBoxEvent#ON_CHANGED
	*/
	public function onRelease () : Void {

		if (mEnabled) {

			mSelected = !mSelected;
			
			if (mSelected) {
				setFrame(rollOverSelected);
			} else {
				setFrame(rollOverUnselected);
			}
			
			dispatchEvent(new CheckBoxEvent(CheckBoxEvent.ON_CHANGED, this, mSelected));
		}
	}

	/**
	*	Draws frame and label.
	*/
	private function setFrame( inFrame:String ) : Void {

		// jump frame
		mMc.gotoAndStop(inFrame);
		// refresh text
		label = mLabelText;
	}

	/**
	*	Returns true if checkbox is in selected state.
	*/
	public function getValue () : Object {

		return mSelected;
	}

	/**
	*	Gets the enabled state.
	*/
	public function getEnabled () : Boolean {

		return mEnabled;
	}

	/**
	*	Sets the enabled state.
	*/
	public function setEnabled ( inValue:Boolean ) : Void {

		// set flag and handcursor
		mEnabled = inValue;
		useHandCursor = inValue;

		// update appearance
		if (mEnabled) {
			if (mSelected) {
				setFrame(normalSelected);
			} else {
				setFrame(normalUnselected);
			}
		} else {
			if (mSelected) {
				setFrame(disabledSelected);
			} else {
				setFrame(disabledUnselected);
			}
		}
	}

	/**
	*	Gets the selected state.
	*/
	public function getSelected () : Boolean {

		return mSelected;
	}

	/**
	*	Sets the selected state.
	*/
	public function setSelected ( inValue:Boolean ) : Void {

		// set flag
		mSelected = inValue;

		// update appearance
		if (mEnabled) {
			if (mSelected) {
				setFrame(normalSelected);
			} else {
				setFrame(normalUnselected);
			}
		} else {
			if (mSelected) {
				setFrame(disabledSelected);
			} else {
				setFrame(disabledUnselected);
			}
		}
	}

	/**
	*	The label text.
	*/
	public function set label ( inLabel:String ) {

		// set label text
		mLabelText = inLabel;
		mLabel.html = true;
		mLabel.htmlText = mLabelText;
		mLabel.multiline = false;
		mLabel.wordWrap = false;
		mLabel.autoSize = true;

		// resize mask
		mMask._height = mLabel._height;
		mMask._width = mLabel._width;
	}
	public function get label () : String {
	
		return mLabelText;
	}
}
