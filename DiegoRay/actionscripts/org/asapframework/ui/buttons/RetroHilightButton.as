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
If the mouse is moved out of the clip before the timeline has reached the "on" label, the timeline goes in reverse back to the "up" frame.
 */
class org.asapframework.ui.buttons.RetroHilightButton extends EventButton {

	private static var DEFAULT_FRAME_ON:String = "on";
	private static var DEFAULT_FRAME_UP:String = "up";
	private static var DEFAULT_FRAME_OVER:String = "over";
	private static var DEFAULT_FRAME_OUT:String = "out";
	
	private var mFrameOn:String = DEFAULT_FRAME_ON;
	private var mFrameUp:String = DEFAULT_FRAME_UP;
	private var mFrameOver:String = DEFAULT_FRAME_OVER;
	private var mFrameOut:String = DEFAULT_FRAME_OUT;
	
	private var direction : Number;
	private var hilightFrame : Number;
	private var upFrame:Number;

	private var isAnimating : Boolean;
	private var doOutAnimation : Boolean;


	/**
	
	*/
	public function RetroHilightButton() {
		super();
	}

	/**
	
	*/
	public function onLoad () : Void {
		super.onLoad();

		gotoAndStop(mFrameOn);
		hilightFrame = _currentframe;
		gotoAndStop(mFrameUp);
		upFrame = _currentframe;

		gotoAndStop(1);
	}

	/**
	Rollover handler.
	*/
	public function onRollOver () : Void {
		super.onRollOver();
		gotoAndPlay(mFrameOver);

		isAnimating = true;
		direction = 1;
		onEnterFrame = checkAnimation;
	}

	/**
	Rollout handler.
	*/
	public function onRollOut () : Void {
		super.onRollOut();

		if (isAnimating){
			direction = -1;
			doOutAnimation = true;
		} else {
			gotoAndPlay(mFrameOut);
		}
	}
	
	/**
	Stop enterFrame handling.
	*/
	private function stopAnimation () : Void {
		isAnimating = false;
		delete onEnterFrame;
	}

	/**
	Check status of animation on enterFrame.
	*/
	private function checkAnimation () : Void {
		var newFrame:Number = _currentframe + direction;
		if (newFrame == upFrame) {
			isAnimating = false;
			delete onEnterFrame;
			doOutAnimation = false;
		} else if (newFrame == hilightFrame) {
			stopAnimation();

			if (doOutAnimation){
				onRollOut();
			} else {
				stop();
			}
		}
		this.gotoAndStop(newFrame);
	}

	/**
	
	*/
	public function toString() : String {
		return ";ui.RetroHilightButton";
	}
}