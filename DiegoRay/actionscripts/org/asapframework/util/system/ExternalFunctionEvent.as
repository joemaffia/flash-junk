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

import org.asapframework.util.system.ExternalFunction;

/**
@author Martijn de Visser 
*/

class org.asapframework.util.system.ExternalFunctionEvent {
	
	public var type:String;
	public var target:ExternalFunction;
	public var params:Array;

	/**
	Creates a new event with the name of the event handler, the source of the event and the parameters
	@param inType:String, name of event (as received from JavaScript)
	@param inSource:Object, source of event (always ExternalFunction.getInstance())
	@param inParams:Array, parameters (as received from JavaScript)
	*/
	function ExternalFunctionEvent (inType:String, inSource:ExternalFunction, inParams:Array) {
		
		type = inType;
		target = inSource;
		params = inParams;
	}
}
