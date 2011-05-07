//
//  AppController
//
//  Created by Dr. Joe Maffia on 2007-10-07.
//

import org.asapframework.management.movie.LocalController;
import org.asapframework.management.sound.SoundManager;
import org.asapframework.ui.buttons.EventButton;
import org.asapframework.ui.buttons.EventButtonEvent;
import org.asapframework.events.Event; 
import org.asapframework.util.actionqueue.*;
import org.asapframework.util.MovieClipUtils;
import com.mosesSupposes.fuse.*;
import org.asapframework.util.watch.Watcher;


class AppController extends LocalController {
	
    /**
    A button on the stage.
    */
    private var $homeButton:EventButton;
    private var $newsButton:EventButton;
    private var $biographyButton:EventButton;
    private var $discographyButton:EventButton;
    private var $galleryButton:EventButton;
    private var $contactButton:EventButton;
    private var $myspaceButton:EventButton;
	private var $playerButton:EventButton;
	private var $spectro:EventButton;
	
	//Player
	private var $player_playButton:EventButton;
	private var $player_stopButton:EventButton;
	private var $player_nextButton:EventButton;
	private var $player_prevButton:EventButton;
	private var $player_closeButton:EventButton;

    // array for all the menu and menu with reflection
    private var $menu:Array = new Array ();
    private var $menuR:Array = new Array ();
	
    // sound manager
	private var theSoundManager:SoundManager;
					
	public function AppController (inTimeline:MovieClip) {
		super(inTimeline);
		ZigoEngine.register(Fuse, PennerEasing, CustomEasing);
	
	    // set reference to button in stage. Note that this
        // button is based on EventButton, so it will automatically
        // fire the 'onEventButtonRelease' event to our Controller class
        $homeButton = EventButton(mTimeline.homeTitle);
        $newsButton = EventButton(mTimeline.newsButton);
        $biographyButton = EventButton(mTimeline.biographyButton);
        $discographyButton = EventButton(mTimeline.discographyButton);
        $galleryButton = EventButton(mTimeline.galleryButton);
        $contactButton = EventButton(mTimeline.contactButton);
    	$myspaceButton = EventButton(mTimeline.myspaceButton);
		
		//Player
		$playerButton = EventButton(mTimeline.playerButton);
		$spectro = EventButton(mTimeline.spectro);
		$player_playButton = EventButton(mTimeline.mask.player_play);
		$player_stopButton = EventButton(mTimeline.mask.player_stop);
		$player_nextButton = EventButton(mTimeline.mask.player_next);
		$player_prevButton = EventButton(mTimeline.mask.player_prev);
		$player_closeButton = EventButton(mTimeline.mask.player_close);
		
		$menu[0] = $newsButton;
		$menu[1] = $biographyButton;
		$menu[2] = $discographyButton;
		$menu[3] = $galleryButton;
		$menu[4] = $contactButton;
		
		$menuR[0] = mTimeline.newsButtonR;
		$menuR[1] = mTimeline.biographyButtonR;
		$menuR[2] = mTimeline.discographyButtonR;
		$menuR[3] = mTimeline.galleryButtonR;
		$menuR[4] = mTimeline.contactButtonR;
		
		theSoundManager = SoundManager.getInstance();
 	}

	public static function main (inTimeline:MovieClip) : Void {
 		var controller:AppController = new AppController(inTimeline);
		inTimeline.controller = controller;
 		controller.start();  
	}
	
	public function start () : Void {
				
		// the 'mTimeline' property references to the main
		// mTimeline fo the SWF we're controlling.
		 
		// stop the mTimeline from playing (in case an animation is going on)
		mTimeline.stop();
		
		// if you want to catch additional events coming from an
        // EventButton-based button, you can enable them like this:
 		
 		$homeButton.setSendEventOnRoll(true);
		$homeButton.setSendEventOnPress(true);
 		
 		$newsButton.setSendEventOnRoll(true);
		$newsButton.setSendEventOnPress(true);
		
		$biographyButton.setSendEventOnRoll(true);
		$biographyButton.setSendEventOnPress(true);
		
		$discographyButton.setSendEventOnRoll(true);
		$discographyButton.setSendEventOnPress(true);
		
		$galleryButton.setSendEventOnRoll(true);
		$galleryButton.setSendEventOnPress(true);
		
		$contactButton.setSendEventOnRoll(true);
		$contactButton.setSendEventOnPress(true); 
		
		$myspaceButton.setSendEventOnRoll(true);
		$myspaceButton.setSendEventOnPress(true);
		
		//Player
		$playerButton.setSendEventOnRoll(true);
		$playerButton.setSendEventOnPress(true);
		$spectro.setSendEventOnRoll(true);
		$spectro.setSendEventOnPress(true);
		$player_playButton.setSendEventOnRoll(true);
		$player_playButton.setSendEventOnPress(true);
		$player_stopButton.setSendEventOnRoll(true);
		$player_stopButton.setSendEventOnPress(true);
		$player_nextButton.setSendEventOnRoll(true);
		$player_nextButton.setSendEventOnPress(true);
		$player_prevButton.setSendEventOnRoll(true);
		$player_prevButton.setSendEventOnPress(true);
		$player_closeButton.setSendEventOnRoll(true);
		$player_closeButton.setSendEventOnPress(true);
		
		
		// played sounds need a MovieClip
		theSoundManager.addMovie("main", mTimeline);
		theSoundManager.addSound("mfx_electric7", "main");
		theSoundManager.addSound("mfx_electric11", "main");
		theSoundManager.addSound("mfx_electric12", "main");
        
		//
        loadStage();
	}
	
	//unmask the stage
	public function loadStage() {
		
		mTimeline.homeMovie._visible = true;
		mTimeline.frameFX._alpha = 0;
		mTimeline.bkg._alpha = 0;
		
		for (var i=0; i<5; i++ ) {
			$menu[i]._alpha = 0;
			$menuR[i]._alpha = 0;
			ZigoEngine.doTween($menu[i], '_alpha', 100, Math.random()+2, 'easeInBounce');
			ZigoEngine.doTween(mTimeline.bkg, '_alpha', 100, 2, 'easeOutBounce');		
			
		}
		
		ZigoEngine.doTween($menuR[0], '_alpha', 100, 2, 'linear');
		ZigoEngine.doTween($menuR[1], '_alpha', 100, 2, 'linear');
		ZigoEngine.doTween($menuR[2], '_alpha', 100, 2, 'linear');
		ZigoEngine.doTween($menuR[3], '_alpha', 100, 2, 'linear');
		ZigoEngine.doTween($menuR[4], '_alpha', 100, 2, 'linear');
		
		//loadFrameFX();
		var watcher:Watcher = new Watcher(mTimeline.bkg, "_alpha", 100, 1/60);
		watcher.setAfterMethod(this, "loadFrameFX");
		watcher.start();
		
		var watcher:Watcher = new Watcher(mTimeline.frameFX, "_currentFrame", 26, 1/60);
		watcher.setAfterMethod(this, "homeSection");
		watcher.start();
	}

    
	public function loadFrameFX() {
		
		var queue:ActionQueue = new ActionQueue("loadframeFX");
		//event listener
		queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
		queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);
		queue.addEventListener(ActionQueueEvent.QUEUE_QUIT, this);
		//action
		queue.addAction( AQTimeline.gotoAndPlay, mTimeline.frameFX, 2 );
		queue.addAction( ZigoEngine.doTween, mTimeline.frameFX, '_alpha', 100, 2, 'linear' );
		queue.run();
	}
	public function unloadFrameFX() {
		var queue:ActionQueue = new ActionQueue("unloadframeFX");
		//event listener
		queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
		queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);
		queue.addEventListener(ActionQueueEvent.QUEUE_QUIT, this);
		//action
		queue.addAction( AQTimeline.gotoAndPlay, mTimeline.frameFX, 28 );
		queue.addAction( ZigoEngine.doTween, mTimeline.frameFX, '_alpha', 0, 2, 'linear' );
		queue.run();
		
		var watcher:Watcher = new Watcher(mTimeline.frameFX, "_alpha", 0, 1/60);
		watcher.setAfterMethod(this, "loadFrameFX");
		watcher.start();
	}
	
	
	public function loadMask() {
		toggleObjects(0, mTimeline);
		ZigoEngine.doTween(mTimeline.mask, '_alpha', 100, 1, 'easeOutExpo');
	}
	
	public function unloadMask() {
		ZigoEngine.doTween(mTimeline.playerButton.infoPlayer,  '_alpha', 100, 0, 'easeInCirc');
		ZigoEngine.doTween(mTimeline.playerButton.tooltip,  '_alpha', 0, 0, 'easeInCirc');
		toggleObjects(1, mTimeline);
		ZigoEngine.doTween(mTimeline.mask, '_alpha', 0, 1, 'easeOutExpo');
	}
 
    /**
     * 
     * EVENTS
     * 
     */	
  
	/**
    This event is automatically fired by all buttons based on EventButton.
    */
    public function onEventButtonRelease ( e:EventButtonEvent ) : Void {
        //showFeedback(e.buttonName + ": released");
        ZigoEngine.doTween(e.target, '_brightness', 0, 0.5, 'easeInCirc');
    }
    
    /**
    This event is automatically fired by all buttons based on EventButton 
    * if <code>setSendEventOnPress</code> has been set to 'true': <code>myButton.setSendEventOnPress(true)</code>;
    */
    public function onEventButtonPress ( e:EventButtonEvent ) : Void {
        //showFeedback(e.buttonName + ": pressed");
    	ZigoEngine.doTween(e.target, '_brightness', 100, 0, 'easeInCirc');
		theSoundManager.playSound("mfx_electric11");
	
	    switch (e.buttonName) {
	   		case 'homeTitle': unloadFrameFX(); loadHome(); break;
	   		case 'newsButton': unloadFrameFX(); loadNews(); break;
	       	case 'biographyButton': unloadFrameFX(); loadBiography(); break;
	       	case 'discographyButton': unloadFrameFX(); loadDiscography(); break;
	       	case 'galleryButton': unloadFrameFX(); loadGallery(); break;
	       	case 'contactButton': unloadFrameFX(); loadContact(); break;
			case 'myspaceButton': getURL("http://myspace.com/diegoray","_blank"); break;
			case 'playerButton': loadMask(); break;
			case 'spectro': toggleMute(); break;
			case 'player_close': unloadMask(); break;
			case 'player_play': mTimeline.mask.myPlayer.play(); mTimeline.spectro.loop(100); break;
			case 'player_stop': mTimeline.mask.myPlayer.stop(); mTimeline.spectro.stop(0); break;
			case 'player_next': mTimeline.mask.myPlayer.dspNextItem(); mTimeline.spectro.loop(100); break;
			case 'player_prev': mTimeline.mask.myPlayer.dspPrevItem(); mTimeline.spectro.loop(100); break;
	       	default: ;break;
	   }
       
    }
    
    /**
    This event is automatically fired by all buttons based on EventButton 
    * if <code>setSendEventOnRoll</code> has been set to 'true': <code>myButton.setSendEventOnRoll(true);</code>
    */
    public function onEventButtonRollOver ( e:EventButtonEvent ) : Void {
		//showFeedback(e.buttonName + ": rollover");
		if (e.buttonName=='myspaceButton') {
			ZigoEngine.doTween(e.target,  '_invertColor', 100, 0, 'easeInCirc');
			theSoundManager.playSound("mfx_electric7"); 
		} else if (e.buttonName=='playerButton') {
			ZigoEngine.doTween(e.target.infoPlayer,  '_alpha', 0, 0.2, 'easeInCirc');
			ZigoEngine.doTween(e.target.tooltip,  '_alpha', 100, 0.2, 'easeInCirc');
			theSoundManager.playSound("mfx_electric7");
		} else {
			ZigoEngine.doTween(e.target, '_brightness', 80, 0, 'easeInCirc');
			theSoundManager.playSound("mfx_electric12");
		}
    }
    
    /**
    This event is automatically fired by all buttons based on EventButton 
    * if <code>setSendEventOnRoll</code> has been set to 'true': <code>myButton.setSendEventOnRoll(true);</code>
    */
    public function onEventButtonRollOut ( e:EventButtonEvent ) : Void {
		//showFeedback(e.buttonName + ": rollout");
		ZigoEngine.doTween(e.target, '_brightness', 0, 0.5, 'easeInCirc');
		if (e.buttonName=='playerButton') {
			ZigoEngine.doTween(e.target.infoPlayer,  '_alpha', 100, 0.2, 'easeInCirc');
			ZigoEngine.doTween(e.target.tooltip,  '_alpha', 0, 0.2, 'easeInCirc');
		}
	}
    
    
    /**
     * 
     * Menu Section
     * 
     */ 	
        
    public function loadHome() {
    	mTimeline.holder_mc.unloadMovie();
		var watcher:Watcher = new Watcher(mTimeline.frameFX, "_currentFrame", 26, 1/60);
		watcher.setAfterMethod(this, "homeSection");
		watcher.start();
    }
        
    private function homeSection() {
  		mTimeline.holder_mc.attachMovie("homeMovie","homeMovie",1);
		mTimeline.holder_mc.homeMovie._alpha = 0;
  		var queue:ActionQueue = new ActionQueue("homeSection");
		//event listener
		queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
		queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);
		//action
		queue.addPause(1);
		queue.addAction( ZigoEngine.doTween, mTimeline.holder_mc.homeMovie, '_alpha', 100, 1, 'linear' );
		queue.addPause(1);
		queue.addAction( AQTimeline.gotoAndPlay, mTimeline.holder_mc.homeMovie, 2 );
		queue.run();	
	} 
    
    public function loadNews() {
    	mTimeline.holder_mc.unloadMovie();
		var watcher:Watcher = new Watcher(mTimeline.frameFX, "_currentFrame", 26, 1/60);
		watcher.setAfterMethod(this, "newsSection");
		watcher.start();
    }
    private function newsSection() { 
        	mTimeline.holder_mc.attachMovie("xmlNews","xmlNews",1);
	        mTimeline.holder_mc.xmlNews._alpha = 0;
        	var queue:ActionQueue = new ActionQueue("newsSection");
	    	//event listener
			queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
			queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);
			//action
			queue.addPause(1);
			queue.addAction( ZigoEngine.doTween, mTimeline.holder_mc.xmlNews, '_alpha', 100, 1, 'linear' );
			queue.run();	
    }
    
    public function loadBiography() {
    	mTimeline.holder_mc.unloadMovie();
		var watcher:Watcher = new Watcher(mTimeline.frameFX, "_currentFrame", 26, 1/60);
		watcher.setAfterMethod(this, "biographySection");
		watcher.start();
    }
    private function biographySection() {
			mTimeline.holder_mc.attachMovie("xmlBiography","xmlBiography",1);
		    mTimeline.holder_mc.xmlBiography._alpha = 0;
    		var queue:ActionQueue = new ActionQueue("xmlBiography");
	    	//event listener
			queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
			queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);
			//action
			queue.addPause(1);
			queue.addAction( ZigoEngine.doTween, mTimeline.holder_mc.xmlBiography, '_alpha', 100, 1, 'linear' );
			queue.run();	
    }
    
    public function loadDiscography() {
    	mTimeline.holder_mc.unloadMovie();
		var watcher:Watcher = new Watcher(mTimeline.frameFX, "_currentFrame", 26, 1/60);
		watcher.setAfterMethod(this, "discographySection");
		watcher.start();
    }
    private function discographySection() {
    	mTimeline.holder_mc.attachMovie("coverFlow","coverFlow",1);
	    mTimeline.holder_mc.coverFlow._alpha = 0;
	    MovieClipUtils.setActive(mTimeline.holder_mc.coverFlow, false);
    	var queue:ActionQueue = new ActionQueue("coverFlow");
    	//event listener
		queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
		queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);	
		//action
		queue.addPause(1);
		queue.addAction( ZigoEngine.doTween, mTimeline.holder_mc.coverFlow, '_alpha', 100, 1, 'linear' );
		queue.addAction( MovieClipUtils.setActive, mTimeline.holder_mc.coverFlow, true );
		queue.run();
    }
    
    public function loadGallery() {
    	mTimeline.holder_mc.unloadMovie();
		var watcher:Watcher = new Watcher(mTimeline.frameFX, "_currentFrame", 26, 1/60);
		watcher.setAfterMethod(this, "gallerySection");
		watcher.start();
    }
    private function gallerySection() {
    	mTimeline.holder_mc.attachMovie("xmlGallery","xmlGallery",1);
    	mTimeline.holder_mc.xmlGallery._alpha = 0;
    	var queue:ActionQueue = new ActionQueue("xmlGallery");
    	//event listener
		queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
		queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);
		//action
		queue.addPause(1);
		queue.addAction( ZigoEngine.doTween, mTimeline.holder_mc.xmlGallery, '_alpha', 100, 1, 'linear' );
		queue.run();	
	}
    
	public function loadContact() {
    	mTimeline.holder_mc.unloadMovie();
		var watcher:Watcher = new Watcher(mTimeline.frameFX, "_currentFrame", 26, 1/60);
		watcher.setAfterMethod(this, "contactSection");
		watcher.start();
    }

    private function contactSection() {
    	mTimeline.holder_mc.attachMovie("contact","contact",1);
	    mTimeline.holder_mc.contact._alpha = 0;
		var queue:ActionQueue = new ActionQueue("contact");
    	//event listener
		queue.addEventListener(ActionQueueEvent.QUEUE_STARTED, this);
		queue.addEventListener(ActionQueueEvent.QUEUE_FINISHED, this);
		//action
		queue.addPause(1);
		queue.addAction( ZigoEngine.doTween, mTimeline.holder_mc.contact, '_alpha', 100, 1, 'linear' );
		queue.run();
    }

	private function toggleMute() {
		switch ($spectro._alpha) {
			case 100:
				ZigoEngine.doTween($spectro, '_alpha', 66, 0.5, 'easeInCirc');
				mTimeline.mask.myPlayer.volume = 66;
				break;
			case 65.625:
				ZigoEngine.doTween($spectro, '_alpha', 33, 0.5, 'easeInCirc');
				mTimeline.mask.myPlayer.volume = 33;
				break;
			default: 
				ZigoEngine.doTween($spectro, '_alpha', 100, 0.5, 'easeInCirc');
				mTimeline.mask.myPlayer.volume = 100;
				break;
		}
	}
    // PRIVATE METHODS
    
    /**
    * a quick trace/debug
    * and different EventListener
    */
    private function showFeedback ( inText:String ) : Void {
    	trace(inText);
    }
    public function onActionQueueStarted (e:ActionQueueEvent) : Void {
    	//showFeedback("queue " + e.name + " has started");
	}
	public function onActionQueueFinished (e:ActionQueueEvent) : Void {
	    //showFeedback("queue " + e.name + " has finished");
	    //to make sure eache queue will be destroyed otherwise this will lead to a memory leak
	    e.target.quit();
	}
	public function onActionQueueQuit (e:ActionQueueEvent) : Void {
	    //showFeedback("queue " + e.name + " quit");
	}
	
	/*
    * Disable/Enable utility
    *
	* Recursive function that can disable/enable objects.
	* 0=disable
	* 1=enable
	*/
	public function toggleObjects(toggle:Number, scope:Object, stack:Array):Void
	{
		// create a stack to avoid circular references
		if (!stack) var stack:Array = [];

		//trace ("SCOPE: "+scope);
		if (scope+""!="_level0.mask") {
			var j:Number;
			var i:String;
			var circular:Boolean;
			for (i in scope)
			{ 
				if (typeof (scope[i]) == "movieclip")
				{ 
					// search the stack to make sure we not looking at a circular reference to an anscestor movieclip
					circular = false;
					j = stack.length;
					while (j--) {
						if (scope[i] === stack[j]) {
							circular = true;
							break;
						}
					}

					// avoid any anscestors
					if (!circular) {
						//trace("scope[name] = "+scope[i]);
						//trace("I have a movie clip child named "+i);
						//trace("Disabling: "+scope[i]);
						if (toggle==0) {
							scope[i].enabled = false;
						} else {
							scope[i].enabled = true;
						}
						// add this clip to the stack 
						stack.push(scope[i]);

						// recurse down the branch
						toggleObjects(toggle, scope[i], stack);

						// done this branch so pop the stack
						stack.pop();
					}
				} 
				else if (typeof(scope[i]) == "object")
				{
					if (scope[i].enabled)
					{
						scope[i].enabled = false;
					}else {
						scope[i].enabled = true;
					}
				}
			}
		}
	}
	
}
