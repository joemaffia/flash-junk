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

import org.asapframework.util.actionqueue.ActionQueueData;

/**
Data storage class used by {@link ExtendedActionQueue}.
@author Arthur Clemens
*/

class org.asapframework.util.actionqueue.ExtendedActionQueueData extends ActionQueueData {

	public var sender:Object;
	public var message:String;
	public var timeOutDuration:Number;
	public var timedOutObject:Object;
	public var timedOutFunctionName:String;
	public var timedOutArgs:Array;
	public var isPaused:Boolean;
	public var variableToWatchOwner:Object;
	public var variableToWatch:String;
	public var checkForValue:Object;
	public var intervalDuration:Number;
	public var willPause:Boolean;
	
	public function toString () : String {
		return "; ExtendedActionQueueData";
	}
}