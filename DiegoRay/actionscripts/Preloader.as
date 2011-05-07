class Preloader extends MovieClip{

	private var target_mc:MovieClip;
	private var progress_mc:MovieClip;
	private var pct_str:String;
	
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;
		
	function Preloader(){
		// initialize with EventDispatcher so the preloader can broadcast events
		mx.events.EventDispatcher.initialize(this);
	}
	
	public function startPreload(t:MovieClip){
		// set a reference to the timeline that is loading
		target_mc = t;
		
		// reveal the preloader clip
		this.gotoAndPlay("IN");
	}
	
	private function onAnimateIn(){
		this.stop();
		
		// this is called from the preloader mc timeline on the last frame of the 'in' animation
		// starts checking the load progress of the target movie clip on each frame
		this.onEnterFrame = this.checkLoadProgress;	
	}
	
	private function checkLoadProgress(){
		// get the total bytes and the loaded bytes of the target clip
		var bl = target_mc.getBytesLoaded();
		var bt = target_mc.getBytesTotal();
		
		// calculate the percentage of bytes loaded
		var pct = bl/bt;
				
		// get the current frame and total frames of the progress clip
		var cf = progress_mc._currentframe;
		var tf = progress_mc._totalframes;
		
		// calculate the frame that corresponds with the load percentage
		var f = Math.ceil(tf * pct);
		
		// if the current frame of the progress mc is less than the value of f then let the clip play
		// otherwise, stop the progress clip to wait for f to catch up with the current frame
		// this prevents the animation from jumping ahead if the target clip is loading faster than
		// your progress animation
		if(f > cf){
			progress_mc.play();
		}else{
			progress_mc.stop();
		}
		
		// set percent display in preloader_mc based on percentage of frames that have played
		this.pct_str = (Math.round(cf/tf * 100)).toString();
		
		// if the clip is entirely loaded, and the progress clip has played all the way through
		// then the preloading is complete
		if(bt > 20 && bl == bt && cf == tf && progress_mc){
			onPreloadComplete();
		}
	}
	
	private function onPreloadComplete(){
		// stop the check load call
		this.onEnterFrame = null;
		
		// animate the preloader
		this.gotoAndPlay("OUT");
	}
	
	
	private function onAnimateOut(){
		this.stop();
		
		// dispatch event that tells any listeners that the preloader is done
		dispatchEvent({target:this, type:'onPreloaderOut'});
	}
}