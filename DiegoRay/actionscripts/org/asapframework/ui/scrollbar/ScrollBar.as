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

// framework classses
import org.asapframework.ui.buttons.*;
import org.asapframework.ui.scrollbar.*;


/**
ScrollBar class to create scrollbars with. Assumes the presence of 4 other clips:
<ul>
	<li>'scroller_mc' 	DragButton, scrollable handle</li>
	<li>'scrollerBg_mc' MovieClip, background of scrollbar</li>
	<li>'arrowUp_mc'	RepeaterButton, scroll up arrow</li>
	<li>'arrowDown_mc'	RepeaterButton, scroll down arrow</li>
</ul>
@author Martijn de Visser
@todo Support for orientation so horizontal scrollbars are possible as well.
*/

class org.asapframework.ui.scrollbar.ScrollBar extends org.asapframework.ui.EventMovieClip {

	private var mEnabled:Boolean;
	private var mScroller:DragButton;
	private var mScrollerBg:MovieClip;
	private var mArrowUp:RepeaterButton;
	private var mArrowDown:RepeaterButton;
	private var mScrollTarget:IScrollable;

	private var mSnap:Number;
	private var mScrollerHeight:Number;
	private var mOldScrollerHeight:Number;
	private var mVisibleHeight:Number;
	private var mOldVisibleHeight:Number;
	private var mTotalHeight:Number;
	private var mOldTotalHeight:Number;
	
	private static var DEFAULT_MIN_HEIGHT:Number = 10;
	private static var mMinHeight:Number = DEFAULT_MIN_HEIGHT;

	public function ScrollBar () {

		super();
	}

	public function onLoad () : Void {

		// get references
		mScroller = DragButton(mMc.scroller_mc);
		mScrollerBg = MovieClip(mMc.scrollerBg_mc);
		mArrowUp = RepeaterButton(mMc.arrowUp_mc);
		mArrowDown = RepeaterButton(mMc.arrowDown_mc);

		// set default values
		setHeight(mMc._height);

		// set listeners
		mArrowUp.addEventListener(EventButtonEvent.ON_RELEASE, this);
		mArrowDown.addEventListener(EventButtonEvent.ON_RELEASE, this);
		mScroller.addEventListener(DragButtonEvent.ON_MOVE, this);
		mScroller.sendMoveEvent = true;
	}

	/**
	Updates the scroller.
	*/
	public function update () : Void {

		// store previous values
		mOldTotalHeight = mTotalHeight;

		// get latest target sizes
		mVisibleHeight = mScrollTarget.getVisibleHeight();
		mTotalHeight = mScrollTarget.getTotalHeight();

		// has the scroller height been changed?
		// if so, we need a new lay-out
		if (mScrollerHeight != mOldScrollerHeight) {

			if (mScrollerHeight == undefined) { 
				mScrollerHeight = mMc._height;
			}
			mArrowDown._y = Math.floor(mScrollerHeight - mArrowDown._height);
			mScrollerBg._y = Math.floor(mArrowUp._height);
			mScrollerBg._height = Math.floor(mScrollerHeight - (mArrowUp._height + mArrowDown._height));
			mOldScrollerHeight = mScrollerHeight;
		}

		// has the target height been changed?
		// if so, we need to adjust the size of the scroller
		if ((mVisibleHeight != mOldVisibleHeight) || (mOldTotalHeight != mTotalHeight)) {

			// is all content already visible? then hide scroller
			if (mTotalHeight <= mVisibleHeight) {

				mScroller._visible = false;
				mArrowUp.enabled = false;
				mArrowDown.enabled = false;

			} else {

				var scrollerLength:Number = Math.floor((mVisibleHeight / mTotalHeight) * mScrollerBg._height);
				
				mScroller._height = (scrollerLength < mMinHeight) ? mMinHeight : scrollerLength;
				var bounds:Rectangle = new Rectangle(
					mScrollerBg._x,
					mScrollerBg._y,
					0,
					mScrollerBg._height - mScroller._height);
				mScroller.setBounds(bounds);
				
				mScroller._y = bounds.top;
				
				mOldVisibleHeight = mVisibleHeight;

				mScroller._visible = true;
				mArrowUp.enabled = true;
				mArrowDown.enabled = true;
			}
		}
	}
	
	/**
	Programmatically scrolls the scrollbar.
	@sends ScrollEvent#ON_SCROLL_CONTENT
	*/
	public function scroll ( inDirection:Number ) : Void {		

		// calculate if new position is within bounds
		
		var newContentPos:Number = mScrollTarget.getScrollPosition() - mScrollTarget.getStepSize() * inDirection;
				
		var curScroll:Number = newContentPos / (mVisibleHeight - mTotalHeight);
		// calculate new position of content clip
		var maxScroll:Number = mVisibleHeight - mTotalHeight;

		var newPos:Number = Math.round(curScroll * maxScroll);
		if (newPos < maxScroll) {
			newPos = maxScroll;
		}
		if (newPos > 0) {
			newPos = 0;
		}
		mScrollTarget.scrollTo(newPos);
		alignScroller();
		
		dispatchEvent( new ScrollEvent(ScrollEvent.ON_SCROLL_CONTENT, this, inDirection));
	}

	/**
	Aligns the scroller to the position of the content
	*/
	public function alignScroller () : Void {
		// calculate new position of scroller clip
		var maxScroll:Number = mScrollerBg._height - mScroller._height;
		var curScroll:Number = mScrollTarget.getScrollPosition() / (mVisibleHeight - mTotalHeight);
		var newPos:Number = -Math.round(curScroll * maxScroll);
		mScroller._y = mScrollerBg._y - newPos;
	}

	/**
	The target clip to scroll. This target should implement the IScrollable interface. The target will automatically be added to the listener queue and receive the 'onScroll' event.
	@param inScrollTarget
	*/
	public function setTarget ( inScrollTarget:IScrollable ) : Void {

		// remove current listener if present
		if (mScrollTarget != undefined) {
			removeEventListener(ScrollEvent.ON_SCROLL_CONTENT, mScrollTarget);
		}

		// set new target
		mScrollTarget = inScrollTarget;
		mOldVisibleHeight = mVisibleHeight;

		// set new listener
		addEventListener(ScrollEvent.ON_SCROLL_CONTENT, mScrollTarget);

		// update scrollbar
		update();
	}
	
	/**
	@deprecated: Use {@link #setTarget}.
	*/
	public function set target ( inScrollTarget:IScrollable ) : Void {
		setTarget(inScrollTarget);
	}
	
	/**
	The total height of the scrollbar in pixels.
	*/
	public function setHeight ( inHeight:Number ) : Void {
		mOldScrollerHeight = mScrollerHeight;
		mScrollerHeight = inHeight;
		update();
	}

	/**
	@deprecated: Use {@link #setHeight}.
	*/
	public function set height ( inHeight:Number ) : Void {
		setHeight(inHeight);
	}

	/**
	The number of pixels to snap to.
	*/
	public function set snapping ( inValue:Number ) {

		mSnap = inValue;
	}

	/**
	The enabled state of ScrollBar.
	*/
	public function get enabled () : Boolean {

		return mEnabled;
	}
	public function set enabled ( inValue:Boolean ) {

		mEnabled = inValue;
		mScroller.enabled = inValue;
		mArrowUp.enabled = inValue;
		mArrowDown.enabled = inValue;
	}
	
	// EVENTS
	
	/**
	Triggered by scroller.
	*/
	public function onDragMove ( e:DragButtonEvent ) : Void {

		alignContent();
	}

	/**
	Triggered by arrows.
	*/
	public function onEventButtonRelease ( e:EventButtonEvent ) : Void {

		var dir:Number = (e.buttonName == "arrowDown_mc")? 1 : -1;
		scroll(dir);
	}
	
	// PRIVATE METHODS
	
	/**
	Aligns the content to the position of the scroller.
	*/
	private function alignContent () : Void {

		// calculate new position of content clip
		var maxScroll:Number = mVisibleHeight - mTotalHeight;
		var curScroll:Number = mScroller.distance.y / (mScrollerBg._height - mScroller._height);
		var newPos:Number = Math.round(curScroll * maxScroll);

		if (newPos < maxScroll) { newPos = maxScroll; };
		if (newPos > 0) {
			newPos = 0;
		}

		// do we need to snap?
		if (mSnap != undefined) {
			// yes, scroll modulo snapfactor
			mScrollTarget.scrollTo(-((newPos - (newPos % mSnap)) / mSnap));
		} else {
			// no, just scroll...
			mScrollTarget.scrollTo(newPos);
		}
	}
	
	/**
	Is this method used?
	*/
	private function getPos ( inDirection:Number ) : Number {
		
		var dir:Number = (inDirection == undefined)? 1 : inDirection;
		var maxScroll:Number = -(mVisibleHeight - mTotalHeight);
		var newPos:Number;

		// update position of scrolltarget and scroller
		if (mSnap != undefined) {

			// yes, scroll times snapfactor
			newPos = -(dir * mSnap);

		} else {

			// no, just scroll...
			newPos = -newPos;
		}

		if (newPos < maxScroll) {
			newPos = maxScroll;
		}
		if (newPos > 0)  {
			newPos = 0;
		}
		
		return newPos;
	}
}
