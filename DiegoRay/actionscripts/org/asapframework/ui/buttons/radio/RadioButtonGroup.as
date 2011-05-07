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
import org.asapframework.events.Dispatcher;
import org.asapframework.ui.buttons.EventButtonEvent;
import org.asapframework.ui.buttons.radio.IRadioButton;
import org.asapframework.ui.buttons.radio.RadioButton;
import org.asapframework.ui.buttons.radio.RadioButtonEvent;
import org.asapframework.ui.buttons.radio.RadioGroupEvent;
import org.asapframework.util.ArrayUtils;
import org.asapframework.util.debug.Log;


/**
RadioButtonGroup manages a group of RadioButtons.
@usage The following code creates a new RadioButtonGroup and adds three buttons, the first of which is set to selected state.
<code>
var myGroup:RadioButtonGroup = new RadioButtonGroup();
myGroup.addButton(myButton1,true);
myGroup.addButton(myButton2);
myGroup.addButton(myButton3);
</code>
 * @author Martijn de Visser
 */
class org.asapframework.ui.buttons.radio.RadioButtonGroup extends Dispatcher implements org.asapframework.util.forms.validate.IValidate {

	private var mGroup:Array;
	private var mSelection:IRadioButton;

	/**
	Creates a new RadioButtonGroup
	@param inListener : subscribes inListener to events from RadioButtonGroup
	*/
	public function RadioButtonGroup( inListener:Object ) {

		super();

		// add listener?
		if ( inListener != undefined ) {

			addEventListener(RadioGroupEvent.ON_CHANGED, inListener);
		}

		// create empty group
		mGroup = new Array();

		// set selection
		mSelection = undefined;
	}

	/**
	Adds a button to the RadioButtonGroup
	@param inButton, button to add
	@param inSelected : (optional) set to true to add and also set the button to selected state
	*/
	public function addButton ( inButton:RadioButton, inSelected:Boolean ) : Void {

		if (inButton != undefined) {

			if (ArrayUtils.findElement(mGroup, inButton) != -1) {

				Log.info("addButton : button '"+inButton+"' already in group, not added.", toString());

			} else {

				// add to group
				mGroup.push(inButton);

				// listen to events
				inButton.addEventListener(RadioButtonEvent.ON_SELECTED, this);

				if (inSelected) {

					select(inButton,true);
				}
			}

		} else { return; }
	}

	/**
	Removes a button fron the RadioButtonGroup
	@param inButton : button to remove
	*/
	public function removeButton ( inButton:RadioButton ) : Void {

		if (inButton != undefined) {
			if (!ArrayUtils.removeElement(mGroup, inButton)) {
				Log.info("RadioButtonGroup : button '"+inButton+"' not in group, cannot remove.");
			} else {
				// stop listening to events
				inButton.removeEventListener(EventButtonEvent.ON_RELEASE, this);
			}

		} else { return; }
	}

	/**
	Used to (de)select a RadioButton
	@param Reference to the button to select
	@sends RadioGroupEvent#ON_CHANGED
	*/
	public function select ( inButton:IRadioButton, inInternal:Boolean ) : Void {

		if (inInternal == undefined) { inInternal = true; };

		// was clicked button already selected?
		if (inButton.getSelected()) {

			// yes, was already selected, can this button deselect itself?
			if (inButton.getDisableSelf()) {

				// yes, deselect it
				inButton.setSelected(false);

				// clear current selection
				mSelection = undefined;
			}

		} else {

			// no, wasn't selected, select it
			inButton.setSelected(true);

			// did we have a previous selection?
			if (mSelection != undefined) {

				// yes, deselect current selection
				mSelection.setSelected(false);
			}

			// store new selection
			mSelection = inButton;
			var index:Number = getIndex(mSelection);
			
			// broadcast event
			if (!inInternal) {
				
				dispatchEvent( new RadioGroupEvent(RadioGroupEvent.ON_CHANGED, this, mSelection, index ));
			}
		}
	}
	
	/**
	Selects a button by index.
	*/
	public function setSelectedIndex ( inIndex:Number ) : Void {
		
		select(IRadioButton(mGroup[inIndex]));
	}
	
	/**
	Deselects all radio buttons.
	*/
	public function deselectAll () : Void {
	
		// did we have a previous selection?
		if (mSelection != undefined) {

			// yes, deselect current selection
			mSelection.setSelected(false);
			mSelection = undefined;
		}
	}

	/**
	Removes all RadioButtons from the group.
	*/
	public function clear () : Void {

		// remove listener reference
		for (var i:Number=0; i<mGroup.length; ++i) {

			RadioButton(mGroup[i]).removeEventListener(EventButtonEvent.ON_RELEASE,this);
		}

		// clear group
		mGroup = [];

		// clear selection
		mSelection = undefined;
	}
	
	/**
	@return List of all elements managed by this RadioButtonGroup.
	*/
	public function getElements () : Array {

		return mGroup;
	}
	
	public function toString() : String {
		return ";org.asapframework.ui.buttons.radio.RadioButtonGroup";
	}
	
	// EVENTS

	/**
	Triggered by RadioButtons added to this group.
	*/
	public function onRadioButtonSelected ( e:RadioButtonEvent ) : Void {
		
		var btn:IRadioButton = IRadioButton(e.target);
		select(btn, false);
	}

	// IVALIDATE IMPLEMENTATION

	/**
	@return The currently selected button.
	*/
	public function getValue () : Object {

		// return selected button
		return Object(mSelection);
	}
	
	/**
	@return The index of the button in the group.
	*/
	private function getIndex ( inButton:IRadioButton ) : Number {
		
		var len:Number = mGroup.length;
		for (var i:Number=0; i<len; ++i) {
			
			var mc:IRadioButton = IRadioButton(mGroup[i]);
			if (mc == inButton) return i;
		}
		
		return null;
	}

}
