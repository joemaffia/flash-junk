/*
Copyright 2005-2006 by the authors of asapframework

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

import org.asapframework.events.Event;
import org.asapframework.ui.video.FLVPlayer;

class org.asapframework.ui.video.FLVPlayerEvent extends Event {
	/** Generic event type for all FLVPlayer events */
	public static var EVENT_FLVPLAYER:String = "onFLVPlayerEvent";
	
	/** Event sent when player status has changed */
	public static var STATUS_CHANGE:String = "onStatusChange";
	/** Event sent when the player starts playing video */ 
	public static var PLAY_STARTED:String = "onPlayStarted"; 
	/** Event sent when the buffer is empty */
	public static var BUFFER_EMPTY:String = "onBufferEmpty";
	/** Event sent when meta data has been received */
	public static var METADATA_RECEIVED:String = "onMetaDataReceived"; 

	/** specific type of event */
	public var subtype:String;
	/** current status of player when status has changed */
	public var status:String;
	
	public function FLVPlayerEvent (inType:String, inStatus:String, inSource:FLVPlayer) {
		super(EVENT_FLVPLAYER, inSource);
		
		subtype = inType;		
		status = inStatus;
	}
}
