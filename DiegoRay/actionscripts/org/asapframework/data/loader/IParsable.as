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
Interface to implement in DataValueObject classes that get their data through the {@link Parser} class.
The {@link Parser} class calls the {@link #parseObject} function with data from {@link XML2Object#parseXML}. The implementing class is expected to use this Object to retrieve data from.
*/
 
interface org.asapframework.data.loader.IParsable {
	/**
	*	Parse an object (from XML or otherwise) into typed variables.
	*	@param o: Object containing data
	*	@return true if parsing went ok, otherwise false
	*/
	public function parseObject (o:Object) : Boolean;
}