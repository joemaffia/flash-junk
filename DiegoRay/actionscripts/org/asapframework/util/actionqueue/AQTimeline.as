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
ActionQueue methods to control the movieclip's timeline.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQTimeline {
	
	/**
	Moves the framehead to a frame number or label and plays.
	@param inMC : movieclip which timeline to control
	@param inFrame : frame number (Number) or frame label (String)
	*/	
	public static function gotoAndPlay (inMC:MovieClip,
										inFrame:Object) : Void {
		inMC.gotoAndPlay(inFrame);
	}
	
	/**
	Moves the framehead to a frame number or label and stops.
	@param inMC : movieclip which timeline to control
	@param inFrame : frame number (Number) or frame label (String)
	*/
	public static function gotoAndStop (inMC:MovieClip,
										inFrame:Object) : Void {
		inMC.gotoAndStop(inFrame);
	}
	
}