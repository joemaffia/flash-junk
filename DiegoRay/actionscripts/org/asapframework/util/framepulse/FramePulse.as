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

import org.asapframework.events.Dispatcher;
import org.asapframework.util.framepulse.FramePulseEvent;

/**
Class to simulate onEnterFrame events.
@usage
<code>	
var fpulse:FramePulse = FramePulse.getInstance();
fpulse.addEventListener(FramePulseEvent.ON_ENTERFRAME, this);

// next, define a function named "onEnterFrame" in your class...
 	
public function onEnterFrame (e:FramePulseEvent) : Void {
	
	// code goes here...
}
</code>
To stop code that is run in the class' onEnterFrame, remove the listener:
<code>
fpulse.removeEventListener(FramePulseEvent.ON_ENTERFRAME, this);
</code>

An alternate way to listen to enterframe events is as follows:
<code>
var listener:Function = EventDelegate.create(this, onEnterFrame);
FramePulse.addEnterFrameListener(listener);
</code>
To stop listening to enterFrame events do this:
<code>
FramePulse.removeEnterFrameListener(listener);
</code>

@implementationNote Creates an empty clip named "__FramePulseClip" (by default on _level0, at depth 9888).
@author Martijn de Visser
*/

class org.asapframework.util.framepulse.FramePulse extends Dispatcher {
	
	/**
	Default name of the FramePulse movieclip.
	*/
	public static var CLIP_NAME:String = "__FramePulseClip";
	
	/**
	Default stack depth of the FramePulse movieclip.
	*/
	public static var CLIP_DEPTH:Number = 9888;
	
	/**
	Default root clip where the FramePulse movieclip is attached to.
	*/
	public static var CLIP_ROOT:MovieClip = _level0;
	
	private static var sInstance:FramePulse = null;
	
	/**
	
	*/
	private function FramePulse () {

		super();
		
		var owner:FramePulse = this;
		var mc:MovieClip = FramePulse.CLIP_ROOT.createEmptyMovieClip (FramePulse.CLIP_NAME, FramePulse.CLIP_DEPTH);		
		mc.onEnterFrame = function () { owner.pulse(); };
	}

	/**
	Add a listener to the FramePulse
	@param inListener: function to be called on enterframe, with parameter FramePulseEvent
	*/
	public static function addEnterFrameListener (inListener:Function) : Void {
		FramePulse.getInstance().addEventListener(FramePulseEvent.ON_ENTERFRAME, inListener);
	}
	
	/**
	Remove a listener from the FramePulse
	@param inListener: function that was previously added
	*/
	public static function removeEnterFrameListener (inListener:Function) : Void {
		FramePulse.getInstance().removeEventListener(FramePulseEvent.ON_ENTERFRAME, inListener);
	}
	
	/**
	Returns reference to singleton instance of FramePulse.
	*/
	public static function getInstance () : FramePulse {
		
		if (sInstance == null) {
			sInstance = new FramePulse();
		}
		return sInstance;
	}
	
	/**
	This method is called by FramePulse's movieclip instance on its onEnterFrame method.
	@sends FramePulseEvent#ON_ENTERFRAME At "onEnterFrame" event of created clip
	*/
	public function pulse () : Void {
	
		dispatchEvent( new FramePulseEvent( this ));
	}
	
}
