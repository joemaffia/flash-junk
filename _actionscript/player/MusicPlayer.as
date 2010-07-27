package player
{
    import flash.display.*;
    import flash.events.*;
	import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
	import flash.utils.*;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	
	// -------------------------------------------------
	// Class MusicPlayer
	// A class to manage MP3 playback of a single song. Provides
	// User interface controls and playback feedback.
	// -------------------------------------------------
    public class MusicPlayer extends Sprite 
	{
		private var pSong:Sound;
        private var pSongChannel:SoundChannel = new SoundChannel();
		private var pProgressBarDisplay:ProgressBarDisplay;
		private var pPlayButton:ButtonClass;
		private var pPauseButton:ButtonClass;
		private var pSongPosition:Number;
		private var pLastPosition:Number;
		public static var END_REACHED:String = "endReached";
		public static var SONG_LOADED:String = "songLoaded";
		
		private var songField:TextField = new TextField();

        public function MusicPlayer() 
		{
			// Sound object sticks around, used by SoundChannel class.
			// Set up sound instance, link to event handlers
            pSong = new Sound();
            pSong.addEventListener(Event.COMPLETE, completeHandler);
			pSong.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			
			
			// Create and position progress bar component
			
			pProgressBarDisplay = new ProgressBarDisplay();
			pProgressBarDisplay.x = 34;
			pProgressBarDisplay.y = 26;
			addChild(pProgressBarDisplay);
			pProgressBarDisplay.addEventListener(ProgressBarDisplay.ACTION, handleReposition);
			
			// Create and position play button
			pPlayButton = new ButtonClass(18, 18, "/_media/tests/deploy/bitmap/play.png");
			pPlayButton.x = 20;
			pPlayButton.y = 25;
			addChild(pPlayButton);
			pPlayButton.addEventListener(ButtonClass.ACTION, handlePlay);

			// Create and positoin pause button
			pPauseButton = new ButtonClass(18, 18, "/_media/tests/deploy/bitmap/pause.png");
			pPauseButton.x = 20;
			pPauseButton.y = 25;
			addChild(pPauseButton);
			pPauseButton.addEventListener(ButtonClass.ACTION, handlePause);
			pPauseButton.visible = false
			
			

			// Set up text format to be used for song label
            var songFormat:TextFormat = new TextFormat();
            songFormat.font = "_sans";
            songFormat.color = 0x666666;
            songFormat.size = 12;
			songFormat.align = "center";


			// Set up song label field
			songField.name = "songField";
			songField.x = 50;
			songField.y = 10;
			songField.width = 170;
			songField.height = 20;
            songField.defaultTextFormat = songFormat;
			songField.text = "Currently playing:";
            addChild(songField);
			
			pSongPosition = 0;
			
			
		}
		
		// -------------------------------------------------
		// Method: loadSong()
		// parameters: 
		//		songPath:String - URL pointing to location of MP3 file to load
		// -------------------------------------------------
		public function loadSong(songPath:String):void
		{
			var request:URLRequest = new URLRequest(songPath);

			if(pSongChannel) {
				pSongPosition = 0;
				pSongChannel.stop();
				pPlayButton.visible = true;
				pPauseButton.visible = false;
				dispatchEvent(new Event(END_REACHED));
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				songField.text = "";
				pSong = new Sound();
				pProgressBarDisplay.setProgress(0);
	            pSong.load(request);
			} else {
				pPlayButton.visible = true;
				pPauseButton.visible = false;
				dispatchEvent(new Event(END_REACHED));
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				songField.text = "";
				pSong = new Sound();
				pProgressBarDisplay.setProgress(0);
	            pSong.load(request);
			}
		}
		public function stopSong():void
		{
			if(pSongChannel) {
				pSongPosition = 0;
				pSongChannel.stop();
				pPlayButton.visible = true;
				pPauseButton.visible = false;
				dispatchEvent(new Event(END_REACHED));
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				songField.text = "";
				pSong = new Sound();
				pProgressBarDisplay.setProgress(0);
			}
		}
		
		// -------------------------------------------------
		// Method: completeHandler()
		// Internal method for responding to firing of sound file 
		// load complete event
		// parameters: 
		// -------------------------------------------------
        private function completeHandler(evt:Event):void 
		{
			dispatchEvent(new Event(SONG_LOADED));
			songField.text = "";
        }
		
		private function progressHandler(evt:ProgressEvent):void 
		{
			var loadedPct:uint = Math.round(100 * (evt.bytesLoaded / evt.bytesTotal));
			//trace("The sound is " + loadedPct + "% loaded.");
			songField.text = "The sound is " + loadedPct + "% loaded.";
		}

		
		// -------------------------------------------------
		// Method: enterFrameHandler()
		// Perform polling of sound file, send updates to progress bar
		// Also responsible for sending event when end of song reached.
		// -------------------------------------------------
		private function enterFrameHandler(event:Event):void
		{
			var progressAmount:Number = 0;
			progressAmount = event.target.pSongChannel.position / event.target.pSong.length;
			pProgressBarDisplay.setProgress(progressAmount);
			
			if (progressAmount >= 0.995 && pLastPosition == progressAmount)
			{
				// Terminate playback, broadcast event
				pSongPosition = 0;
				pSongChannel.stop();
				pPlayButton.visible = true;
				pPauseButton.visible = false;
				dispatchEvent(new Event(END_REACHED));
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				songField.text = "";
			}
			pLastPosition = progressAmount;
		}
		
		// -------------------------------------------------
		// Method: handleReposition()
		// Respond to clicking of progress bar
		// -------------------------------------------------
		private function handleReposition(evt:Event):void
		{
			pPlayButton.visible = false;
			pPauseButton.visible = true;
			
			if (pSongChannel != null && pSongChannel != undefined)
			{
				pSongChannel.stop();
			}
            pSongChannel = pSong.play(pSong.length * evt.target.newPosition);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			songField.text = "Playing";
		}
		
		// -------------------------------------------------
		// Method: handlePlay()
		// Respond to clicking of play button
		// -------------------------------------------------
		private function handlePlay(evt:Event):void
		{
			pPlayButton.visible = false;
			pPauseButton.visible = true;
            pSongChannel = pSong.play(pSongPosition);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			songField.text = "Playing";
		}

		// -------------------------------------------------
		// Method: handlePause()
		// Respond to clicking of pause button
		// -------------------------------------------------
		private function handlePause(evt:Event):void
		{
			pPlayButton.visible = true;
			pPauseButton.visible = false;
			pSongPosition = pSongChannel.position;
			trace(pSongPosition);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            pSongChannel.stop();
			songField.text = "Pause";
		}
	}
}