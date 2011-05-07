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

// Adobe classes
//import flash.geom.*;
// Still support Flash 7:
import org.asapframework.util.types.*;

// ASAP classes
import org.asapframework.util.MovieClipUtils;


/**
Tooltip class.
@author Arthur Clemens
@use
You can customize a Tooltip by either setting properties after creation, or by creating a Tooltip subclass (see further below).

The following code creates a new tooltip:
<code>
var tip:Tooltip = new Tooltip("tip", _level0, 9999, "Click to enlarge");
tip.create();
tip.setLoc(new Point(100,100));
</code>
Change the tooltip properties: 
<code>
tip.backgroundColor = 0x990000;
tip.textColor = 0xffffff;
tip.textSize = 15;
tip.borderWidth = 0; // no border
</code>
Set a new text:
<code>
tip.setText("Click to go back");
</code>
After (dynamically) setting Tooltip properties, update must be called:
<code>
tip.update();
</code>
<hr />
To use <strong>embedded fonts</strong> in the Tooltip, the font should be available in the Flash movie - for instance by placing a dynamic text field with that font embedded offscreen. If you want to use "Monaco" for instance, write:
<code>
tip.fontName = "Monaco";
tip.textField.embedFonts = true;
tip.update();
</code>
<hr />
To use multiple lines, word wrap, set:
<code>
tip.textField.wordWrap = true;
</code>
<hr />
You can also create a Tooltip subclass. For example:
<code>
//import flash.geom.*;
// Still support Flash 7:
import org.asapframework.util.types.*;

import org.asapframework.ui.Tooltip;

class MCTooltip extends Tooltip {

	public function MCTooltip (inName:String, inTimeline:MovieClip, inDepth:Number, inText:String) {
		super(inName, inTimeline, inDepth, inText);
		// set custom properties
		backgroundColor = 0xffffff;
		borderAlpha = 20;
		fontName = "DIN-Light";
		textSize = 12;
		offset = new Point(2, -1);
		padding = new Point(2, 2);
		minWidth = 1;
		maxWidth = 200;
		// create clips
		create();
		textField.embedFonts = true;
		// set invisible to make it appear only on rollover the right spot
		clip._visible = false;
	}
	
}
</code>
@todo Fix unwanted wrapping with wordWrap true.
*/

class org.asapframework.ui.Tooltip {
	
	public var minWidth:Number = 50; /**< The minimum width of the tooltip, regardless the amount of text. */
	public var maxWidth:Number = 150; /**< The minimum width of the tooltip; more text will be displayed on multiple lines. */
	
	public var borderWidth:Number = 1; /**< Width of box border. Use 0 for no border. */
	public var borderColor:Number = 0x8D7F01; /**< Border color. */
	public var borderAlpha:Number = 50; /**< Alpha blend of border. */
	
	public var backgroundColor:Number = 0xFEF49C; /**< Background color; default light yellow. */
	public var backgroundAlpha:Number = 100; /**< Alpha blend of background. */
	
	public var fontName:String = "Arial"; /**< Font name. By default the font is not embedded - use <code>myTip.textField.embedFonts = true;</code> */
	public var textSize:Number = 11; /**< Size of text. */
	public var textColor:Number = 0x000000; /**< Color of text. */
	
	public var padding:Point; /**< The inside spacing between text and border. Default (1,0). */
	public var offset:Point; /**< The box offset position from the tip _x and _y position; default (0,0). */
	
	public var clip:MovieClip; /**< The Tooltip movieclip and holder of subclips backgroundClip and textField. */
	public var backgroundClip:MovieClip; /**< Background movieclip. The background color is a box that is drawn onto the background clip. */
	public var textField:TextField; /**< Text container. */
	public var textFormat:TextFormat; /**< TextFormat object of textField. */
	
	private var mName:String;
	private var mTimeline:MovieClip;
	private var mDepth:Number;
	private var mText:String;
	private var mSize:Point;
	private var mLoc:Point;
	
	private static var BACKGROUND_CLIP_NAME:String = "Tooltip_background_mc";
	private static var TEXTFIELD_CLIP_NAME:String = "Tooltip_textfield_tf";
	
	/**
	Creates a new Tooltip and optionally sets properties. Will not draw the clip: always call {@link #create} to create the Tooltip movieclip parts.
	@param inName : (optional) name of Tooltip movieclip on timeline inTimeline
	@param inTimeline : (optional) timeline of Tooltip movieclip
	@param inDepth : (optional) stack depth of Tooltip movieclip
	@param inText : (optional) Tooltip text contents; may contain html formatting 
	*/
	public function Tooltip (inName:String, inTimeline:MovieClip, inDepth:Number, inText:String) {
		
		if (inName != undefined) {
			mName = inName;
		}
		if (inTimeline != undefined) {
			mTimeline = inTimeline;
		}
		if (inDepth != undefined) {
			mDepth = inDepth;
		}
		if (inText != undefined) {
			mText = inText;
		}
		mLoc = new Point();
		mSize = new Point(0, textSize);
		offset = new Point();
		padding = new Point(1,0);
		textFormat = new TextFormat();
	}
	
	/**
	Sets a new Tooltip text and redraws.
	@param inText : text contents; may contain html formatting
	@implementationNote Calls {@link #update}
	*/
	public function setText (inText:String) : Void {
		mText = inText;
		textField.htmlText = mText;
		textField.setTextFormat(textFormat);
		update();
	}
	
	/**
	Sets the position of the Tooltip.
	@param inLoc : the new position relative of the Tooltip movieclip
	*/
	public function setLoc (inLoc:Point) : Void {
		mLoc = inLoc;
		updateLoc();
	}
	
	/**
	Updates and redraws the movieclip. Call this function after setting properties.
	*/
	public function update () : Void {
		updateTextFormat();
		updateSize();
		draw();
	}
	
	/**
	Creates the movieclip parts if they do not exist yet: the Tooltip clip, the background clip and the textfield. Sets default textfield properties.
	*/
	public function create () : Void {
		if (clip != undefined) {
			return;
		}
		clip = mTimeline.createEmptyMovieClip(mName, mDepth);
		if (clip == undefined) {
			trace("Tooltip create: could not create clip");
		}
		backgroundClip = clip.createEmptyMovieClip(BACKGROUND_CLIP_NAME, 1);
		drawBackground();
		
		clip.createTextField(TEXTFIELD_CLIP_NAME, 2, 0, 0, mSize.x, mSize.y);
		textField = clip.Tooltip_textfield_tf;
		textField.border = false;
		textField.autoSize = "left";
		textField.multiline = true;
		textField.html = true;
		textField.embedFonts = false;
		textField.selectable = false;
		textField.wordWrap = false;
		textField.mouseWheelEnabled = false;
		textField.condenseWhite = false;
		textField.htmlText = mText;
		
		updateTextFormat();
		updateSize();
		draw();
	}
	
	/**
	Removes the Tooltip clip parts and calls delete on itself.
	*/
	public function die () : Void {
		backgroundClip.removeMovieClip();
		clip.removeTextField(TEXTFIELD_CLIP_NAME);
		clip.removeMovieClip();
		delete this;
	}
	
	/**
	
	*/
	public function toString () : String {
		return "Tooltip: " + mName;
	}
	
	// PRIVATE METHODS
	
	/**
	
	*/
	private function updateTextFormat() : Void {
		textFormat.font = fontName;
		textFormat.color = textColor;
		textFormat.size = textSize;
		textField.setTextFormat(textFormat);
	}
	
	/**
	
	*/
	private function updateSize () : Void {
	
		var lineWidth = (borderWidth <= 0) ? 1 : borderWidth;

		var textWidth:Number = textField.textWidth;
		textWidth -= lineWidth;
		if (textWidth < minWidth) {
			textWidth = minWidth;
		}
		if (textWidth > maxWidth) {
			textWidth = maxWidth;
		}
		textField._width = textWidth;
		mSize.x = textField._width + 2*padding.x;
		
		var textHeight = textField.textHeight;
		textHeight -= lineWidth;
		textField._height = textHeight;
		mSize.y = textField._height + 2*padding.y;
	}
	
	/**
	
	*/
	private function draw () : Void {
		updateBackground();
		positionTextField();
	}
	
	/**
	
	*/
	private function updateLoc () : Void {
		clip._x = mLoc.x;
		clip._y = mLoc.y;
	}
	
	/**
	
	*/
	private function drawBackground () : Void {
		backgroundClip.clear();
		var hasBorder:Boolean = (borderWidth == 0) ? false : true;
		var borderProps:Array = [];
		if (hasBorder) {
			borderProps = [borderWidth, borderColor, borderAlpha];
		}
		MovieClipUtils.drawBox(backgroundClip, 0 + offset.x, -mSize.y + offset.y, mSize.x + offset.x, 0 + offset.y, borderProps, [backgroundColor, backgroundAlpha]);
	}
	
	/**
	
	*/
	private function updateBackground () : Void {
		drawBackground();
	}
	
	/**
	
	*/
	private function positionTextField () : Void {
		textField._x = padding.x + offset.x;
		textField._y = padding.y - mSize.y + offset.y;
	}
}