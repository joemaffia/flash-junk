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

import org.asapframework.ui.buttons.EventButton;

/**
DelayButton offers timing control over rollOver and rollOut. This can be useful for navigation menus where a menu item should "remember" its state for a brief moment even when the mouse has moved out of its click region (in UI design this effect is called hysteresis - see also <a href="http://www.mackido.com/Interface/hysteresis.html">time delay in hierarchical menus</a>.

Other uses for DelayButton are (Flash specific) to avoid flickering with buttons that grow in size with roll over, and in intuitive interfaces that require precise time control.

DelayButton has 3 properties that can be set to control timings before and after roll over and roll out:
<ul>
<li>{@link #indelay} : the number of seconds between the mouse having rolled over and the clip performing onRollOver</li>
<li>{@link #outdelay} : the number of seconds between the mouse having rolled out and the clip performing onRollOut</li>
<li>{@link #afterdelay} : the number of seconds a movieclip is momentarily inactive after roll out</li>
</ul>

@use
A hierarchical menu that folds out a submenu will leave the submenu visible for a short time after the mouse has left it. The submenu will have an <code>outdelay</code> of about 0.5 seconds.

If the menu has multiple submenus, each submenu will only pop up after a short delay, to prevent a wild and annoying popping-up effect. The submenu will have a short <code>indelay</code> (of about 0.1 seconds).

A movieclip that expands with roll over will get its hit area wrong - an annoying Flash 'bug'. If you move the mouse on the right spot, a wild firing of onRollOver and onRollOut will occur, resulting in the flickering of the movieclip as if it is not sure in which state it is in. To prevent this, give the button a <code>afterdelay</code> of about 0.5 seconds.
@example
You may need to create a rollover state variable to prevent onRollOut getting called when the button's doRollOver has not yet been called. For example in a DelayButton subclass:
<code>
private static var UP_STATE:Number = 0;
private static var ROLLOVER_STATE:Number = 1;
private var mState:Number = UP_STATE;
//...
public function doRollOver () : Void {
	mState = ROLLOVER_STATE;
	super.doRollOver(); // DelayButton sends an onRollOver to its superclass
}

public function doRollOut () : Void {
	if (mState != ROLLOVER_STATE) {
		return;
	}
	super.doRollOut(); // DelayButton sends an onRollOut to its superclass
	mState = UP_STATE;
}
</code>
@author Arthur Clemens
*/

class org.asapframework.ui.buttons.DelayButton extends EventButton {

	private var mRollOverState:Boolean; /**< Indicates if the button has a rollover, defined by the delay variables. */
	
	// Delay variables
	public var indelay:Number = 0;		/**< Delay before doRollOver action is performed, in seconds. */
	public var outdelay:Number = 0;		/**< (Hysteresis) delay before doRollOut action is performed, in seconds. */
	public var afterdelay:Number = 0; /**< Delay after onRollOut until the button is activated (enabled) again, in seconds. */

	private var mReenabledTime:Number; /**< Set the time from where the button will be active again (in milliseconds); value is calculated. */
	private var mInDelay_ival:Number; /**< Id from setInterval used to call method performDoRollOver. */
	private var mOutDelay_ival:Number; /**< Id from setInterval used to call method performDoRollOut. */
	private var mAfterDelay_ival:Number; /**< Id from setInterval used to call method reenableAfterDelay. */
	
	/**
	Creates a new DelayButton.
	*/
	public function DelayButton () {
		super();
		mRollOverState = false;
	}
	
	/**
	At unload, clears the intervals set with setInterval.
	*/
	public function onUnload () : Void {
		super.onUnload();
		clearIntervals();
	}
	
	/**
	
	*/
	public function toString () : String {
		return ";DelayButton: name = " + _name;
	}
	
	/**
	Implements MovieClip.onRollOver. Do not implement this method yourself; code that should be performed on onRelease should go into {@link #doRollOver}.
	If {@link #indelay} is specified, calling of doRollOver is postponed until after the delay period.
	*/
	public function onRollOver () : Void {
		clearInterval(mOutDelay_ival); // disable calling of performDoRollOut

		if ( !enabled || (getTimer() < mReenabledTime) ) {
			return;
		}
				
		clearInterval(mInDelay_ival);
		
		if (indelay == 0) {
			mRollOverState = true;
			doRollOver();
		} else {
			mInDelay_ival = setInterval(this, "performDoRollOver", indelay * 1000);
		}
	}
	
	/**
	Implements MovieClip.onRollOut. Do not implement this method yourself; code that should be performed on onRelease should go into {@link #doRollOut}.
	If {@link #afterdelay} is specified, the movieclip will be disabled until after delay time. This is useful for out-animations where the hitarea changes shape - the Flash can get trapped in a race condition if a onRollOver event is fired immediately after the onRollOut. Setting {@link #afterdelay} enables the movieclip to finish the out-animation before being enabled/active again.
	If {@link #outdelay} is specified, calling of doRollOut is postponed until after delay time. This effect is also called hysteresis.
	*/
	public function onRollOut () : Void {
		
		clearIntervals();

		if (outdelay == 0) {
			mRollOverState = false;
			doRollOut();
		} else {
			var tempTime:Number = getTimer() + outdelay * 1000;
			if (mReenabledTime < tempTime) {
				mReenabledTime = tempTime;
			}
			mOutDelay_ival = setInterval(this, "performDoRollOut", outdelay * 1000);
		}
	}
	
	
	/**
	Implements MovieClip.onPress. Do not implement this method yourself; code that should be performed on onPress should go into {@link #doPress}.
	*/	
	public function onPress () : Void {
		clearInterval(mInDelay_ival); // do not call doRollOver later on 
		doPress();
	}
	
	/**
	Implements MovieClip.onRelease. Do not implement this method yourself; code that should be performed on onRelease should go into {@link #doRelease}.
	*/
	public function onRelease () : Void {
		clearInterval(mInDelay_ival); // do not call doRollOver later on 
		doRelease();
	}
	
	/**
	Implements MovieClip.onReleaseOutside. Calls {@link #doRollOut} by default.
	*/
	public function onReleaseOutside () : Void {
		doRollOut();
	}
	
	/**
	Called by onRollOver. Empty stub to be implemented by a DelayButton subclass. Calls super.onRollOver.
	@example In a DelayButton subclass:
	<code>
	private function doRollOver () : Void
		super.doRollOver();
		if (!selected) {
			gotoAndStop("over");
		}
	}
	</code>
	*/
	public function doRollOver () : Void {
		super.onRollOver();
	}
	
	/**
	Called by onRollOut. Empty stub to be implemented by a DelayButton subclass. Calls super.onRollOut.
	*/
	public function doRollOut () : Void {
		super.onRollOut();
		if (afterdelay > 0) {
			enabled = false;
			mReenabledTime = getTimer() + afterdelay * 1000;
			mAfterDelay_ival = setInterval(this, "reenableAfterDelay", afterdelay * 1000);
		}
	}
	
	/**
	Called by onPress. Empty stub to be implemented by a DelayButton subclass. Calls super.onPress.
	*/
	public function doPress () : Void {
		super.onPress();
	}
	
	/**
	Called by onRelease. Empty stub to be implemented by a DelayButton subclass. Calls super.onRelease.
	@example In a DelayButton subclass:
	<code>
	private function doRelease () : Void
		super.doRelease();
		if (!selected) {
			selected = true;
			gotoAndStop("selected");
		}
	}
	</code>
	*/
	public function doRelease () : Void {
		super.onRelease();
	}
	
	
	// PRIVATE METHODS
	
	/**
	Clears all intervals created with setInterval.
	*/
	private function clearIntervals () : Void {
		clearInterval(mInDelay_ival);
		clearInterval(mOutDelay_ival);
		clearInterval(mAfterDelay_ival);
	}
	
	/**
	Interval method called from onRollOut. Sets the button enabled to true.
	*/
	private function reenableAfterDelay () : Void {
		clearInterval(mAfterDelay_ival);
		enabled = true;
	}
	
	/**
	Interval method called from onRollOver. Calls {@link #doRollOver}.
	*/
	private function performDoRollOver () : Void {
		clearInterval(mInDelay_ival);
		mRollOverState = true;
		doRollOver();
	}
	
	/**
	Interval method called from onRollOut. Calls {@link #doRollOut}.
	*/
	private function performDoRollOut () : Void {
		clearInterval(mOutDelay_ival);
		mRollOverState = false;
		doRollOut();
	}
}