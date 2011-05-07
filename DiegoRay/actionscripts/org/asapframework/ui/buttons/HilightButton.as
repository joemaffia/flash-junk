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
Class to link to a movieclip to create a button with animated hilight behaviour.

The timeline is expected to have 4 labels: "up", "over", "on" and "out", in that order.
There has to be a "stop();" frame script on the first frame, but on no other frames.
As its base class, {@link EventButton}, a movieclip named "hitArea_mc" can be used to define the hit area of the button.

The default state is the first frame.
On rollover, the timeline advances from the "over" label to the "on" label, and stays there if the mouse is still over the clip.
On rollout, the timeline advances from the "out" label to the end, and stops at the first frame.
If the mouse is moved out of the clip before the timeline has reached the "on" label, the timeline continues all the way until the "on" frame, and then continues further until the end. So a short move over a clip that has this class, results in a full hilight of the clip.

If the clip has an intro for first display, the "up" frame will not be at the first frame. In order for the clip to move back to the "up" label when it has reached the end, an extra frame script must be added in the last frame: "gotoAndStop("up");".
*/
 
class org.asapframework.ui.buttons.HilightButton extends EventButton {
	
	private static var DEFAULT_FRAME_ON:String = "on";
	private static var DEFAULT_FRAME_UP:String = "up";
	private static var DEFAULT_FRAME_OVER:String = "over";
	private static var DEFAULT_FRAME_OUT:String = "out";
	
	private var mFrameOn:String = DEFAULT_FRAME_ON;
	private var mFrameUp:String = DEFAULT_FRAME_UP;
	private var mFrameOver:String = DEFAULT_FRAME_OVER;
	private var mFrameOut:String = DEFAULT_FRAME_OUT;
	
	private var mDoOutAnimation:Boolean = false;
	private var mIsAnimating:Boolean = false;
	private var mHilightFrame:Number;
	private var mForceHilight:Boolean = false;

	public function HilightButton () {
				
		super();
	}

	/**
	
	*/
	private function onLoad () : Void {
		super.onLoad();

		gotoAndStop(mFrameOn);
		mHilightFrame = _currentframe;
	
		if (!mForceHilight) {
			gotoAndStop(1);
		}
	}

	/**
	True if the current frame is the hilight frame
	*/
	public function get isLit () : Boolean {
		return (_currentframe == mHilightFrame);
	}

	/**
	Go directly to the hilight frame.
	*/
	public function hilight () : Void {
		mForceHilight = true;
		gotoAndStop(mFrameOn);
	}

	/**
	Go directly to the "up" frame
	*/
	public function unHilight () : Void {
		gotoAndStop(mFrameUp);
	}

	/**
	Handle rollover event.
	Can also be used to animate to the hilight state.
	*/
	public function onRollOver () : Void {
		super.onRollOver();
		gotoAndPlay(mFrameOver);

		mIsAnimating = true;
		mDoOutAnimation = false;
		onEnterFrame = checkAnimation;
	}

	/**
	Handle rollout event.
	Can also be used to animate out of the hilight state.
	*/
	public function onRollOut () : Void {
		if (mIsAnimating){
			mDoOutAnimation = true;
		} else {
			super.onRollOut();
			gotoAndPlay(mFrameOut);
		}
	}

	/**
	enterFrame handler that checks if animation has to continue
	*/
	private function checkAnimation () : Void {
		if (_currentframe == mHilightFrame) {
			mIsAnimating = false;
			delete onEnterFrame;
			onEnterFrame = null;

			if (mDoOutAnimation){
				onRollOut();
			} else {
				stop();
			}
		}
	}

	/**
	
	*/
	public function toString () : String {
		return ";HilightButton";
	}
}
