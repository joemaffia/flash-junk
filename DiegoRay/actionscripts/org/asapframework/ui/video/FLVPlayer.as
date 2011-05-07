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
Class for playing FLV files.

Requires a movieclip with an embedded video object with the name "holder_vid".
Currently resizing is not supported; therefore the video object has to have the same size as the video to be played.

@example:
1. In the library, create a new Embedded Video object
2. Create an new MovieClip symbol, and drag the Video object into it. 
3. Set the proper size of the Video object, and name it "holder_vid". This name is mandatory!
4. Set the linkage id of the movieclip to "videoContainer". Another name can be used, since this is passed as a parameter to the constructor.

In a controller class, add the following code:
<code>
	// create the player
	mPlayer = new FLVPlayer(mMc, "videoContainer", DEPTH_PLAYER, 0, 0);
	
	// listen to events if necessary; implement the handler functions
	// mPlayer.addEventListener(FLVPlayerEvent.PLAY_STARTED, EventDelegate.create(this, onPlayStarted));
	// mPlayer.addEventListener(FLVPlayerEvent.STATUS_CHANGE, EventDelegate.create(this, onStatusChange));
	
	// play the video; change the parameters to match your flv path and duration, respectively
	mPlayer.playMovie("myMovie.flv", 30); 
</code>

Alternately, follow steps 1. to 3. above, and then do the following:
4. drag an instance of the created movieclip symbol onto the stage, and name it "video_mc". Another name can be used since the clip is passed as a parameter to the constructor.

On the timeline, add the following code:
<code>
	// create the player
	var player:FLVPlayer = new FLVPlayer(video_mc);
	// play the video; change the parameters to match your flv path and duration, respectively
	player.playMovie("myMovie.flv", 30); 
</code>
@todo A solution needs to be found for issue #1337339 where no PLAY_STARTED event is generated when the buffer size exceeds the length of the video 

*/
import org.asapframework.events.Dispatcher;
import org.asapframework.events.EventDelegate;
import org.asapframework.ui.video.FLVMetaData;
import org.asapframework.ui.video.FLVPlayerEvent;

class org.asapframework.ui.video.FLVPlayer extends Dispatcher {
	/* status constants */
	public static var STOPPED:String = "stopped";
	public static var PLAYING:String = "playing";	/**< Status message received when the first frame has been displayed; video still needs to be preloaded. */
	public static var PAUSED:String = "paused";
	
	private var mHolderMC:MovieClip;
	private var mStream:NetStream;
	private var mConnection:NetConnection;
	private var mDuration:Number;
	private var mStatus:String = STOPPED;
	private var flvPath:String;
	private var mMetaData:FLVMetaData;

	private var mVideo : Video;

	/**
	Constructor
	@param inBaseMC: movieclip to attach the library symbol to, or the movieclip on the stage that contains the video; video object inside the movieclip must be named "holder_vid".
	
	The following parameters are needed only if a library symbol is attached; otherwise they must be left out.
	@param inLinkageName: linkage id of a movieclip symbol in the library
	@param inLevel: depth to attach the library symbol to; ignored if an existing movieclip is passed
	@param inX: x-position of the new movieclip; ignored if an existing movieclip is passed
	@param inY: y-position of the new movieclip; ignored if an existing movieclip is passed
	*/
	public function FLVPlayer (inBaseMC:MovieClip, inLinkageName:String, inDepth:Number, inX:Number, inY:Number) {
		super();

		// create or store UI		
		if (inLinkageName == undefined) {
			mHolderMC = inBaseMC;
		} else {
			mHolderMC = inBaseMC.attachMovie(inLinkageName, inLinkageName + inDepth, inDepth);
			mHolderMC._x = inX;
			mHolderMC._y = inY;
		}
	
		// create NetConnection
		mConnection = new NetConnection();
		mConnection.connect(null);
		
		// create NetStream
		mStream = mHolderMC.stream = new NetStream(mConnection);
		mStream.setBufferTime(20);
		mStream.onStatus = EventDelegate.create(this, handleStatusMessage);
		
		// get Video object
		mVideo = Video(mHolderMC.holder_vid);
		mVideo.attachVideo(mStream);

		// catch handleMetaData event
		mStream.onMetaData = EventDelegate.create(this, handleMetaData);
	}
	
	/**
	Set filters for video.<br>
	From the documentation of the Video class:<br>
	Deblocking indicates the type of deblocking filter applied to decoded video as part of postprocessing. Two deblocking filters are available: one in the Sorenson codec and one in the On2 VP6 codec. The following values are acceptable:
	<ul>
	  <li>0 (the default)--Let the video compressor apply the deblocking filter as needed.</li>
	  <li>1--Do not use any deblocking filter.</li>
	  <li>2--Use the Sorenson deblocking filter.</li>
	  <li>3--Use the On2 deblocking filter and no deringing filter.</li>
	  <li>4--Use the On2 deblocking and the fast On2 deringing filter.</li>
	  <li>5--Use the On2 deblocking and the better On2 deringing filter.</li>
	  <li>6--Same as 5.</li>
	  <li>7--Same as 5.</li>
	</ul><br>
	If a mode greater than 2 is selected for video when you are using the Sorenson codec, the Sorenson decoder defaults to mode 2 internally.<br>
	Use of a deblocking filter has an effect on overall playback performance, and it is usually not necessary for high-bandwidth video. If your system is not powerful enough, you may experience difficulties playing back video with this filter enabled.
	@param inDeblocking: type of deblocking 
	@param inSmooth: if true, video is smoothed
	*/
	public function setFilters (inDeblocking:Number, inSmooth:Boolean) : Void {
		if (inDeblocking != null) mVideo.deblocking = inDeblocking;
		if (inSmooth != undefined) mVideo.smoothing = inSmooth;
	}
	
	/**
	Play an FLV movie; specification of duration is necessary only when progress is monitored
	@param inURL: full path to the FLV movie to be played
	@param inDuration: duration in seconds
	*/
	public function playMovie (inURL:String, inDuration:Number) : Void {
		setDuration(inDuration);

		flvPath = inURL;
		mStream.play(flvPath);
	}
	
	/**
	Starts the movie from the beginning.
	*/
	public function play () : Void {
		mStream.play(flvPath);
	}
	
	/**
	Pauses the movie; use {@link #resume} to resume playing.
	*/
	public function pause () : Void {
		mStream.pause(true);
		mStatus = PAUSED;
		dispatchEvent(new FLVPlayerEvent(FLVPlayerEvent.STATUS_CHANGE, mStatus, this));
	}
	
	/**
	Resumes the movie after it has been paused.
	*/
	public function resume () : Void {
		mStream.pause(false);
		mStatus = PLAYING;
		dispatchEvent(new FLVPlayerEvent(FLVPlayerEvent.STATUS_CHANGE, mStatus, this));
	}
	
	/**
	Stops playing the movie.
	*/
	public function stop () : Void {
		mStream.close();
		mStatus = STOPPED;
		dispatchEvent(new FLVPlayerEvent(FLVPlayerEvent.STATUS_CHANGE, mStatus, this));
	}
	
	/**
	Seeks to the offset specified (seconds). Pass '0' to rewind the video.
	*/
	public function seek ( inSeconds:Number ) : Void {
		mStream.seek(inSeconds);
	}

	/**
	The current progress time in seconds.
	*/
	public function getCurrentPlayTime () : Number {
		return mStream.time;
	}

	/**
	Returns the current progress percentage, if the duration has been set. Otherwise returns 0.
	*/
	public function getCurrentPlayPercentage () : Number {
		if ((mDuration == undefined) || (mDuration == 0)) return 0;
		
		return 100 * mStream.time / mDuration;
	}
	
	/**
	Returns the current progress factor (0 <= f <= 1); defined only if the duration has been set.
	*/
	public function getCurrentProgressFactor () : Number {
		if ((mDuration == undefined) || (mDuration == 0)) return 0;

		return mStream.time / mDuration;
	}

	/**
	FLV meta data as received through NetStream.handleMetaData event.
	*/
	public function getMetaData () : FLVMetaData {
		return mMetaData;
	}

	/**
	The duration of the movie in seconds.
	*/
	public function setDuration (inD:Number) : Void {
		mDuration = inD;
	}
	
	/**
	The duration of the movie in seconds.
	*/
	public function getDuration () : Number {
		return mDuration;
	}

	/**
	The loading progress of the movie.
	*/
	public function getBytesLoaded () : Number {
		return mStream.bytesLoaded;
	}

	/**
	The total size of the movie.
	*/
	public function getBytesTotal () : Number {
		return mStream.bytesTotal;
	}
	
	/**
	Returns the percentage of the video that has been loaded.
	*/
	public function getLoadedPercentage () : Number {
		return 100 * getBytesLoaded() / getBytesTotal();
	}
	
	/**
	The current player status.
	*/
	public function getStatus () : String {
		return mStatus;
	}
	
	/**
	The visibility of the player (true: visible or false:invisible).
	*/
	public function setVisible ( inVisible:Boolean ) : Void {
		
		mHolderMC._visible = inVisible;
	}
	
	/**
	The number of seconds of video to buffer before playing is started;
	default is 20 seconds
	*/
	public function setBufferTime (inTime:Number) : Void {
		mStream.setBufferTime(inTime);
	}

	/**
	Handler for status messages from the NetStream object.
	@param inObj: an object containing a String property 'code' with the status details
	*/
	private function handleStatusMessage (inObj:Object) : Void {
		var doDispatch:Boolean = false;
		
		switch (inObj.code) {
			case "NetStream.Play.Start": 
				mStatus = PLAYING; 
				doDispatch = true;
				break;
			case "NetStream.Play.Stop":
				mStatus = STOPPED;
				doDispatch = true;
				break;
			case "NetStream.Buffer.Empty":
				dispatchEvent(new FLVPlayerEvent(FLVPlayerEvent.BUFFER_EMPTY, mStatus, this));
				break;
			case "NetStream.Buffer.Full":
				dispatchEvent(new FLVPlayerEvent(FLVPlayerEvent.PLAY_STARTED, mStatus, this));
				break;

		}
		if (doDispatch) {
			dispatchEvent(new FLVPlayerEvent(FLVPlayerEvent.STATUS_CHANGE, mStatus, this));
		}
	}

	/**
	 * Handler for onMetadata event from the NetStream object.
	 * @param inObj: the meta data found in this FLV, see NetStream documentation for more info
	 */
	private function handleMetaData ( inData:Object ) : Void {
		// store data
		mMetaData = new FLVMetaData(inData);
				
		// update duration
		mDuration = mMetaData.duration;
		
		dispatchEvent(new FLVPlayerEvent(FLVPlayerEvent.METADATA_RECEIVED));
	}

	public function toString () : String {
		return ";FLVPlayer";
	}
}
