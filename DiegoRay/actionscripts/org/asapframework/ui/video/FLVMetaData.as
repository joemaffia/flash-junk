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

/**
 * ValueObject to store FLV Metadata in.
 */
class org.asapframework.ui.video.FLVMetaData {
	
	/** Video framerate as received through onMetaData event */
	public var framerate:Number;
	/** Video duration as received through onMetaData event */
	public var duration:Number;
	/** Video width as received through onMetaData event */
	public var width:Number;
	/** Video height as received through onMetaData event */
	public var height:Number;
	/** Video data rate (kbits/second) as received through onMetaData event */
	public var videoDataRate:Number;
	/** Audio data rate (kbits/second) as received through onMetaData event */
	public var audioDataRate:Number;
	/** Creation date as received through onMetaData event */
	public var creationDate:String;
	/** 'canSeekToEnd' as received through onMetaData event */
	public var canSeekToEnd:Boolean;
	/** video codec ID as received through onMetaData event */
	public var videoCodecID:Number;
	/** audio codec ID as received through onMetaData event */
	public var audioCodecID:Number;
	
	/**
	 * Constructor.
	 * @param data Object to parse, this should be a raw NetStream.onMetaData data object.   
	 */
	public function FLVMetaData ( inData:Object ) {
		
		duration = isNaN(inData.duration) ? null : inData.duration;
		framerate = isNaN(inData.framerate) ? null : inData.framerate;
		width = isNaN(inData.width) ? null : inData.width;
		height = isNaN(inData.height)? null : inData.height;
		videoDataRate = isNaN(inData.videoDataRate)? null : inData.videoDataRate;
		audioDataRate = isNaN(inData.audioDataRate) ? null : inData.audioDataRate;
		creationDate = (inData.creationDate == undefined) ? null : inData.creationDate;
		canSeekToEnd = (inData.canSeekToEnd == undefined) ? false : inData.canSeekToEnd;
		videoCodecID = isNaN(inData.videocodecid) ? null : inData.videocodecid;
		audioCodecID = isNaN(inData.audiocodecid) ? null : inData.audiocodecid;
	}
}
