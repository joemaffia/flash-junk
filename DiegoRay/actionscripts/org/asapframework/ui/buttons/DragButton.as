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

// Adobe classes
//import flash.geom.*;
// Still support Flash 7:
import org.asapframework.util.types.*;

// ASAP classes
import org.asapframework.ui.buttons.DragButtonEvent;
import org.asapframework.ui.EventMovieClip;


/**
A button that can be dragged around.
Assumes the presence of the following frame labels to represent states:
	<ul>
		<li>'normal'</li>
		<li>'rollover'</li>
		<li>'mousedown'</li>
	</ul>
@author Martijn de Visser
@author Arthur Clemens (refactoring)
*/

class org.asapframework.ui.buttons.DragButton extends EventMovieClip {

	private var mDragging:Boolean = false;
	private var mSendMoveEvent:Boolean = false;
	private var mBounds:Rectangle;
	private var mLastPos:Point;
	private var mStartPos:Point;
	
	private static var DEFAULT_FRAME_NORMAL:String = "normal";
	private static var DEFAULT_FRAME_ROLLOVER:String = "rollover";
	private static var DEFAULT_FRAME_MOUSEDOWN:String = "mousedown";
	
	private var mFrameNormal:String = DEFAULT_FRAME_NORMAL;
	private var mFrameRollOver:String = DEFAULT_FRAME_ROLLOVER;
	private var mFrameMouseDown:String = DEFAULT_FRAME_MOUSEDOWN;

	public function DragButton () {

		super();
		
		mLastPos = new Point(mMc._x, mMc._y);
		mStartPos = new Point(mMc._x, mMc._y);
		
		mMc.gotoAndStop(mFrameNormal);
	}

	/**
	Override in subclasses; if you need actions to be taken when the clip is being dragged, implement additional functionality in an overriding method. Performance may be a point as this function is called while the clip moves on each onEnterFrame event.
	*/
	public function onClipDragging () : Void {
	
		// empty by default
	}

	/**
	@sends DragButtonEvent#ON_MOVE - if sendMoveEvent == true
	*/
	private function onUpdatePosition () : Void {

		if (mSendMoveEvent) {
			
			if (mDragging && (mMc._x != mLastPos.x || mMc._y != mLastPos.y)) {
	
				dispatchEvent( new DragButtonEvent(DragButtonEvent.ON_MOVE, this, _name));
			}
		}
		
		// store position
		mLastPos.x = mMc._x;
		mLastPos.y = mMc._y;

		// implement onClipDragging in subclass
		onClipDragging();
	}

	/**
	@sends DragButtonEvent#ON_START
	*/
	public function onPress () : Void {

		if (enabled) {

			gotoAndStop(3);

			// do we need to apply constraints?
			if (mBounds != undefined) {

				mMc.startDrag( false, mBounds.left, mBounds.top, mBounds.right, mBounds.bottom );

			} else {

				mMc.startDrag(false);
			}
			
			// catch onEnterFrame events
			this.onEnterFrame = this.onUpdatePosition;

			dispatchEvent( new DragButtonEvent(DragButtonEvent.ON_START, this, _name));
			mDragging = true;
		}
	}

	/**
	@sends DragButtonEvent#ON_END
	*/
	public function onDragEnd () : Void {

		if (mDragging) {

			mDragging = false;
			mMc.stopDrag();
			
			// stop onEnterFrame events
			this.onEnterFrame = null;
			
			mLastPos.x = mMc._x;
			mLastPos.y = mMc._y;
		}
		dispatchEvent( new DragButtonEvent(DragButtonEvent.ON_END, this, _name));
	}

	public function onMouseUp () : Void {

		if (mMc.hitTest(_parent._xmouse, _parent._ymouse, true)) {

			onDragEnd();
		}
	}
	
	public function onRollOver () : Void {
		
		if (enabled) {
			gotoAndStop(mFrameRollOver);
		}
	}
	
	public function onRollOut () : Void {
		
		if (enabled) {
			gotoAndStop(mFrameNormal);
		}
	}

	public function onRelease () : Void {

		if (enabled) {
			gotoAndStop(mFrameRollOver);
			onDragEnd();
		}
	}

	public function onReleaseOutside () : Void {

		if (enabled) {
			gotoAndStop(mFrameNormal);
			onDragEnd();
		}
	}

	public function get distance () : Point {

		return new Point((mMc._x - mStartPos.x), (mMc._y - mStartPos.y));
	}

	/**
	Sets the bounding rectangle (in pixels) in which the MovieClip may move. Pass a Rectangle with a height of 1 to create a horizontal-only draggable clip.
	@param inBounds: the constraining rectangle in pixels
	*/
	public function setBounds (inBounds:Rectangle) : Void {
	
		mBounds = inBounds;		
		mStartPos.x = mBounds.left;
		mStartPos.y = mBounds.top;
	}
	
	/**
	@return The bounding rectangle (in pixels) in which the MovieClip may move.
	*/
	public function getBounds () : Rectangle {
		return mBounds;
	}
	
	/**
	*	Set to true to receive move events (may be CPU intensive, false by default) 
	*/
	public function set sendMoveEvent ( inValue:Boolean ) {
		
		mSendMoveEvent = inValue;
	}

}
