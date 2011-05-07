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
import org.asapframework.management.focus.FocusEvent;
import org.asapframework.management.focus.IFocus;
import org.asapframework.util.ArrayUtils;
import org.asapframework.util.debug.Log;
import org.asapframework.util.FrameDelay;

/**
@author Martijn de Visser
@description Class to manage focus between various UI elements, without the need of MM's focus manager (which requires elements to be derived from UIComponent class). Listens to TAB key for forward navigation and SHIFT-TAB for backward navigation.
@sends org.asapframework.management.focus.FocusEvent#ON_CHANGE_FOCUS Triggered when the focus of one of the registered elements changes.
@usage You may need to add the 'SeamlessTabbing' parameter to the {@code <object>} tag. From Macromedia: (http://www.macromedia.com/support/documentation/en/flashplayer/7/releasenotes.html#Fixes) The default value is true; set this parameter to false to disable "seamless tabbing", which allows users to use the Tab key to move keyboard focus out of a Flash movie and into the surrounding HTML (or the browser, if there is nothing focusable in the HTML following the Flash movie). ActiveX Flash Player has supported seamless tabbing since version 7.0.14.0.
*/
class org.asapframework.management.focus.FocusManager extends Dispatcher {

	private var mFocusIndex:Number;
	private var mFocusList:Array;

	/**
	Constructor. IMPORTANT: when using FocusManager in a MovieClip, the manager will remain in memory (and active) when the clip is removed (due to listening to Key object). Use {@link #kill} to remove the listener.
	@param listener object (optional) which will receive events.	
	@usage
	<code>
	var myFocus:FocusManager = new FocusManager();
	myFocus.addEventListener(FocusEvent.ON_CHANGE_FOCUS, EventDelegate.create(this, onChangeFocus));
	</code>

	The following code makes the object that instantiates the FocusManager the default listener. It will receive the onChangeFocus event.
	@see org.asapframework.management.focus.FocusEvent 
	for the actual name of that event.
	<code>
	var myFocus:FocusManager = new FocusManager(this);
	</code>
	*/
	public function FocusManager ( inListener:Object ) {

		super();
		clear();
		
		// listen to TAB key
		Key.addListener(this);

		// if a listener was specified, add it
		if (inListener != undefined) {

			addEventListener(FocusEvent.ON_CHANGE_FOCUS, inListener);
		}
	}

	/**
	*	Clears list of focus elements
	*/
	public function clear () : Void {
		
		mFocusIndex = -1;
		mFocusList = new Array();
	}

	/**
	Sets the focus to a specific element.
	@param inElement: Must implement the {@link org.asapframework.management.focus.IFocus} interface.
	@usage
	<code>
	var formFocus:FocusManager = new FocusManager();
	formFocus.addElement(to_name, 0);
	formFocus.addElement(to_email, 1);
	formFocus.setFocus(to_name);
	</code>
	*/
	public function setFocus ( inElement:IFocus ) : Void {

		// does element exist?
		var idx:Number = ArrayUtils.findElement(mFocusList,inElement);

		// element ok
		if (idx != -1) {

			var f:FrameDelay = new FrameDelay(this, changeFocus, 1, [mFocusIndex,idx]);
		}
	}

	/**
	Set the TAB index for an interface element.
	@param inElement: Must implement the {@link org.asapframework.management.focus.IFocus} interface.
	@param inPosition: zero-based, optional. If ommitted, it will be added to the end of the list. If an element was already found at the position specifed, it will be inserted.
	@return Boolean indicating if addition was successfull.
	@usage
	<code>
	formFocus.addElement(to_name, 0);
	formFocus.addElement(to_email, 1);
	formFocus.addElement(to_city, 2);
	</code>
	*/
	public function addElement ( inElement:IFocus, inPosition:Number ) : Boolean {

		// element defined?
		if (inElement != undefined) {

			// not already present in list?
			if (ArrayUtils.findElement(mFocusList, inElement) == -1) {

				// was position specified?
				if (inPosition != undefined) {

					// yes, insert element
					ArrayUtils.insertElementAt(mFocusList, inPosition, inElement);

				} else {

					// no, just add element
					mFocusList.push(inElement);
				}

				return true;

			} else {

				return false;
			}

		} else {

			Log.warn("addElement: No element specified for addition", toString());
			return false;
		}
	}

	/**
	Listens to SHIFT / TAB key.
	*/
	public function onKeyUp () : Void {

		if (Key.getCode() == Key.TAB) {

			if (Key.isDown(Key.SHIFT)) {

				prevFocus();

			} else {

				nextFocus();
			}
		}
	}

	/**
	Sets focus to next item in list.
	*/
	private function nextFocus () : Void {

		// has one of our elements focus?
		var idx:Number = checkFocus();
		if (idx != -1) {

			// store previous focus
			var prev:Number = idx;

			// update
			idx++;

			// constrain to array bounds
			if (idx > mFocusList.length-1) { idx = 0; };

			changeFocus(prev,idx);

		} else {

			mFocusIndex = -1;
		}
	}

	/**
	Sets focus to previous item in list.
	*/
	private function prevFocus () : Void {

		// has one of our elements focus?
		var idx:Number = checkFocus();
		if (idx != -1) {

			// store previous focus
			var prev:Number = idx;

			// update
			idx--;

			// constrain to array bounds
			if (idx < 0) { idx = mFocusList.length-1; };

			changeFocus(prev,idx);

		} else {

			mFocusIndex = -1;
		}
	}

	/**
	Changes the focus the 'index' passed
	@sends FocusEvent#ON_CHANGE_FOCUS
	*/
	private function changeFocus ( inPrevFocus:Number, inNewFocus:Number ) : Void {

		// store new focus
		mFocusIndex = inNewFocus;

		// yes, change focus
		IFocus(mFocusList[mFocusIndex]).setFocus();

		// dispatch onChangeFocus event
		dispatchEvent(new FocusEvent(FocusEvent.ON_CHANGE_FOCUS, this, mFocusList[inPrevFocus], mFocusList[mFocusIndex]));
	}

	/**
	Checks if any of our elements has focus and returns its index
	*/
	private function checkFocus () : Number {

		var idx:Number = -1;
		var len:Number = mFocusList.length;
		for (var i:Number=0; i<len; ++i) {

			if (IFocus(mFocusList[i]).hasFocus()) {

				idx = i;
				break;
			}
		}

		return idx;
	}

	/**
	Kills the link to the Key object so the FocusManager can be removed by garbage collection. Best used in onUnload event of MC where FocusManager is instantiated in.
	*/
	public function kill () : Void {

		Key.removeListener(this);
	}
	
	/**
	 * @return List of all elements managed by this FocusManager
	 */
	public function getElements () : Array {

		return mFocusList;
	}
	
	public function toString() : String {
		return ";org.asapframework.management.focus.FocusManager";
	}
}