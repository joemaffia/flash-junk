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

/**
MovieClip utility functions.
@author Arthur Clemens
*/

class org.asapframework.util.MovieClipUtils {

	/**
	Sets a movieclip to the center of the stage. 
	@param inMC : movieclip or button to set
	@param inOffset: (optional) movieclip offset as Point
	@example
	This example centers the movieclip on the stage, with an offset of (50, 0):
	<code>
	MovieClipUtils.centerOnStage( my_mc, new Point(50,0) );
	</code>
	*/
	public static function centerOnStage (inMC:MovieClip,
								   		  inOffset:Point,
								   		  inShouldCenter:Boolean) : Void {
		var x:Number = Stage.width / 2;
		var y:Number = Stage.height / 2;
		if (inOffset != undefined) {
			x += inOffset.x;
			y += inOffset.y;
		}
		if (inShouldCenter) {
			x -= (inMC._width / 2);
			y -= (inMC._height / 2);
		}
		inMC._x = x;
		inMC._y = y;
	}
	
	/**
	Inactivates the contents of a movieclip (including buttons and button clips), or activates it back again.
	@param inMC : movieclip or button whose contents should be set enabled or disabled
	@param inFlag : false (make inactive) or true (make active)
	@example
	You can disable all menu buttons in a menu, by calling <code>setActive(menu_mc, false)</code>.
	To activate the menu items again, call <code>setActive(menu_mc, true)</code>.
	@implementationNote The movieclip is given an empty event handler (onRelease) with useHandCursor set to false.
	*/
	public static function setActive (inMC:MovieClip,
							   		  inFlag:Boolean) : Void {
		if (!inFlag) {
			// Make inactive
			// Set a event that catches events from deeper movieclips
			inMC.onRelease = function () {};
			// Make de hand disappear
			inMC.useHandCursor = false;
		} else {
			// Make active again
			delete inMC.onRelease;
			inMC.useHandCursor = true;
		}
	}
	
	/**
	Calculates the scale factor of a movieclip to let it fit within given boundaries: when this scale factor is applied, the MovieClip is no wider than inMaxSize.x and no higher than inMaxSize.y.
	@param inMC: the movieclip to be scaled
	@param inMaxSize: the maximum width and heigth of the movieclip defined as a Point object; to force height (the scale factor is related to height only), pass a Point with null as x value; to force width (the scale factor is related to width only), pass a Point with null as y value
	@return The factor to apply to the scale of a movieclip to let it fit within the specified boundaries. This factor uses MovieClip scaling values (meaning 100 is the unscaled default value).
	@implementationNote The calculated factor is independent of already applied MovieClip scaling.
	@example
	For a picture gallery with picture frames of 150 wide and 100 high, to scale MovieClip mc to fit withing these boundaries, use:
	<code>
	var frameSize:Point = new Point(150,100);
	var normalScale:Number = MovieClipUtils.getNormalizedScale(mc, frameSize);
	mc._xscale = mc._yscale = normalScale;
	</code>
	<hr />
	Another example: image a Loader that loads images of unknown dimensions, while these images should fit within given picture boundaries. On the Loader's listener method ON_DONE you would call <code>getNormalizedScale</code> to fit the image in.<br />
	In the image class:
	<code>
	public function loadImage (inName:String, inUrl:String) : Void {
		loader.addEventListener(LoaderEvent.ON_DONE, this);
		loader.load( image_mc, inUrl, inName, true ); // sets the loaded image initially to visible:false
	}
	private function onLoadDone (e:LoaderEvent) : Void {
		var image:MovieClip = MovieClip(e.targetClip)
		var normalScale:Number = MovieClipUtils.getNormalizedScale(image, mSize);
		image._xscale = image._yscale = normalScale;
		// now show the movieclip
		image._visible = true;
	}
	</code>
	*/
	public static function getNormalizedScale (inMC:MovieClip, inMaxSize:Point) : Number {
		var w:Number = inMC._width / (0.01 * inMC._xscale); // calculate independent of stage scaling
		var h:Number = inMC._height / (0.01 * inMC._yscale); // calculate independent of stage scaling
		
		if (inMaxSize.x == null) {
			// force height
			return 100.0/h * inMaxSize.y;
		}
		if (inMaxSize.y == null) {
			// force width
			return 100.0/w * inMaxSize.x;
		}
		var scale_f:Number;
		if ((w/h) > (inMaxSize.x/inMaxSize.y)) {
			scale_f = 100.0/w * inMaxSize.x;
		} else {
			scale_f = 100.0/h * inMaxSize.y;
		}
		return scale_f;
	}
	
	/**
	Draws a box in a movieclip.
	@param inMC: the movieclip to draw the box into
	@param inLeft: the left coordinate of the box in pixels
	@param inTop: the top coordinate of the box in pixels
	@param inRight: the right coordinate of the box in pixels
	@param inBottom: the bottom coordinate of the box in pixels
	@param inLineProperties: an array of line properties: line width, line rgb color and line alpha, for example: <code>[0, 0xff0000,100]</code> (see MovieClip.lineStyle)
	@param inFillProperties: an array of fill properties: fill rgb color and fill alpha, for example: <code>[0x8888ff, 5]</code>
	@example
	The following code draws a box of 80 pixels wide, centered, with a red hairline and a half-transparent yellow fill:
	<code>
	MovieClipUtils.drawBox(my_mc, -40, -40, 40, 40, [0, 0xff0000, 100], [0xffff00, 50]);
	</code>
	To draw a box without border, pass an empty line properties array:
	<code>
	MovieClipUtils.drawBox(my_mc, -40, -40, 40, 40, [], [0xffff00, 50]);
	</code>
	*/
	public static function drawBox (inMC:MovieClip, inLeft:Number, inTop:Number, inRight:Number, inBottom:Number, inLineProperties:Array, inFillProperties:Array) : Void {
		// use apply to send line array variables to lineStyle function
		inMC.lineStyle.apply(inMC, inLineProperties);
		// use apply to send line array variables to beginFill function
		inMC.beginFill.apply(inMC, inFillProperties);
		// start drawing from upper left going around counter-clockwise 
		inMC.moveTo(inLeft, inTop);
		inMC.lineTo(inLeft, inBottom);
		inMC.lineTo(inRight, inBottom);
		inMC.lineTo(inRight, inTop);
		inMC.lineTo(inLeft, inTop);
		inMC.endFill();
	}
	
}
