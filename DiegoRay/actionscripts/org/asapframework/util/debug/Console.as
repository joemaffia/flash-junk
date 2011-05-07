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
Console creates a debugging window on the stage that can be invoked with a configurable string. Close the window by double-clicking the bar.
@author Jeremy Brown, Arthur Clemens
@use
	The console is enabled by default. If you don't want to use the console, add this class to the exclude xml.
	You can set a character or word to activate the console. To set the activation string, use:
	<code>
	Console.sActivationString = "trace";
	</code>
The default activation string is "debug".
Hide the console by clicking on the top right button.
There are 5 log levels: DEBUG, INFO, WARN, ERROR and FATAL. Default is DEBUG_LEVEL. To set the log level (and to ignore messages of lower rank), use:
	<code>
	Console.logLevel = Console.DEBUG_LEVEL;
	</code>
	Example usage:
	<code>
	Console.INFO("Version: Mon 10 May 2004");
	Console.INFO("Environment: ", Environment.getEnvironment());
	</code>
@history 2 May 2005: Fixed bugs to enable for Flash 7; added a close button; when activationString is "", press space bar to make visible again.
@history 16 Jan 2005: Made the console enabled by default.
@history 28 Sep 2004: Optimized KeyListener.
@history 17 Sep 2004: Added strings "DEBUG", "INFO" etc to messages. Added double-click to hide window.
@todo
NICE:
Add a scrollbar
Add a clear button
Add error level buttons in the bar
Make the top bar visually more bar like, with a grip
*/

/*
// Older history:
@history 4 March 2004 - Changed class path from com.j3r.debug.JTrace to org.asapframework.util.logging.Console. This seemed ok according to author's instructions on http://www.j3r.com/?page=jtrace.
@history The original code relies heavily on getNextHighestDepth, but this is available only in Flash player 7. To use this class in Flash 6 projects, I made some checks for the value of getNextHighestDepth: if undefined, the maximum depth is used. You can also set the depth.
@history Added (clip stack) depth set and get. Default depth is 1048575.
@history Added alpha set and get. Default alpha = 65.
@history Added a bg to the textfield.
@history Added a text fmt to the textfield: font Monaco, size 9.
@history In authoring mode, trace is written to the console AND to the Flash trace window.
@history Added activation string: make the console visible by typing a string. You can set the string with activation: Console.activation = "hello"; Use an empty string to have the console always visible. Default string is 'trace'.
@history Added word wrap to text field.
@history Textfield now accepts additional passed arguments and prints them as a comma separated list.
@history The text field now scrolls to the bottom when new content is added, unless the field has keyboard focus: click in the text to stop scrolling, click somewhere else to update again.
@history The debug window can now be collapsed by clicking in the bar.
@history The level of error messages can be specified:
		Console.DEBUG("my message");
		Console.INFO("my message");
		Console.WARN("my message");
		Console.ERROR("my message");
		Console.FATAL("my message");
	Console.trace does still exist, and is equal to Console.DEBUG.
	Specify the log level to filter messages. To view only error messages for instance use:
		Console.logLevel = Console.ERROR_LEVEL;
@history Output is colorized by its error level, from blue to red.
*/

class org.asapframework.util.debug.Console {
	
	// Color scheme: http://www.meyerweb.com/eric/tools/color-blend/
	// DEBUG_LEVEL: blue
	// LEVEL_FATAL: red
	public static var DEBUG_LEVEL:Object =	{level:0, string:"Debug", color:"#0000CC"};	/**< Typecode for debugging messages.		*/
	public static var INFO_LEVEL:Object =	{level:1, string:"Info", color:"#550088"};	/**< Typecode for informational messages. 	*/
	public static var WARN_LEVEL:Object =	{level:2, string:"Warn", color:"#AA0044"};	/**< Typecode for warning messages.			*/
	public static var ERROR_LEVEL:Object =	{level:3, string:"Error", color:"#FF0000"};	/**< Typecode for error messages.			*/
	public static var FATAL_LEVEL:Object =	{level:4, string:"Fatal", color:"#FF0000"};	/**< Typecode for fatal error messages.		*/
	
	public static var DOUBLE_CLICK_DELAY:Number = 250;
	
	private static var sLogLevel:Number = DEBUG_LEVEL.level;
	
	private static var FONT_TYPE:String = "Verdana";
	private static var FONT_SIZE:Number = 10;
	private static var MAXDEPTH:Number = 1048575;
	private static var CONSOLE_COLOR:Number = 0x888888;
	
	private static var sHolderClip:MovieClip;
	private static var sIsEnabled:Boolean = true;
	private static var sOwner:Object = _root;
	private static var sOpenState:String = "open"; // "open", "minimized", "closed"
	
	private static var sWidth:Number = 400;
	private static var sHeight:Number = 300;
	private static var sHandleHeight:Number = 16;
	private static var sAlpha:Number = 65;
	private static var sDepth:Number = MAXDEPTH;
	private static var sBgColor:Number = 0xFFFFFF;
	private static var sActivationString:String = "debug";
	private static var sScrolls:Boolean = true;

	public static function DEBUG (objValue:Object) : Void
	{	
		assertWriteMessage(DEBUG_LEVEL, objValue); 
	}

	public static function INFO (objValue:Object) : Void
	{	
		assertWriteMessage(INFO_LEVEL, objValue); 
	}
	
	public static function WARN (objValue:Object) : Void
	{	
		assertWriteMessage(WARN_LEVEL, objValue); 
	}
	
	public static function ERROR (objValue:Object) : Void
	{	
		assertWriteMessage(ERROR_LEVEL, objValue); 
	}
	
	public static function FATAL(objValue:Object) : Void
	{	
		assertWriteMessage(FATAL_LEVEL, objValue); 
	}

	private static function assertWriteMessage(inLevel:Object, objValue:Object) : Void
	{
		arguments.shift();
		if (!(sLogLevel > inLevel.level) && sIsEnabled) {
			doWriteMessage(inLevel, arguments);
		}
	}

	public static function set logLevel(inLogLevel:Number) : Void
	{
		if (inLogLevel >= 0 && inLogLevel <= 6) sLogLevel = inLogLevel;
	}
	public static function set enabled(inIsEnabled:Boolean) : Void
	{
		sIsEnabled = inIsEnabled;
	}
	
	public static function set scroll(inScroll:Boolean)
	{
		sScrolls = inScroll;
	}
	
	public static function get state () : String
	{
		return sOpenState;
	}
	
	/**
	The text string to make the Console appear on screen.
	*/
	public static function set activationString (inString:String) : Void
	{
		sActivationString = inString;
	}
	/**
	Alpha of the background.
	*/
	public static function set alpha (inAlpha:Number) : Void
	{
		sAlpha = inAlpha;
	}
	
	private static function createConsole () : Void
	{
		var depth:Number;
		
		// holder
		depth = sOwner.getNextHighestDepth();
		if (depth == undefined) {
			depth = MAXDEPTH - 1; // if Flash player 6
		}
		sHolderClip = sOwner.createEmptyMovieClip("ConsoleHolder_mc", depth);
		sHolderClip._alpha = sAlpha;
		sHolderClip._visible = false;
		
		// text field bg
		depth = 1;
		var bg:MovieClip = sHolderClip.createEmptyMovieClip("background_mc", depth);
		bg.beginFill (sBgColor);
		bg.lineStyle (0, CONSOLE_COLOR, 100); // Yes, double alpha
		bg.moveTo(0,0);
		bg.lineTo(sWidth,0);
		bg.lineTo(sWidth,sHeight + 8); // 8 offset
		bg.lineTo(0,sHeight + 8);
		bg.lineTo(0,0);
		bg.endFill();
		
		// create a text field in the debug clip
		depth = 2;
		sHolderClip.createTextField("textfield_tf", depth, 0, 0, sWidth, sHeight-sHandleHeight);
		var tf:TextField = sHolderClip.textfield_tf;
		tf._y = sHandleHeight;
		tf.bg = false;
		tf.border = false;
		tf.wordWrap = true;
		tf.html = true;
		tf.multiline = true;

		tf.onSetFocus = function(oldFocus) {
			Console.scroll = false;
		};
		tf.onKillFocus = function(newFocus) {
			Console.scroll = true;
		};
		
		// text format sets default font and tab stops
		var fmt:TextFormat = new TextFormat();
		fmt.tabStops = [40];
		fmt.leftMargin = fmt.rightMargin = 4;
		fmt.indent = -4;
		tf.setTextFormat(fmt);
	
		// create a handle in the debug clip to move it around
		depth = 3;
		var refHandle:MovieClip = sHolderClip.createEmptyMovieClip("handle_mc", depth);
		refHandle.beginFill (CONSOLE_COLOR);
		refHandle.moveTo(0,0);
		refHandle.lineTo(sWidth,0);
		refHandle.lineTo(sWidth,sHandleHeight);
		refHandle.lineTo(0,sHandleHeight);
		refHandle.lineTo(0,0);
		refHandle.endFill();
		
		refHandle.owner = sHolderClip;
		refHandle.chrome = bg;
		
		refHandle.lastClicked = getTimer();
		refHandle.onPress = function() : Void
		{
			if ((this.lastClicked + Console.DOUBLE_CLICK_DELAY) > getTimer()) {
				Console.closeConsole();
			} else {
				this._parent.startDrag();
				this.startX = this.owner._x;
				this.startY = this.owner._y;
			}
			this.lastClicked = getTimer();
		};
		refHandle.onRelease = function() : Void
		{
			this._parent.stopDrag();
			if (this.owner._x == this.startX && this.owner._y == this.startY) {
				// not moved
				if (Console.state == "open") {
					Console.minimizeConsole();
				} else if (Console.state == "minimized") {
					Console.openConsole();
				}
			}			
		};
		
		// close button
		depth = 4;
		var h:Number = sHandleHeight-4;
		var w:Number = sHandleHeight-4;
		var rightOffset:Number = 2;
		var closeButton:MovieClip = sHolderClip.createEmptyMovieClip("close_btn", depth);
		closeButton._x = sWidth-w - rightOffset;
		closeButton._y = 2;
		closeButton.beginFill (0x990000);
		closeButton.moveTo(0,0);
		closeButton.lineTo(w,0);
		closeButton.lineTo(w,h);
		closeButton.lineTo(0,h);
		closeButton.lineTo(0,0);
		closeButton.endFill();
		
		closeButton.onRelease = function() : Void
		{
			Console.closeConsole();
		};
		
		var activationString:String = sActivationString;
		if (sActivationString.length == 0) {
			openConsole();
			activationString = " ";
		} else {
			closeConsole();
		}
		// Create a listener to make the console visible when the right keys are pressed
		var strlen:Number = activationString.length;
		var keysPressed:Array = new Array(strlen);
		var validTurnOnKeys:Array = new Array(strlen);
		for (var i:Number=0; i<strlen; ++i) {
			validTurnOnKeys[i] = activationString.charCodeAt(i);
		}
		var activationKeyString:String = validTurnOnKeys.toString();
		var curIndex:Number = 0;

		var myKeyListener:Object = new Object();
		myKeyListener.onKeyDown = function () {
			var a:Number = Key.getAscii();
			keysPressed[curIndex++] = a;

			if (a != validTurnOnKeys[curIndex-1]) {
				curIndex = 0;
			} else if ((curIndex == strlen) && (keysPressed.toString() == activationKeyString)) {
				Console.openConsole();
				Console.placeConsole();
				curIndex = 0;
			}
		};
		Key.addListener(myKeyListener);
	
	}

	public static function closeConsole () : Void
	{
		sHolderClip._visible = false;
		sHolderClip.textfield_tf._visible = true;
		sHolderClip.handle_mc.chrome._visible = true;
		sOpenState = "closed";
	}
	
	public static function minimizeConsole () : Void
	{
		sHolderClip.textfield_tf._visible = false;
		sHolderClip.handle_mc.chrome._visible = false;
		sOpenState = "minimized";
	}
	
	public static function openConsole () : Void
	{
		sHolderClip._visible = true;
		sHolderClip.textfield_tf._visible = true;
		sHolderClip.handle_mc.chrome._visible = true;
		sOpenState = "open";
	}
	
	public static function placeConsole () : Void
	{
		sHolderClip._x = _root._xmouse - (sHolderClip._width / 2);
		sHolderClip._y = _root._ymouse - 10;
	}
	
	private static function createPrintMessage () : String
	{
		var message:String = getTimer() + " - " + arguments.shift().toString();
		while (arguments.length > 0) {
			message += ", " + arguments.shift();
		}		
		return message;
	}
	
	private static function doWriteMessage (inLevel:Object) : Void
	{
		arguments.shift();
		var message:String = inLevel.string + "\t" + createPrintMessage(arguments);
		trace(message);
		writeToConsole(message, inLevel);
	}
	
	private static function writeToConsole(inMessage:String,
										   inLevel:Object) : Void
	{	
		if (sHolderClip == undefined) {
			createConsole();
		}
		if (sActivationString.length == 0) {
			openConsole();
		}
		
		var consoleText:String = "<font face='" + FONT_TYPE + "' size='" + FONT_SIZE + "' color='" + inLevel.color + "'>" + inMessage + "</font><br>";

		sHolderClip.textfield_tf.htmlText += consoleText;
		
		if (sScrolls) {
			sHolderClip.textfield_tf.scroll = sHolderClip.textfield_tf.maxScroll;
		}
		var depth:Number = sOwner.getNextHighestDepth();
		if (depth != undefined) {
			sHolderClip.swapDepths(depth);
		}
	}

}