/*
Copyright 2005 by the authors of asapframework

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

// macromedia classes
import mx.transitions.easing.Strong;
import mx.transitions.Tween;

import org.asapframework.events.EventDelegate;
import org.asapframework.ui.buttons.EventButton;
import org.asapframework.ui.buttons.EventButtonEvent;
import org.asapframework.ui.combobox.ComboBoxEvent;
import org.asapframework.ui.combobox.ComboBoxItemEvent;
import org.asapframework.ui.scrollbar.IScrollable;
import org.asapframework.ui.scrollbar.ScrollBar;
import org.asapframework.ui.scrollbar.ScrollEvent;
import org.asapframework.util.ArrayUtils;
import org.asapframework.util.forms.validate.IValidate;

/**
	@author Martijn de Visser
	@description ComboBox class to create ComboBox UI elements with.
	@todo Implement removal of items
*/
class org.asapframework.ui.combobox.ComboBox extends org.asapframework.ui.EventMovieClip implements IScrollable, IValidate {

	private var mData:Array;
	private var mItems:Array;

	private var mLabelText:String;
	private var mClipDepth:Number;
	private var mShowDepth:Number;
	private var mItemHeight:Number;
	private var mRowCount:Number;
	private var mMaskAnchor:Number;
	private var mScrollPosition:Number;
	private var mNeedUpdate:Boolean;
	private var mEnabled:Boolean;
	private var mOpen:Boolean;
	private var mItemClass:String;
	private var mDirection:String;
	private var mSelectedIndex:Number;
	private var mTweenDuration:Number;

	private var mTextFormat:TextFormat;

	private var mc:MovieClip;
	private var mArrow:EventButton;
	private var mScrollBar:ScrollBar;
	private var mLabel:TextField;
	private var mListMask:MovieClip;
	private var mListContent:MovieClip;
	private var mListContentBg:MovieClip;

	private var mContentMover:Tween;
	private var mBackgroundMover:Tween;
	private var mScrollBarMover:Tween;

	/**
	*	DropDown class
	*/
	public function ComboBox () {

		super();		
		Mouse.addListener(this);

	}

	private function onLoad () : Void {

		// set references to assets
		mc = MovieClip(this);
		mLabel = TextField(mMc.label_txt);
		mListMask = MovieClip(mMc.mask_mc);
		mListContent = MovieClip(mMc.list_mc);
		mListContentBg = MovieClip(mMc.bg_mc);
		mArrow = EventButton(mMc.arrow_mc);
		mScrollBar = ScrollBar(mMc.scrollbar_mc);

		// set default values
		mData = [];
		mItems = [];
		mClipDepth = mMc.getDepth();
		mShowDepth = 294727;
		itemHeight = 18;
		mSelectedIndex = -1;
		mTweenDuration = 10;
		mScrollPosition = 0;
		rowCount = 5;
		direction = "auto";
		itemClass = "DropDownItem";
		mOpen = false;
		mEnabled = true;
		mNeedUpdate = false;
		tabEnabled = false;
		if (mLabelText != null) mLabel.text = mLabelText;

		// set listeners
		mArrow.addEventListener(EventButtonEvent.ON_RELEASE, EventDelegate.create(this, onButtonClicked));
		addEventListener(ScrollEvent.ON_SCROLL_CONTENT, mScrollBar);
		
		mScrollBar.target = this;
		mScrollBar.snapping = itemHeight;

		mMaskAnchor = mListMask._y;
	}
	
	private function onUnload () : Void {

		// remove listener
		Mouse.removeListener(this);
	}

	/**
	*	Adds an item to the list
	*/
	private function mAdd ( inItem:Object, inPosition:Number ) : Void {

		// did we receive an item wih at least a label?
		if (inItem.label != undefined) {

			var lbl:String = inItem.label;			
			var dat:Object = (inItem.data == undefined)? inItem.label : inItem.data;
			var type:String = "";

			// add the item
			if (inPosition == -1) {

				mData.push({ label:lbl, data:dat });

			} else {

				ArrayUtils.insertElementAt( mData, inPosition, { label:lbl, data:dat } );
			}

			// update attached items?
			if (mOpen) {

				// yes, we're visible so show changes immdiately
				update();

			} else {

				// no, set flag that we need an update (executed at next show() action)
				mNeedUpdate = true;
				
				// update label
				if (mSelectedIndex == -1 || inPosition == 0) {
					updateSelection();
				}
			}
		}
	}

	/**
	*	Opens or closes the dropdown
	*/
	private function action () : Void {

		if (mData.length > 0 && mEnabled) {
			if (mOpen) {
				hide();
			} else {
				show();
			}
		}
	}

	/**
	*	Determine if we need to drop down or drop up
		@returns Boolean, true if we can drop down (preferred direction)
	*/
	private function dropDirection () : Boolean {

		if (mDirection == "auto") {

			// calculate position on stage
			var point:Object = {x:0, y:0};
			mMc.localToGlobal(point);
			var downSpace:Number = Stage.height - point.y;
			var upSpace:Number = point.y;

			if (downSpace > mListContent._height) {
				return true;
			} else {
				return false;
			}

		} else if (mDirection == "down") {

			return true;

		} else if (mDirection == "up") {

			return false;
		}
	}

	/**
	*	Updates visible items and scrollbar
	*/
	private function update() : Void {

		// update all
		updateItems();
		updateContent();
		updateScrollBar();
		updateSelection();
		
		if (mOpen) show(false);

		// set flag
		mNeedUpdate = false;
	}

	/**
	*	Attaches items to show (to max set by rowCount, or deafult 5)
	*/
	private function updateItems () : Void {

		// remove existing items
		for (var i:Number=0; i<mItems.length; ++i) {

			MovieClip(mItems[i]).removeMovieClip();
		}

		// clear item list
		mItems = [];

		var len:Number = (mData.length < rowCount)? mData.length : rowCount;

		// attach items
		for (var i:Number=0; i<len; ++i) {

			// attach item
			var x:Number = 0;
			var y:Number = mItems.length * mItemHeight;
			var item:Object = mListContent.attachMovie( itemClass, "item_" + i, (i+1), { _x:x, _y:y } );

			// let us listen to item
			item.addEventListener(org.asapframework.ui.combobox.ComboBoxItemEvent.ON_ITEM_CLICKED, this);

			// add to list
			mItems.push(item);
		}

		// fit mask to match content
		var h:Number = mItems.length * mItemHeight;
		mListMask._height = h+1;
		mListContentBg._height = h;

		// drop down or drop up?
		placeClips(dropDirection());
	}

	/**
	*	Updates the content of the visible items
	*/
	private function updateContent ( inPosition:Number ) : Void {

		mScrollPosition = (inPosition == undefined)? mScrollPosition : inPosition;

		if (mScrollPosition < 0) {

			mScrollPosition = 0;

		} else if (mScrollPosition > (mData.length - mItems.length)) {

			mScrollPosition = mData.length - mItems.length;
		}

		for (var i:Number=0; i<mItems.length; ++i) {

			mItems[i].setLabel(mData[mScrollPosition+i].label);
			mItems[i].setData(mData[mScrollPosition+i].label);
		}
	}

	/**
	*	Updates length of scrollbar and hides / shows it
	*/
	private function updateScrollBar () : Void {

		if (mData.length > rowCount) {

			// fit scrollbar to new length
			mScrollBar.height = mItems.length * mItemHeight;

			// show it
			mScrollBar._visible = true;

		} else {

			// hide it
			mScrollBar._visible = false;
		}
	}

	/**
	*	updates the  Label
	*/
	private function updateSelection ( inIndex:Number ) : Void {
		
		if (inIndex == undefined) {
			if (mLabelText != null) return; 
			inIndex = mSelectedIndex;
		}

		if (mSelectedIndex > mData.length-1) {

			mSelectedIndex = -1;
			mLabel.text = "";

		} else if (inIndex == -1) {

			mSelectedIndex = 0;
			mLabel.text = mData[mSelectedIndex].label;

		} else if (inIndex != -1) {

			mSelectedIndex = inIndex;
			mLabel.text = mData[mSelectedIndex].label;
		}
		
	}

	/**
	*	Places clips before showing them
		@returns Number, vertical anchor point where all clips are aligned to
	*/
	private function placeClips ( inDown:Boolean ) : Number {

		var y:Number;
		if (inDown) {

			y = mMaskAnchor;
			mListMask._y = y;
			mListContent._y = -mListContent._height;
			mListContentBg._y = -mListContentBg._height;
			mScrollBar._y = -mScrollBar._height;

		} else {

			y = -mListMask._height;
			mListMask._y = y;
			mListContent._y = mMaskAnchor;
			mListContentBg._y = mMaskAnchor;
			mScrollBar._y = mMaskAnchor;
		}

		// return anchor
		return y;
	}

	/**
	*	PUBLIC
	*/

	/**
	*	adds an item to the dropdown list, format as an object: { label:String, data:(untyped) }.
	*/
	public function addItem ( inItem:Object ) : Void {

		// add this item at the bottom of the list
		mAdd( inItem, -1 );
	}

	/**
	*	adds an item to the dropdown list at a specific position. See addItem for details.
	*/
	public function addItemAt ( inItem:Object, inPosition:Number ) : Void {

		// add this item at specific position to the list
		mAdd( inItem, inPosition );
	}

	/**
	*	Retrieves the item at a specified index.
		@param index The index of the item to retrieve. The index must be a number greater than or equal to 0, and less than the value of ComboBox.length.
		@returns The indexed item object as { data, label }.
	*/
	public function getItemAt ( inIndex:Number ) : Object {

		// add this item at specific position to the list
		return mData[inIndex];
	}

	/**
	*	Opens the dropdown
	*	@param inAnim, boolean, set to false to *skip* dropdown animaition
	*/
	public function show ( inAnim:Boolean ) : Void {

		if (mData.length > 0) {
						
			// swap to higher depth
			mMc.swapDepths(mShowDepth);
	
			// do we need to update first?
			if (mNeedUpdate) {
	
				// perform update
				update();
	
				// place clips
				placeClips(dropDirection());
			}
	
			// drop down or drop up?
			var y:Number;
			if (dropDirection()) {
				y = mMaskAnchor;
			} else {
				y = -mListMask._height + 1;
			}
	
			// show items
			mOpen = true;
			mContentMover.stop();
			mBackgroundMover.stop();
			mScrollBarMover.stop();
			delete mContentMover;
			delete mBackgroundMover;
			delete mScrollBarMover;
			
			if (inAnim == undefined || inAnim == true) {
				mContentMover = new Tween(mListContent, "_y", Strong.easeOut, mListContent._y, y, mTweenDuration);
				mBackgroundMover = new Tween(mListContentBg, "_y", Strong.easeOut, mListContentBg._y, y, mTweenDuration);
				mScrollBarMover = new Tween(mScrollBar, "_y", Strong.easeOut, mScrollBar._y, y, mTweenDuration);
			} else {
				mListContent._y = y;
				mListContentBg._y = y;
				mScrollBar._y = y;
			}
		}
	}

	/**
	*	Closes the dropdown
	*	@param inAnim, boolean, set to false to *skip* dropdown animation
	*/
	public function hide ( inAnim:Boolean ) : Void {
		
		if (mOpen) {

			// swap to lower depth
			mMc.swapDepths(mClipDepth);
	
			// fold down or fold up?
			var y:Number;
			if (dropDirection()) {
				y = -mListContent._height;
			} else {
				y = mMaskAnchor;
			}
	
			// hide items
			mOpen = false;
			mContentMover.stop();
			mBackgroundMover.stop();
			mScrollBarMover.stop();
			delete mContentMover;
			delete mBackgroundMover;
			delete mScrollBarMover;
			if (inAnim == undefined || inAnim == true) {
				mContentMover = new Tween(mListContent, "_y", Strong.easeOut, mListContent._y, y, mTweenDuration);
				mBackgroundMover = new Tween(mListContentBg, "_y", Strong.easeOut, mListContentBg._y, y, mTweenDuration);
				mScrollBarMover = new Tween(mScrollBar, "_y", Strong.easeOut, mScrollBar._y, y, mTweenDuration);
			} else {
				mListContent._y = y;
				mListContentBg._y = y;
				mScrollBar._y = y;
			}
		}
	}

	/**
	*	Clears contents of the ComboBox
	*/
	public function clear () : Void {
	
		// remove existing items
		for (var i:Number=0; i<mItems.length; ++i) {

			MovieClip(mItems[i]).removeMovieClip();
		}

		// clear item list
		mItems = [];
		mData = [];
		
		// hide caption
		mSelectedIndex = -1;
		mLabel.text = "";
	}

	/**
	*	Gets the value of currently selected item (data field by default, or label if no data is available).
	*/
	public function getValue () : Object {

		return value;
	}

	/************************************
	*		EVENTS			*
	/***********************************/

	/**
	Fired DropDownItems
	@sends ComboBoxEvent#ON_ITEM_SELECTED When selection is changed
	*/
	public function onItemClicked ( e:ComboBoxItemEvent ) : Void {

		// store clicked item
		for (var i:Number=0; i<mItems.length; ++i) {

			// is this the selected item and is it different from current selection?
			if (mItems[i] == e.target) {

				// update selected item
				updateSelection(mScrollPosition + i);
				
				// notify listeners
				var eventType:String = ComboBoxEvent.ON_ITEM_SELECTED;
				dispatchEvent(new ComboBoxEvent(eventType, this, selectedItem ));
				break;
			}
		}

		// hide list
		hide();
	}

	/**
	*	Fired by arrow
	*/
	public function onButtonClicked ( e:EventButtonEvent ) : Void {

		switch (e.target) {

			case mArrow :

				action();
				break;
		}
	}

	/**
	*	Catch global onMouseDown event to close when clicking elsewhere
	*/
	public function onMouseDown () : Void {

		if (mOpen && !mMc.hitTest(_root._xmouse,_root._ymouse,true)) {

			hide();
		}
	}

	/**
	*	Catch global onMouseUp event to close when clicking elsewhere, after dragging off the dropdown
	*/
	public function onMouseUp () : Void {

		if (mOpen && !mMc.hitTest(_root._xmouse,_root._ymouse,true)) {

			hide();
		}
	}

	/**
	*	Catches onMouseWheel event and passes it to the ScrollBar
	*/
	public function onMouseWheel ( inDelta:Number ) : Void {

		if (mEnabled) {

			if ( mMc.hitTest(_root._xmouse,_root._ymouse) || MovieClip(mScrollBar).hitTest(_root._xmouse,_root._ymouse) ) {

				var dir:Number = (inDelta < 0)? 1 : -1;
				mScrollBar.scroll(dir);
			}
		}
	}

	/************************************************
	*		ISCROLLABLE IMPLEMENTATION		*
	/***********************************************/
	/**
	*	IScrollable implementation: Returns the current scroll position (pixels)
	*/
	public function getScrollPosition () : Number {

		return mScrollPosition * itemHeight;
	}

	/**
	*	IScrollable implementation: Returns the height of all content
	*/
	public function getTotalHeight () : Number {

		return mData.length * itemHeight;
	}

	/**
	*	IScrollable implementation: Returns the height of the visible content
	*/
	public function getVisibleHeight () : Number {

		return mItems.length * itemHeight;
	}

	/**
	*	IScrollable implementation: Scrolls the content list up or down
	*/
	public function onScrollContent ( e:ScrollEvent ) : Void {

		updateContent(mScrollPosition + e.direction);
	}

	/**
	*	IScrollable implementation: Scrolls the content list up or down
	*/
	public function scrollTo ( inPos:Number ) : Void {

		updateContent(inPos);
	}
	
	/**
	*	Gets the enabled state of the DropDown
	*/
	public function getEnabled () : Boolean {

		return mEnabled;
	}

	/**
	*	Sets the enabled state of the DropDown
	*/
	public function setEnabled ( inValue:Boolean ) : Void {

		mEnabled = inValue;
		useHandCursor = mEnabled;
		mArrow.useHandCursor = mEnabled;
		if (!mEnabled && mOpen) {
			
			hide();
		}
	}

	/************************************
	*		GETTER / SETTER		*
	/***********************************/

	/**
	*	Sets / gets the selected index
	*/
	public function set selectedIndex ( inIndex:Number ) {
		updateSelection( inIndex );
	}

	public function get selectedIndex () : Number {

		return mSelectedIndex;
	}

	/**
	*	Gets the selected item, returns an object { label, data }
	*/
	public function get selectedItem () : Object {

		return mData[mSelectedIndex];
	}

	/**
	*	Gets the length of the drop-down list.
	*/
	public function get length () : Number {

		return mData.length;
	}

	/**
	*	Gets the value of currently selected item (data field by default, or label if no data is available).
	*/
	public function get value () : Object {

		return (selectedItem.data == undefined)? selectedItem.label : selectedItem.data;
	}

	/**
	*	Setsthe duration of the dropdown animation (default 10)
	*/
	public function set duration ( inDuration:Number )  {

		if (inDuration > 0) {

			mTweenDuration = inDuration;
		}
	}

	/**
	*	Sets / gets the item height (default 18)
	*/
	public function set itemHeight ( inHeight:Number )  {

		mItemHeight = inHeight;
		mScrollBar.snapping = itemHeight;
	}

	public function get itemHeight () : Number {

		return mItemHeight;
	}

	/**
	*	Sets / gets the LinkageID to use for dropdown items. Default is "DropDownItem".
	*/
	public function set itemClass ( inClass:String )  {

		mItemClass = inClass;
	}

	public function get itemClass () : String {

		return mItemClass;
	}

	/**
	*	Sets / gets the the number of items to display in list
	*/
	public function set rowCount ( inCount:Number )  {

		if (inCount > 0) {

			mRowCount = inCount;
		}
	}

	public function get rowCount () : Number {

		return mRowCount;
	}

	/**
	*	Sets / gets the drop direction. Values are: "up", "down" or "auto"
	*/
	public function set direction ( inDirection:String )  {

		var dir:String = inDirection.toLowerCase();
		if (dir == "auto" || dir == "down" || dir == "up") {

			mDirection = inDirection;
		}
	}
	public function get direction () : String {

		return mDirection;
	}
	public function get open () : Boolean {
		
		return mOpen;
	}

	/**
	*	Sets the inital label, shown if no items are selected
	*/
	public function set label ( inLabel:String ){
		mLabelText = inLabel;
		mLabel.text = mLabelText;
	}

	/**
	*	Sets the TextFormat of the label
	*/
	public function set textFormat ( inFormat:TextFormat ) {

		mTextFormat = inFormat;
		mLabel.setTextFormat(mTextFormat);
		mLabel.setNewTextFormat(mTextFormat);
	}

	public function getStepSize() : Number {
		return 1;
	}

	public function toString () : String {
		return ";ComboBox";
	}

}
