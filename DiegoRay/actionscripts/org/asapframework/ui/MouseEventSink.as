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

/**
	@author Martijn de Visser 
	@description The MouseEventSink class can be attached to a movieclip to catch all mouse events it receives, thus preventing any clips on lower levels from receving those events.
*/

class org.asapframework.ui.MouseEventSink extends MovieClip {	
	
	/**
	*	Constructor
	*/
	public function MouseEventSink () {

		enabled = false;
		useHandCursor = false;
		tabEnabled = false;
		tabChildren = false;
	}
	
	/**
	*	Catch all mouse events
	*/
	public function onRollOver () : Void {};
	public function onRollOut () : Void {};
	public function onPress () : Void {};
	public function onRelease() : Void {};
	public function onReleaseOutside() : Void {};
}
