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
import org.asapframework.management.movie.MovieManager;
import org.asapframework.management.movie.LocalController;
import org.asapframework.ui.buttons.EventButtonEvent;

/**
Default button, will automatically make the nearest {@link org.asapframework.management.movie.LocalController LocalController} listen to its events. Unregisters with LocalController on unload.
@author Stephan Bezoen
*/
class org.asapframework.ui.buttons.EventButton extends org.asapframework.ui.EventMovieClip {
	
	private var hitArea_mc:MovieClip;
	private var mController:LocalController = null;
	private var mSendEventOnRoll:Boolean = false;
	private var mSendEventOnPress:Boolean = false;

	/**
	
	*/
	public function EventButton () {
		super();
	}

	/**
	
	*/
	public function setSendEventOnRoll (inSend:Boolean) : Void {
		mSendEventOnRoll = inSend;
	}

	/**
	
	*/
	public function setSendEventOnPress (inSend:Boolean) : Void {
		mSendEventOnPress = inSend;
	}

	/**
	
	*/
	public function toString () : String {
		return ";EventButton: name = " + _name;
	}
	
	// EVENTS
	
		/**
	@sends EventButtonEvent#ON_ROLLOVER
	*/
	public function onRollOver () : Void {
		
		if (mSendEventOnRoll && enabled) {
			dispatchEvent(new EventButtonEvent(EventButtonEvent.ON_ROLLOVER, this, _name));
		}
	}

	public function onDragOver () : Void {
		onRollOver();
	}

	/**
	@sends EventButtonEvent#ON_ROLLOUT
	*/
	public function onRollOut () : Void {
		if (mSendEventOnRoll && enabled) {
			dispatchEvent(new EventButtonEvent(EventButtonEvent.ON_ROLLOUT, this, _name));
		}
	}

	public function onDragOut () : Void {
		onRollOut();
	}

	/**
	@sends EventButtonEvent#ON_PRESS
	*/
	public function onPress () : Void {
		if (mSendEventOnPress) {
			dispatchEvent(new EventButtonEvent(EventButtonEvent.ON_PRESS, this, _name));
		}
	}

	/**
	@sends EventButtonEvent#ON_RELEASE
	*/
	public function onRelease () : Void {
		dispatchEvent(new EventButtonEvent(EventButtonEvent.ON_RELEASE, this, _name));
	}

	public function onReleaseOutside () : Void {
		//
	}

	// PRIVATE METHODS
	
	/**
	
	*/
	private function onLoad () : Void {
		mController = MovieManager.getInstance().getNearestLocalController(this);

		if (mController != null) {
			addEventListener(EventButtonEvent.ON_ROLLOVER, mController);
			addEventListener(EventButtonEvent.ON_ROLLOUT, mController);
			addEventListener(EventButtonEvent.ON_PRESS, mController);
			addEventListener(EventButtonEvent.ON_RELEASE, mController);
		}

		hitArea = hitArea_mc;
		hitArea_mc._visible = false;
	}

	/**
	
	*/
	private function onUnload () : Void {
		if (mController != null) {
			removeEventListener(EventButtonEvent.ON_ROLLOVER, mController);
			removeEventListener(EventButtonEvent.ON_ROLLOUT, mController);
			removeEventListener(EventButtonEvent.ON_PRESS, mController);
			removeEventListener(EventButtonEvent.ON_RELEASE, mController);
		}
	}
}
