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
import org.asapframework.ui.slider.SliderEvent;
import org.asapframework.ui.buttons.DragButton;


/**
A class to create a basic slider with, should be attached to slider knob MovieClip. 
Slider sends events on dragging and releasing the slider knob, with values between 0 and 100 percent.
@author Martijn de Visser
@author Arthur Clemens (refactoring)
@use
The knob movieclip <code>slider_knob_vertical_mc</code> is set to class <code>org.asapframework.ui.slider.Slider</code>. The bar movieclip <code>slider_bar_vertical_mc</code> is set to <code>org.asapframework.ui.buttons.EventButton</code>.
<code>
//import flash.geom.*;
// Still support Flash 7:
import org.asapframework.util.types.*;

import org.asapframework.ui.slider.*;
import org.asapframework.ui.buttons.EventButtonEvent;
import org.asapframework.util.RectangleUtils;
import org.asapframework.events.EventDelegate;

// slider bar
mSliderBar = timeline.slider_bar_vertical_mc;
// react on clicks in the bar
mSliderBar.addEventListener(EventButtonEvent.ON_RELEASE, EventDelegate.create(this, handleBarClick));

// slider
mSlider = timeline.slider_knob_vertical_mc;
// at 0 percent, the knob is placed at the top
mSlider.setDirection(Slider.DESCENDING);
// set the knob bounds to the slider bar bounds
var bounds:Rectangle = RectangleUtils.boundsOfMovieClip(mSliderBar);
// lock to the center of the bar
RectangleUtils.flattenWidth(bounds);
mSlider.setBounds(bounds);		
// update only on slide end
mSlider.addEventListener(SliderEvent.ON_SLIDE_DONE, EventDelegate.create(this, handleSliderSlideDone));
</code>
*/

class org.asapframework.ui.slider.Slider extends DragButton {
	
	public static var ASCENDING:Number = 1; /**< Top or left is max value. */
	public static var DESCENDING:Number = -1; /**< Bottom or right is max value. */
	
	private static var HORIZONTAL:String = "HORIZONTAL";
	private static var VERTICAL:String = "VERTICAL";
	
	private var mOrientation:String = VERTICAL; /**< Set automatically when {@link #setBounds} is called. */
	private var mDirection:Number = DESCENDING;

	private var mBounds:Rectangle; /**< The bounding rectangle that constrains the slider knob movements, in Stage pixels. */
	private var mCurrentPos:Point; /** The current position of the Slider knob. */
	private var mPercentage:Number;
	
	/**
	Creates a new Slider.
	*/
	public function Slider () {
	
		super();
		mCurrentPos = new Point(this._x, this._y);
		mPercentage = 0;
	}
	
	/**
	Sets the direction of the Slider.
	@param inDirection : either {@link #ASCENDING} or {@link #DESCENDING}
	*/
	public function setDirection (inDirection:Number) : Void {
		mDirection = inDirection;	
	}
	
	/**
	Gets the direction of the Slider.
	@return A Number value; either {@link #ASCENDING} or {@link #DESCENDING}.
	*/
	public function getDirection () : Number {
		return mDirection;
	}
	
	/**
	Sets the percentage value of the Slider.
	@param inPercentage : the percentage value (from 0 to 100)
	*/
	public function setValue (inPercentage:Number) : Void {

		if (inPercentage == undefined) {
			return;
		}
		var x:Number, y:Number;

		if (mOrientation == HORIZONTAL) {	
			if (mDirection == ASCENDING) {
				x = mBounds.left + mBounds.width * inPercentage * .01;
			}
			if (mDirection == DESCENDING) {
				x = mBounds.right - mBounds.width * inPercentage * .01;
			}
		}
		if (mOrientation == VERTICAL) {
			if (mDirection == ASCENDING) {
				y = mBounds.bottom - mBounds.height * inPercentage * .01;
			}
			if (mDirection == DESCENDING) {
				y = mBounds.top + mBounds.height * inPercentage * .01;
			}
		}
		if (x == undefined) x = _x;
		if (y == undefined) y = _y;

		updatePosition(x, y);
		updateCurrentPos(x, y);
		updatePercentage(inPercentage);
	}
	
	/**
	Sets the position of the Slider in pixels relative to the Slider; a position exactly at the top of the Slider will be 0; a position exactly at the bottom of the Slider will be the height of the Slider bounds.
	The position will be translated to a percentage value dependent on the orientation and direction of the Slider.
	@param inPixelPosition : the position of the Slider in pixels
	*/
	public function setPosition (inPixelPosition:Number) : Void {

		var percentage:Number;
		var relPos:Number;
		if (mOrientation == HORIZONTAL) {	
			if (mDirection == ASCENDING) {
				relPos = inPixelPosition;
				percentage = 100 * (relPos / mBounds.width);
			}
			if (mDirection == DESCENDING) {
				relPos = mBounds.width - inPixelPosition;
				percentage = 100 * (relPos / mBounds.width);
			}
		}
		if (mOrientation == VERTICAL) {
			if (mDirection == ASCENDING) {
				relPos = mBounds.height - inPixelPosition;
				percentage = 100 * (relPos / mBounds.height);
			}
			if (mDirection == DESCENDING) {
				relPos = inPixelPosition;;
				percentage = 100 * (relPos / mBounds.height);
			}
		}
		setValue(percentage);
		sendEvent(SliderEvent.ON_SLIDE_DONE);
	}
		
	/**
	The current percentage value of the slider.
	@return A Number between 0 and 100.
	*/
	public function getValue () : Number {
		var val:Number = 0;	
		if (mOrientation == HORIZONTAL) {		
			var dx:Number = 0;
			if (mDirection == ASCENDING) {
				dx = _x - mBounds.left;
			}
			if (mDirection == DESCENDING) {
				dx = mBounds.right - _x;
			}
			
			val = (dx / mBounds.width) * 100;			
		}
		if (mOrientation == VERTICAL) {
			var dy:Number = 0;
			if (mDirection == ASCENDING) {
				dy = mBounds.bottom - _y;
			}
			if (mDirection == DESCENDING) {
				dy = _y - mBounds.top;
			}
			val = (dy / mBounds.height) * 100;
		}
		return val;
	}
	
	/**
	Sets the constraining rectangle the slider moves within.
	@param inBounds : specify a Rectangle with the same 'y' value for both ends to create a horizontal slider; use a Rectangle with the same 'x' values for a vertical slider
	*/
	public function setBounds (inBounds:Rectangle) : Void {
		
		// determine orientation		
		if (inBounds.height >= inBounds.width) {
			mOrientation = VERTICAL;
		}
		if (inBounds.width > inBounds.height) {
			mOrientation = HORIZONTAL;
		}
		mBounds = inBounds;
		
	}
	
	/**
	Updates the position of the Slider and sends an ON_SLIDE_DONE event.
	@sends SliderEvent#ON_SLIDE_DONE
	*/
	public function update () : Void {

		updateCurrentPos();
		updatePercentage();
		sendEvent(SliderEvent.ON_SLIDE_DONE);
	}
	
	public function toString () : String {
		return "org.asapframework.ui.slider.Slider";
	}
	
	// PRIVATE METHODS
	
	/**
	Updates the _x or _y position - dependent on the Slider orientation.
	@param inPercentage : the relative position to move the Slider to; the _x / _y positions are calculated from the percentage value
	*/
	private function updatePosition (inX:Number, inY:Number) : Void {
		_x = inX;
		_y = inY;
	}
	
	/**
	Calculates the min and max values before sending event <code>inEventName</code>.
	@param inEventName : either {@link SliderEvent#ON_SLIDE} or {@link SliderEvent#ON_SLIDE_DONE}
	*/
	private function sendEvent (inEventName:String) : Void {
		if (mOrientation == HORIZONTAL) {
			var min:Number, max:Number;
			if (mDirection == ASCENDING) {
				min = mBounds.left;
				max = mBounds.right;
			}
			if (mDirection == DESCENDING) {
				min = mBounds.right;
				max = mBounds.left;
			}
			dispatchEvent( new SliderEvent(inEventName, this, min, mCurrentPos.x, max));
		}
		if (mOrientation == VERTICAL) {
			var min:Number, max:Number;
			if (mDirection == ASCENDING) {
				min = mBounds.bottom;
				max = mBounds.top;
			}
			if (mDirection == DESCENDING) {
				min = mBounds.top;
				max = mBounds.bottom;
			}
			dispatchEvent( new SliderEvent(inEventName, this, min, mCurrentPos.y, max));
		}
	}
	
	/**
	
	*/
	private function updateCurrentPos (inX:Number, inY:Number) : Void {
		mCurrentPos.x = (inX != undefined) ? inX : _x;
		mCurrentPos.y = (inY != undefined) ? inY : _y;
	}
	
	/**
	
	*/
	private function updatePercentage (inPercentage:Number) : Void {
		
		if (inPercentage != undefined) {
			mPercentage = inPercentage;
			return;
		}
		var value:Number;
		if (mOrientation == HORIZONTAL) {
			var min:Number, max:Number;
			if (mDirection == ASCENDING) {
				min = mBounds.left;
				max = mBounds.right;
			}
			if (mDirection == DESCENDING) {
				min = mBounds.right;
				max = mBounds.left;
			}
			value = mCurrentPos.x;
		}
		if (mOrientation == VERTICAL) {
			var min:Number, max:Number;
			if (mDirection == ASCENDING) {
				min = mBounds.bottom;
				max = mBounds.top;
			}
			if (mDirection == DESCENDING) {
				min = mBounds.top;
				max = mBounds.bottom;
			}
			value = mCurrentPos.y;
		}
		mPercentage = (value - min) / (max - min) * 100;
	}
	
	
	// EVENTS
	
	/**
	Called while dragging.
	@sends SliderEvent#ON_SLIDE - if position changes
	*/
	private function onClipDragging () : Void {
	
		var oldPercentage:Number = mPercentage;
		updateCurrentPos();
		updatePercentage();
		if (mPercentage != oldPercentage) {
			sendEvent(SliderEvent.ON_SLIDE);
		}
	}
	
	/**
	Called when the dragging is ended.
	@sends SliderEvent#ON_SLIDE_DONE
	*/
	private function onDragEnd () : Void {

		super.onDragEnd();
		
		updatePercentage();
		sendEvent(SliderEvent.ON_SLIDE_DONE);
	}
	
}