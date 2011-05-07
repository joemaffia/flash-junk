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

import org.asapframework.data.array.*;

/**
Enhanced array enumerator, with the option to loop. TraverseArrayEnumerator sends out traverse events of type {@link TraverseArrayEnumeratorEvent#UPDATE}.

A TraverseArrayEnumerator can be used with a paging controller to navigate through a list of thumbs or search result pages (see example below).
@author Arthur Clemens
@use
Example for a enumerator that handles a row of thumbs.
<code>
private function PagingController (inTimeline:MovieClip) {
	// Create thumb image list:
	var thumbList:Array = createThumbs();
	// Create traverse enumerator for this list
	mThumbPager = new TraverseArrayEnumerator(thumbList);
	// Subscribe to update events so the previous and next buttons can be updated:
	mThumbPager.addEventListener(TraverseArrayEnumeratorEvent.UPDATE,
EventDelegate.create(this, handleThumbUpdate));
	// Highlight first thumb and load corresponding image:		
	activateThumb(mThumbPager.getNextObject());
}
</code>
In this example the previous, next and thumb image buttons are subclasses of {@link EventButton}:
<code>
public function onEventButtonPress ( e:EventButtonEvent ) : Void {
	if (e.target instanceof ThumbImage) {
		var thumb:ThumbImage = ThumbImage(e.target);
		var oldThumb:ThumbImage = mThumbPager.getCurrentObject();
		mThumbPager.setCurrentObject(thumb); // will update the enumerator			
		activateThumb(thumb, oldThumb);
	}
	if (e.target instanceof NextButton) {
		var oldThumb:ThumbImage = mThumbPager.getCurrentObject();
		var newThumb:ThumbImage;
		if (e.target._name == "next_btn") {
			newThumb = mThumbPager.getNextObject();
		}
		if (e.target._name == "previous_btn") {
			newThumb = mThumbPager.getPreviousObject();
		}
		activateThumb(newThumb, oldThumb);
	}
}
</code>
Update the previous and next button with each change:
<code>
private function handleThumbUpdate (e:TraverseArrayEnumeratorEvent) : Void {	
	next_btn.setEnabled(mThumbPager.hasNextObject());
	previous_btn.setEnabled(mThumbPager.hasPreviousObject());
}
</code>
Thumb update function:
<code>
private function activateThumb (inThumb:ThumbImage, inOldThumb:ThumbImage) : Void {
	if (inOldThumb) {
		inOldThumb.setSelected(false);
	}
	inThumb.setSelected(true);
	loadImage(inThumb.getId()); 
}
</code>
*/

class org.asapframework.data.array.TraverseArrayEnumerator extends ArrayEnumerator {

	private var mTraverseOptions:Number = TraverseArrayOptions.NONE;
	private var mDelegateObject:Object;
	private var mDelegateMethod:Object;
	
	/**
	Creates a new array enumerator. Optionally stores a pointer to array inArray.
	@param inArray : (optional) the array to enumerate
	@param inDoLoop : if true, the enumerator will loop past the end of the array to the start (and back when traversing backwards)
	*/
	public function TraverseArrayEnumerator (inArray:Array, inDoLoop:Boolean) {
		super(inArray);
		if (inDoLoop) {
			mTraverseOptions = TraverseArrayOptions.LOOP;
		}
	}
	
	/**
	The traversal options; see {@link TraverseArrayOptions}.
	*/
	public function set traverseOptions (inTraverseOptions:Number) : Void {
		mTraverseOptions = inTraverseOptions;
	}
	public function get traverseOptions () : Number {
		return mTraverseOptions;
	}
	
	/**
	Set the looping property of the enumerator.
	@param inDoLoop : if true, the enumerator will loop past the end of the array to the start (and back when traversing backwards)
	@implementationNote Uses {@link TraverseArrayOptions#LOOP}.
	*/
	public function setLoop (inDoLoop:Boolean) : Void {
		if (inDoLoop) {
			mTraverseOptions = TraverseArrayOptions.LOOP;
		} else {
			mTraverseOptions = TraverseArrayOptions.NONE;
		}
	}
	
	/**
	A delegate validation method is called in {@link #update} when a delegate object is set. The delegate's validation method is called to evaluate the new node before it is set.
	@param inDelegateObject: the owner of the delegate method
	@param inDelegateMethod: Node validation method (method name or function reference). This method should accept an Object as parameter and return a Boolean to indicate the item's validity.
	*/
	public function setDelegate (inDelegateObject:Object,
								 inDelegateMethod:Object) : Void {
		mDelegateObject = inDelegateObject;
		mDelegateMethod = inDelegateMethod;
	}
	
	/**
	Increments the location pointer by one and returns the object from the array at that location.
	@return (Deliberately untyped) The object at the new location. Returns null if the location pointer has moved past the end of the array and inTraverseOptions is not set to {@link TraverseArrayOptions#LOOP}.
	@implementationNote Calls {@link #update}.
	*/
	public function getNextObject (inTraverseOptions:Number) {
		var nextLocation:Number = performGetNextObject(inTraverseOptions);
		if (nextLocation != -1) {
			return update(nextLocation);
		}
		return null;
	}
	
	/**
	Decrements the location pointer by one and returns the object from the array at that location.
	@return (Deliberately untyped) The object at the new location. Returns null if the location pointer has moved past the end of the array and inTraverseOptions is not set to {@link TraverseArrayOptions#LOOP}.
	@implementationNote Calls {@link #update}.
	*/
	public function getPreviousObject (inTraverseOptions:Number) {
		var previousLocation:Number = performGetPreviousObject(inTraverseOptions);
		if (previousLocation != null) {
			return update(previousLocation);
		}
		return null;
	}
	
	/**
	Checks if there is an object after the current object.
	@return True: there is a next object; false: the current object is the last.
	*/
	public function hasNextObject (inTraverseOptions:Number) : Boolean {
		var nextLocation:Number = performGetNextObject(inTraverseOptions);
		if (nextLocation != -1) {
			return true;
		}
		return false;
	}
	
	/**
	Checks if there is an object before the current object.
	@return True: there is a next object; false: the current object is the first.
	*/
	public function hasPreviousObject (inTraverseOptions:Number) : Boolean {
		var previousLocation:Number = performGetPreviousObject(inTraverseOptions);
		if (previousLocation != -1) {
			return true;
		}
		return false;
	}
	
	/**
	@exclude
	*/
	public function toString () : String {
		return "TraverseArrayEnumerator; array " + mArray;
	}
	
	// PRIVATE METHODS
	
	/**
	@return The next location; -1 if the next location is not valid.
	*/
	private function performGetNextObject (inTraverseOptions:Number) : Number {
		var traverseOptions:Number = (inTraverseOptions != undefined) ? inTraverseOptions : mTraverseOptions;

		var nextLocation:Number = mLocation + 1;
		if (traverseOptions & TraverseArrayOptions.LOOP) {
			if (nextLocation == mArray.length) {
				return 0;
			}
			return nextLocation;
		}
		if (traverseOptions & TraverseArrayOptions.NONE) {
			if (nextLocation < mArray.length) {
				return nextLocation;
			}
		}
		return -1;
	}
	
	/**
	@return The previous location; -1 if the previous location is not valid.
	*/
	private function performGetPreviousObject (inTraverseOptions:Number) : Number {
		var traverseOptions:Number = (inTraverseOptions != undefined) ? inTraverseOptions : mTraverseOptions;
		
		var previousLocation:Number = mLocation - 1;
		if (traverseOptions & TraverseArrayOptions.LOOP) {
			if (previousLocation < 0) {
				return mArray.length - 1;
			}
			return previousLocation;
		}
		if (traverseOptions & TraverseArrayOptions.NONE) {
			if (previousLocation >= 0) {
				return previousLocation;
			}
		}		
		return -1;
	}
	
	/**
	If a delegate object has been set, its validation method is called before setting the new node. If the validation method returns false, this method will return null
	@param inNewLocation: the new pointer position
	@return (Deliberately untyped) The object from the array at the new position.
	@sends TraverseArrayEnumeratorEvent#UPDATE If the delegate validation method exists and only if the delegate method returns true.
	*/
	private function update (inLocation:Number) {
		if (mDelegateObject != null) {
			var isValid:Boolean;
			if (typeof mDelegateMethod == "function") {
				isValid = Boolean(mDelegateMethod.apply(mDelegateObject, [inLocation]));
			} else if (typeof(mDelegateObject[mDelegateMethod]) == "function") {
				isValid = Boolean(mDelegateObject[mDelegateMethod].apply(mDelegateObject, [inLocation]));
			}
			if (!isValid) {
				return null;
			}
		}
		mLocation = inLocation;
		dispatchEvent(new TraverseArrayEnumeratorEvent(TraverseArrayEnumeratorEvent.UPDATE, getCurrentObject(), this));
		return getCurrentObject();
	}
}