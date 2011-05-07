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

// ASAP classes
import org.asapframework.management.lang.IMultiLanguageTextContainer;


/**
Internal ValueObject class used by the LanguageManager to store information on text containers.
*/

class org.asapframework.management.lang.MultiLanguageClipData {

	public var id:Number;	
	public var cnt:IMultiLanguageTextContainer;
	
	/**
	Constructor
	@param inID: the id of the text assigned to the container
	@param inContainer: instance of a class implementing {@link IMultiLanguageTextContainer}
	*/
	public function MultiLanguageClipData (inID:Number, inContainer:IMultiLanguageTextContainer) {
		id = inID;
		cnt = inContainer;
	}
}