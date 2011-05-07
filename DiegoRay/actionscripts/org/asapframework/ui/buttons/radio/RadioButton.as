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
import org.asapframework.ui.buttons.radio.*;
import org.asapframework.ui.buttons.EventButton;


/**
Creates radiobutton functionality. Assumes the presence of the following framelabels to represent states:
<ul>
	<li>'deselected_normal'</li>
	<li>'deselected_rollover'</li>
	<li>'deselected_mousedown'</li>
	<li>'selected_normal'</li>
	<li>'selected_rollover'</li>
	<li>'selected_mousedown'</li>
</ul>
This class also automatically creates a clickable mask that will match the total size of the component (button + label)
You should place a dynamic textfield named 'label_txt' in which the label will be placed (use .label = "my label")
@author Martijn de Visser
 */

class org.asapframework.ui.buttons.radio.RadioButton extends EventButton implements IRadioButton {

	private static var DEFAULT_FRAME_DESELECTED_NORMAL = "deselected_normal";
	private static var DEFAULT_FRAME_DESELECTED_ROLLOVER = "deselected_rollover";
	private static var DEFAULT_FRAME_DESELECTED_MOUSEDOWN = "deselected_mousedown";
	private static var DEFAULT_FRAME_SELECTED_NORMAL = "selected_normal";
	private static var DEFAULT_FRAME_SELECTED_ROLLOVER = "selected_rollover";
	private static var DEFAULT_FRAME_SELECTED_MOUSEDOWN = "selected_mousedown";
		
	private var mFrameDeselectedNormal:String = DEFAULT_FRAME_DESELECTED_NORMAL;
	private var mFrameDeselectedRollOver:String = DEFAULT_FRAME_DESELECTED_ROLLOVER;
	private var mFrameDeselectedMouseDown:String = DEFAULT_FRAME_DESELECTED_MOUSEDOWN;
	private var mFrameSelectedNormal:String = DEFAULT_FRAME_SELECTED_NORMAL;
	private var mFrameSelectedRollOver:String = DEFAULT_FRAME_SELECTED_ROLLOVER;
	private var mFrameSelectedMouseDown:String = DEFAULT_FRAME_SELECTED_MOUSEDOWN;
	
	private var mRollOutEvent:String;
	private var mRollOverEvent:String;
	private var mChangeEvent:String;

	private var mMask:MovieClip;
	private var mLabel:TextField;
	private var mEnabled:Boolean;
	private var mSelected:Boolean;
	private var mLabelText:String;
	private var mCanDisableSelf:Boolean;
	private var mGroup:Array;

	public function RadioButton () {

		super();
		init();
	}

	public function setDisableSelf ( inValue:Boolean ) : Void {

		mCanDisableSelf = inValue;
	}

	public function getDisableSelf () : Boolean {

		return mCanDisableSelf;
	}

	/**
	The label text.
	*/
	public function set label ( inLabel:String ) {

		if (inLabel != undefined && inLabel != "") {

			// create label mask
			if (mMask == undefined) {
				createLabel();
			}

			// set label text
			mLabelText = inLabel;
			mLabel.autoSize = true;
			mLabel.text = inLabel;

			// resize mask
			mMask._height = Math.floor(_height);
			mMask._width = Math.floor(_width);
		}
	}

	/**
	Gets the enabled state (enabled or disabled).
	@return True: the button is enabled; false: the button is disabled.
	*/
	public function getEnabled () : Boolean {

		return mEnabled;
	}

	/**
	Sets the enabled state (enabled or disabled).
	@param inValue: 
	*/
	public function setEnabled ( inValue:Boolean ) : Void {
		
		mEnabled = (inValue != undefined) ? inValue : true;
		useHandCursor = mEnabled;
	}

	/**
	Gets the selected state (selected or deselected).
	@return True: the button is selected; false: the button is deselected.
	*/
	public function getSelected () : Boolean {

		return mSelected;
	}

	/**
	Sets the selected state (selected or deselected).
	@param inValue: (optional) the selected state: true = selected, false = deselected (default)
	*/
	public function setSelected ( inValue:Boolean ) : Void {

		// set flag
		mSelected = (inValue != undefined) ? inValue : false;

		// change appearance
		if (mSelected) {

			gotoAndStop(mFrameSelectedNormal);
			// refresh text
			label = mLabelText;

		} else {

			setFrame(mFrameDeselectedNormal);
		}
	}
	
	// EVENTS
	
	public function onRollOver () : Void {
		
		super.onRollOver();

		if (mEnabled) {
			if (mSelected) {
				setFrame(mFrameSelectedRollOver);
			} else {
				setFrame(mFrameDeselectedRollOver);
			}
		}
	}

	public function onRollOut () : Void {

		super.onRollOut();

		if (mEnabled) {
			if (mSelected) {
				setFrame(mFrameSelectedNormal);
			} else {
				setFrame(mFrameDeselectedNormal);
			}
		}
	}

	public function onPress () : Void {

		super.onPress();

		if (mEnabled) {
			if (mSelected) {
				setFrame(mFrameSelectedMouseDown);
			} else {
				setFrame(mFrameDeselectedMouseDown);
			}
		}
	}

	/**
	@sends RadioButtonEvent#ON_SELECTED
	*/
	public function onRelease () : Void {
		
		super.onRelease();

		if (mEnabled) {
			if (mSelected && mCanDisableSelf) {
				setFrame(mFrameDeselectedRollOver);
				dispatchEvent(new RadioButtonEvent(RadioButtonEvent.ON_SELECTED, this, false));
			} else {
				setFrame(mFrameSelectedRollOver);
				dispatchEvent(new RadioButtonEvent(RadioButtonEvent.ON_SELECTED, this, true));
			}
		}
	}
	
	// PRIVATE METHODS
	
	private function init () : Void {
		setEnabled(mEnabled);
		setSelected(mSelected);
		tabEnabled = false;
		mCanDisableSelf = false;
	}
	
	/**
	Creates a clickable mask for the label.
	*/
	private function createLabel () : Void {

		// is a mask already present?
		if (mMc.mask_mc == undefined) {
			mMask = mMc.createEmptyMovieClip("mask_mc", 10);
		} else {
			mMask = mMc.mask_mc;
		}
		mLabel = TextField(mMc.label_txt);
		mLabelText = mMc.label_txt.text;

		// create the mask (to make text clickable)
		with(mMask)	{
			lineStyle(0,0x000000,0);
			beginFill(0x000000,0);
			moveTo(0, 0);
			lineTo(10, 0);
			lineTo(10, 10);
			lineTo(0, 10);
			lineTo(0, 0);
			endFill();
		}
		mMask._x = Math.min(mLabel._x, 0);
		mMask._y = Math.min(mLabel._y, 0);
		mEnabled = true;
		setSelected(false);
	}
	
	/**
	Displays a particular state.
	@param inFrame:
	*/
	private function setFrame( inFrame:String ) : Void {

		// jump frame
		gotoAndStop(inFrame);
		// refresh text
		if (mLabelText != undefined && mLabelText != "") {
			label = mLabelText;
		};
	}
}
