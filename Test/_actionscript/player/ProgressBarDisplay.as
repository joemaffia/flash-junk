package player
{
    import flash.display.*;
    import flash.events.*;
	import flash.utils.*;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter;
	
	// -------------------------------------------------
	// Class ProgressBarDisplay
	// A class to show a clickable progress bar.
	//
	// Public events:
	//		ProgressBarDisplay.ACTION - reports a click on the progress bar
	//									use evt.target.newPosition to retrieve the clicked-on position as a value from 0 to 1.
	// -------------------------------------------------
    public class ProgressBarDisplay extends Sprite 
	{
		public static var ACTION:String = "action";
		private var pNewPosition:Number;
		
		// -------------------------------------------------
		// -------------------------------------------------
        public function ProgressBarDisplay() 
		{	
			pNewPosition = 0;
			
			// Draw progressbar background
			var progressBar:Sprite = new Sprite();
			progressBar.name = "progressBar";
			progressBar.graphics.beginFill(0x666666);
			progressBar.graphics.drawRect(0, 0, 200, 10);
			progressBar.x = 10;
			progressBar.y = 10;
			progressBar.addEventListener(MouseEvent.CLICK, handleClick);
			// Sprites normally are not automatically treated like buttons, so set button mode.
			progressBar.buttonMode = true;
			progressBar.useHandCursor = true;

			// Set a drop shadow for the whole progress bar
			var filter:DropShadowFilter = new DropShadowFilter(3, 45, 0x000000, 0.5, 3, 3, 0.65,
				BitmapFilterQuality.HIGH, false, false);
			var myFilters:Array = new Array();
            myFilters.push(filter);
            filters = myFilters; // Filters is an intrinsic property to the Sprite class

			addChild(progressBar);
			
			// Initialize the progress bar
			setProgress(0);
		}
		
		// -------------------------------------------------
		// Method: setProgress()  - Set the position of the progress bar
		// Parameters:
		//		progressFraction:Number - A number from 0 to 1 representing the progress amount to display.
		// -------------------------------------------------
		public function setProgress(progressFraction:Number):void
		{
			var progressBar:Sprite = Sprite(getChildByName("progressBar"));
			
			progressBar.graphics.clear();
			progressBar.graphics.beginFill(0xD0D0D0, 0.7);
			progressBar.graphics.lineStyle(1, 0xFFFFFF, 1.0);
			progressBar.graphics.drawRect(0, 0, 200, 10);
			progressBar.graphics.beginFill(0x4593A7, 1.0);
			progressBar.graphics.lineStyle();
			progressBar.graphics.drawRect(1, 1, Math.floor(202*progressFraction), 9);
		}
		
		// -------------------------------------------------
		// Method: handleClick() - Internal handler for the click event from the clickable sprite
		// Parameters:
		//		evt:Event - Event handle from the Sprite CLICK event
		// -------------------------------------------------
		private function handleClick(evt:MouseEvent):void
		{
			
			pNewPosition = evt.localX / 200;
			//trace(evt.localX/100);
			//trace("dispatching click");
			dispatchEvent(new Event(ACTION));
			//trace("click dispatched");
		}
		
		// -------------------------------------------------
		// Parameter getter: newPosition - Gets the position from 0 to 1 of the 
		// last mouse click on the progress bar
		// -------------------------------------------------
		public function get newPosition():Number
		{
			return pNewPosition;
		}
    }
}