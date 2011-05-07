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

import org.asapframework.ui.buttons.EventButtonEvent;
import org.asapframework.ui.buttons.EventButton;

/**
Use this class to create buttons that keep on firing {@link EventButtonEvent#ON_RELEASE} events while the mouse is down (for scrollbar buttons, for example).
@author Martijn de Visser
*/

class org.asapframework.ui.buttons.RepeaterButton extends EventButton {

	private static var DEFAULT_FRAME_NORMAL:String = "normal";
	private static var DEFAULT_FRAME_ROLLOVER:String = "rollover";
	private static var DEFAULT_FRAME_MOUSEDOWN:String = "mousedown";
	private static var DEFAULT_WAIT_TIMEOUT:Number = 200;
	private static var DEFAULT_REPEAT_TIMEOUT:Number = 50;
	
	private var mWaitInterval:Number;
	private var mRepeatInterval:Number;
	
	private var mWaitTimeOut:Number = DEFAULT_WAIT_TIMEOUT;
	private var mRepeatTimeOut:Number = DEFAULT_REPEAT_TIMEOUT;
	
	private var mFrameNormal:String = DEFAULT_FRAME_NORMAL;
	private var mFrameRollOver:String = DEFAULT_FRAME_ROLLOVER;
	private var mFrameMouseDown:String = DEFAULT_FRAME_MOUSEDOWN;

	public function RepeaterButton () {

		super();
		mMc.gotoAndStop(mFrameNormal);
	}

	public function onMouseUp () : Void {

		mMc.gotoAndStop(mFrameNormal);
		stopIntervals();
	}

	public function onRelease () : Void {

		super.onRelease();		
		mMc.gotoAndStop(mFrameRollOver);
		stopIntervals();
	}

	public function onReleaseOutside () : Void {

		super.onReleaseOutside();
		mMc.gotoAndStop(mFrameNormal);
		stopIntervals();
	}

	public function onRollOver () : Void {

		super.onRollOver();
		mMc.gotoAndStop(mFrameRollOver);
	}
	
	public function onRollOut () : Void {

		super.onRollOut();
		mMc.gotoAndStop(mFrameNormal);
	}

	public function onPress () : Void {
		super.onPress();
		mMc.gotoAndStop(mFrameMouseDown);
		mWaitInterval = setInterval(this, "onAutoFire", mWaitTimeOut);
	}

	private function onAutoFire () : Void {

		clearInterval(mWaitInterval);
		mRepeatInterval = setInterval(this, "fireEvent", mRepeatTimeOut);
	}
	
	public function toString () : String {
		return ";RepeaterButton: name = " + _name;
	}
	
	/**
	@sends EventButtonEvent#ON_RELEASE
	*/
	private function fireEvent () : Void {
	
		dispatchEvent(new EventButtonEvent(EventButtonEvent.ON_RELEASE, this, _name));
	}


	private function stopIntervals () : Void {

		clearInterval(mWaitInterval);
		clearInterval(mRepeatInterval);
	}
}
