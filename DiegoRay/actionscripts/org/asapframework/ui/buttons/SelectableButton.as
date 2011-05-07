import org.asapframework.ui.buttons.DelayButton;
 
/**
Convenience class to create buttons with a "selected" state, for instance to be used in menus.
SelectableButton takes care of state management like event handling and the specific bahavior of the selected button. Subclasses only need to take care of drawing each button state: up, over and selected.

SelectableButton offers cascading functionality from superclasses:
<ul>
<li>Control timing with indelay, outdelay and afterdelay from {@link DelayButton}</li>
<li>Use setSendEventOnRoll and setSendEventOnPress to control dispatching of events ({@link EventButton})</li>
</ul>
@use
An example for a SelectableButton subclass, MenuButton:
<code>
import org.asapframework.ui.buttons.SelectableButton;

class MenuButton extends org.asapframework.ui.buttons.SelectableButton {

	private function drawUpState () : Void {
		gotoAndStop("up");
	}
	
	private function drawOverState () : Void {
		gotoAndStop("over");
	}
	
	private function drawSelectedState () : Void {
		gotoAndStop("selected");
	}
}
</code>
An example for a "next" button subclass that shows an disabled state:
<code>
class NextButton extends SelectableButton {

	public function NextButton () {
		super();
		setSendEventOnPress(true); // let the button send events on onPress
	}
	
	private function drawUpState () : Void {
		gotoAndStop("up");
	}
	
	private function drawOverState () : Void {
		gotoAndStop("over");
	}
	
	private function drawDisabledState () : Void {
		gotoAndStop("disabled");
	}
	
	private function drawEnabledState () : Void {
		gotoAndStop("up");
	}
}
</code>
@author Arthur Clemens
*/

class org.asapframework.ui.buttons.SelectableButton extends DelayButton {
	
	/**
	The state id. If a stage manager is used, the button is passed the unique state id to fetch the correct state when the button is clicked.
	*/
	private var mId:String;
	
	/**
	The selected state. Usually this means the button will be highlighted and not clickable.
	*/
	private var mSelected:Boolean = false;
	
	/**
	
	*/
	private var mEnabled:Boolean = true;

	/**
	Creates a new SelectableButton. Calls {@link #init} to initialize variables.
	*/
	public function SelectableButton () {
		super();
		init();
	}
	
	/**
	Calls {@link #updateSelectedState}.
	*/
	public function onLoad () {
		super.onLoad();
		updateSelectedState();
	}

	/**
	Implementation of {@link DelayButton} roll over method. 
	*/
	public function doRollOver () {
		if (mSelected) {
			return;
		}
		super.doRollOver();
		drawOverState();
    }
    
    /**
	Implementation of {@link DelayButton} roll out method. 
	*/
    public function doRollOut () {
    	if (mSelected) {
			return;
		}
		super.doRollOut();
		drawUpState();
	}
    
    /**
	Implementation of {@link DelayButton} release method. 
	*/
    public function doRelease () {
    	if (mSelected) {
			return;
		}
		super.doRelease();
    }
    
    /**
	Implementation of {@link DelayButton} press method. 
	*/
    public function doPress () {
    	if (mSelected) {
			return;
		}
		super.doPress();
    }
    
    /**
	Sets the button state to selected.
	*/
    public function select () : Void {
    	mSelected = true;
    	updateSelectedState();
    }
    
    /**
	Sets the button state to deselected.
	*/
    public function deselect () : Void {
    	mSelected = false;
    	updateSelectedState();
    }
    
    /**
	Sets the button to enabled of disabled. Use this method; do not call <code>.enabled</code> on the button directly.
	@param inState: true sets state to enabled; false to disabled
	*/
	public function setEnabled (inState:Boolean) : Void {
		if (inState == mEnabled) {
			return;
		}
		mEnabled = inState;
		enabled = mEnabled;
		updateEnabledState();
	}
	
	/**
	
	*/
    public function toString() : String {
		return "org.asapframework.ui.buttons.SelectableButton: " + _name;
	}
	
	/**
	Sets the state id.
	@param inId: the id
	*/
	public function setId (inId:String) : Void {
		mId = inId;
	}
	
	/**
	Gets the state id.
	@return The id.
	*/
	public function getId () : String {
		return mId;
	}
    
    // PRIVATE METHODS
    
    /**
    Initializes button properties; to be implemented by subclasses. For example, {@link DelayButton} timing properties can be set here.
    @example
    <code>
    private function init () : Void {
		setSendEventOnPress(true); // let the button send events on onPress
		indelay = .15; // DelayButton property: when rolled over, onRollOver is called after .15 seconds
	}
    </code>
    */
    private function init () : Void {
		//
	}
	
	/**
	Updates the visual state. Calls {@link #updateSelectedState} and {@link #updateEnabledState}.
	*/
	private function update () : Void {
		updateSelectedState();
		updateEnabledState();
	}
	
	/**
	Visually updates to selected state.
	@implementationNote Calls {@link #updateEnabledState updateEnabledState(!mSelected);}
	*/
	private function updateSelectedState () : Void {

		if (mSelected) {
			drawSelectedState();
		}
		if (!mSelected) {
			drawDeselectedState();
		}
		updateEnabledState(!mSelected);
	}
	
	/**
	Visually updates to enabled state.
	*/
	private function updateEnabledState () : Void {
		
		if (!mEnabled) {
			drawDisabledState();
		}
		if (mEnabled) {
			drawEnabledState();
		}
		
	}
	
    /**
	Subclasses implement visual behavior at "up" state.
	*/
	private function drawUpState () : Void {
		//
	}
	
	/**
	Subclasses implement visual behavior at "over" state.
	*/
	private function drawOverState () : Void {
		//
	}
	
	/**
	Subclasses implement visual behavior at "selected" state.
	*/
	private function drawSelectedState () : Void {
		//
	}
	
	/**
	Subclasses implement visual behavior at "selected" state. Default: drawUpState().
	*/
	private function drawDeselectedState () : Void {
		drawUpState();
	}

	/**
	Subclasses implement visual behavior at "disabled" state.
	*/
	private function drawDisabledState () : Void {
		//
	}
	
	/**
	Subclasses implement visual behavior at "enabled" state.
	*/
	private function drawEnabledState () : Void {
		//
	}

}