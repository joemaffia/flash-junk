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

// macromedia classes
import mx.events.EventDispatcher;

/**
	Base class that extends MovieClip and can send events.
*/

class org.asapframework.ui.EventMovieClip extends MovieClip {
	
	private var mMc:MovieClip;
	
	// mix-in EventDispatcher
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;

	public function EventMovieClip () {
		
		// initialize EventDispatcher
		EventDispatcher.initialize(this);
		
		// disable focus rectangle
		mMc = MovieClip(this);
		_focusrect = false;
		tabEnabled = false;
	}
}
