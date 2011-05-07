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
import org.asapframework.ui.combobox.IComboBoxItem;
import org.asapframework.ui.combobox.ComboBoxItemEvent;
import org.asapframework.ui.EventMovieClip;

class org.asapframework.ui.combobox.ComboBoxItem extends EventMovieClip implements IComboBoxItem {

	private var mData:Object;
	private var mLabel:TextField;
	private var mLabelText:String;

	public function ComboBoxItem () {

		super();

		mData = new Object();
		mLabelText = "";
		mLabel = TextField(mMc.label_txt);
		mLabel.html = true;
	}
	
	public function onRollOver () : Void {
	
		gotoAndStop(2);
		setLabel(mLabelText);
	}
	
	public function onRollOut () : Void {
	
		gotoAndStop(1);
		setLabel(mLabelText);
	}

	public function onPress () : Void {
	
		gotoAndStop(3);
		setLabel(mLabelText);
	}

	/**
	@sends ComboBoxItemEvent#ON_ITEM_CLICKED
	*/
	public function onRelease () : Void {

		if (enabled) {
			gotoAndStop(2);
			dispatchEvent( new ComboBoxItemEvent(ComboBoxItemEvent.ON_ITEM_CLICKED, this, _name));
		}
	}
	
	public function onReleaseOutside () : Void {
	
		gotoAndStop(1);
		setLabel(mLabelText);
	}

	public function setLabel ( inLabel:String ) : Void {

		// set label text
		mLabelText = inLabel;
		mLabel.htmlText = mLabelText;
		mLabel.multiline = false;
		mLabel.wordWrap = false;
		mLabel.autoSize = false;
	}

	public function getLabel () : String {

		return mLabel.text;
	}

	public function setData ( inData:Object ) : Void {

		mData = inData;
	}

	public function getData () : Object {

		return mData;
	}
}
