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
This class acts as a replacement for Macromedia's mx.utils.Delegate, as that class cannot be used with MTASC.
Based on Till Schneidereit's simple but elegant solution: http://lists.motion-twin.com/archives/mtasc/2005-April/001602.html
This class allows for extra parameters to be passed to the event handler.
The class method {@link #create} creates a new Function object that passes the scope to the input object, rather than the object calling the function.
*/

class org.asapframework.events.EventDelegate {
	
	/**
	Private constructor
	*/
	private function EventDelegate () {}
	
	/**
	Creates an event delegate relation.
	@param scope: Object to call method on.
	@param method: Method to call.
	@param params: All additional parameters will be passed onto method on execution.
	@use Using a reference:
	<code>
	var myDelegate:Function = EventDelegate.create(this, onXMLloaded);
	myXML = new XML();
	myXML.onLoad = myDelegate;
	</code>
	Without reference:
	<code>myButton.addEventListener( "onClicked", EventDelegate.create(this, onExitButtonClicked))</code>
	To remove a listener using a delegate:
	<code>
	// use instance property
	mLoaderDoneEventDelegate = EventDelegate.create(this, handleImageLoaded);
	mImageLoader.addEventListener(LoaderEvent.ON_DONE, mLoaderDoneEventDelegate);
	</code>
	After having loaded:
	<code>
	mImageLoader.removeEventListener(LoaderEvent.ON_DONE, mLoaderDoneEventDelegate);
	</code>
	*/	
	public static function create (scope:Object, method:Function) : Function {
		var p:Array = arguments.splice (2, arguments.length-2);
		var f:Function = function () : Void {
			method.apply(scope, arguments.concat (p));
		};
		return f;
	}
}