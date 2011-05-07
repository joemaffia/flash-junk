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

import org.asapframework.util.loader.Loader;
import org.asapframework.events.Event;

/**
Event object that is dispatched by {@link Loader}.
*/

class org.asapframework.util.loader.LoaderEvent extends Event {
	public static var ON_ALL_LOADED:String = "onAllLoadFinished";
	public static var ON_START:String = "onLoadStart";
	public static var ON_PROGRESS:String = "onLoadProgress";
	public static var ON_DONE:String = "onLoadDone";
	public static var ON_ERROR:String = "onLoadError";

	public var name:String;
	public var targetClip:Object;
	public var total:Number;
	public var loaded:Number;

	/**
	
	*/
	function LoaderEvent (inType:String, inSource:Loader, inName:String, inTargetClip:Object, inTotal:Number, inLoaded:Number) {

		super(inType, inSource);
		name = inName;
		targetClip = inTargetClip;
		total = inTotal;
		loaded = inLoaded;
	}
}
