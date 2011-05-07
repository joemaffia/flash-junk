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

import org.asapframework.util.actionqueue.*;
import org.asapframework.util.ColorUtils;

/**
ActionQueue methods that control the color of a movieclip. Most methods call methods from {@link ColorUtils}.
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQColor {
	
	private static var START_VALUE:Number = 0; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 1; /**< End animation value to be returned to the perform function. */
	
	/**
	Set a movieclip's color to a color number (0xff3300) or string ("ff3300").
	@param inMC : the movieclip to set the color of
	@param inHexColor : hexadecimal number (0xff3300) or string ("ff3300") of the new color; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@example
	This example makes a movieclip red:
	<code>
	queue.addAction( AQColor.setColor, clip_mc, 0xff0000 );
	</code>
	THe following line makes it yellow:
	<code>
	queue.addAction( AQColor.setColor, clip_mc, "ffff00" );
	</code>
	@implementationNote Calls {@link ColorUtils#setColor}.
	*/
	public static function setColor (inMC:MovieClip,
									 inHexColor:Object) : Void {	
		ColorUtils.setColor(inMC, inHexColor);
	}
	
	/**
	Stores a color variable as "base color" property in the movieclip that can be referenced by {@link #setToBaseColor} and {@link #mixColors}.
	Use a base color when you plan to change the color of the movieclip, and you want to revert or animate back to the original set color. For instance, {@link AQColor#mixColors} allows to use the base color (using the string "base") as end color.
	To retrieve the set base color, call {@link ColorUtils#getBaseColor}.
	@param inMC : movieclip that will store the property
	@param inBaseColor : a color hex number (like 0xff3300) or hex string ("ff3300")
	@param inShouldSetColor : (optional) if true the movieclip's color is set using setRGB(baseColorNum); default is false (no color change)
	@implementationNote Calls {@link ColorUtils#setBaseColor}.
	*/
	public static function setBaseColor (inMC:MovieClip,
									 	 inBaseColor:Object,
									 	 inShouldSetColor:Boolean) : Void {
		ColorUtils.setBaseColor(inMC, inBaseColor, inShouldSetColor);
	}
	
	/**
	Restores the true color of the movieclip, making it appear as in the Library.
	@param inMC : movieclip to set the default color of
	@example
	The following code first sets the movieclip color to red, then restores it again:
	<code>
	queue.addAction( AQColor.setColor, clip_mc, 0xff0000 );
	queue.addAction( AQColor.restoreColor, clip_mc );
	</code>
	@implementationNote Calls {@link ColorUtils#restoreColor}.
	*/
	public static function restoreColor (inMC:MovieClip) : Void {
		ColorUtils.restoreColor(inMC);
	}
	
	/**
	Sets the color of a movieclip (back) to the color value stored in its base color.
	@param inMC : movieclip to set the color of
	@implementationNote Calls {@link ColorUtils#setToBaseColor}
	*/
	public static function setToBaseColor (inMC:MovieClip) : Void {
		ColorUtils.setToBaseColor(inMC);
	}
	
	/**
	Sets the color of a movieclip over a period of time by mixing two colors.
	@param inMC : movieclip to set the color of
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant change
	@param inStartColor : the start color; either: 1) a hexadecimal number (like 0xff0033 or -0xff0033) or hex string ("ff0033" of "-ff0033") or 2) the string "base": the base color that is set with {@link #setBaseColor}.
	@param inMixColor : the color to mix in; either: 1) a hexadecimal number or 2) the string "base"
	@param inPercentage : (optional) the amount of color of inMixColor that is mixed in baseColor; value between 0.0 and 1.0. A percentage of 0.5 with baseColor red and inMixColor yellow will result in orange; a percentage of 1.0 in yellow; default value is 1.0
	@param inComponentPercentage : (optional) the percentage value used for ra, ga, ba and aa; default 0 is assumed; use 100 to retain the transparency of pictures; use values greater than 100 for light effects
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	@example
	To mix two colors over a period of 1 second, use:
	<code>
	queue.addAction( AQColor.mixColors, my_mc, 1, 0xff0000, 0xffff00 );
	</code>
	The following code sets a movieclip to yellow, and adds a white tint on rollover:
	<code>
	ColorUtils.setBaseColor(my_mc, 0xffd633, true); // 'true' sets the color immediately
	...
	my_mc.onRollOver = function ()
	{
		var queue:ActionQueue = new ActionQueue();
		queue.addAction( AQColor.mixColors, this, 1, null, 0xffffff, 0.5 );
		queue.run();
	}
	</code>
	To animate the movieclip back to its original Library color, use a black color with a component percentage of 100:
	<code>
	queue.addAction( AQColor.mixColors, this, 1, null, 0x000000, 1.0, 100 );
	</code>
	@implementationNote Colors are mixed using Color.setTransform.
	*/
	public static function mixColors (inMC:MovieClip,
									  inDuration:Number,
									  inStartColor:Object,
									  inMixColor:Object,
									  inPercentage:Number,
									  inComponentPercentage:Number,
									  inEffect:Function) : ActionQueuePerformData {	
									  
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(7, arguments.length - 7);
		
		var base_r:Number, base_g:Number, base_b:Number;
		var mix_r:Number, mix_g:Number, mix_b:Number;
		var col:Color = new Color(inMC);
		var startColorNum:Number, mixColorNum:Number;
		
		if (inStartColor == null) {
			startColorNum = col.getRGB();
		} else if (inStartColor == "base") {
			startColorNum = ColorUtils.getBaseColor(inMC);
		} else {
			startColorNum = ColorUtils.getHexNumber(inStartColor);
		}
		
		// bit masking technique, see http://chattyfig.figleaf.com/ezmlm/ezmlm-cgi/1/28921 (Gary Fixler)
		base_r = (startColorNum & 0xFF0000) >> 16;
		base_g = (startColorNum & 0x00FF00) >> 8;
		base_b = startColorNum & 0x0000FF;
		
		if (inMixColor == null) {
			mixColorNum = col.getRGB();
		} else if (inMixColor == "base") {
			mixColorNum = ColorUtils.getBaseColor(inMC);
		} else {
			mixColorNum = ColorUtils.getHexNumber(inMixColor);
		}
		
		mix_r = (mixColorNum & 0xFF0000) >> 16;
		mix_g = (mixColorNum & 0x00FF00) >> 8;
		mix_b = mixColorNum & 0x0000FF;
		
		var percentage:Number = (inPercentage != undefined) ? inPercentage : 1.0;
		
		var t:Object = col.getTransform();
		var o:Object = new Object();
		o.mixValues = function (a:Number, b:Number, mix:Number) : Number {
			return ( a*(100-mix) + b*mix ) * 0.01;
		};
		var p:Number;
		var performFunction:Function = function (inPerc:Number) {
			// inPerc = percentage counting down from {@link #END_VALUE} to {@link #START_VALUE}
			p = inPerc * percentage * 100;
			t.ra = t.ga = t.ba = inComponentPercentage;
			t.rb = o.mixValues( base_r, mix_r, p );
			t.gb = o.mixValues( base_g, mix_g, p );
			t.bb = o.mixValues( base_b, mix_b, p );
			col.setTransform(t);
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}
	
	/**
	Sets the color of a movieclip over a period of time by mixing two colors, using two color transform objects, which gives greater control over the transparency of the color effect over time.
	@param inMC : movieclip to set the color of
	@param inDuration : length of animation in seconds
	@param inStartTransform : start color (color transformation object); use {@link ColorUtils#getTransformObject} to create a color transform object from a hex number
	@param inMixTransform : mix color (color transformation object)
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return The return value of {@link AQWorker#returnValue}.
	@example
	This example mixes two colors, created with {@link ColorUtils#getTransformObject}, over a period of 1 second:
	<code>
	var t1:Object = ColorUtils.getTransformObject(0x0066ff);
	var t2:Object = ColorUtils.getTransformObject(0x660000);
	queue.addAction( AQColor.mixTransforms, my_mc, 1, t1, t2 );
	</code>
	Use 0x000000 to give the movieclip its original color. The following code transforms the current color back to the original color over a period of 1 second:
	<code>
	var t2:Object = ColorUtils.getTransformObject(0x000000);
	queue.addAction( AQColor.mixTransforms, my_mc, 1, null, t2 );
	</code>
	@implementationNote Calls {@link ColorUtils#setMixTransform}.
	*/
	public static function mixTransforms (inMC:MovieClip,
									  	  inDuration:Number,
									  	  inStartTransform:Object,
									  	  inMixTransform:Object,
									  	  inEffect:Function) : ActionQueuePerformData {
									  	  
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(6, arguments.length - 6);
		
		var col:Color = new Color(inMC);
		var at:Object = inStartTransform;
		var bt:Object = inMixTransform;
		if (at == undefined) {
			at = col.getTransform();
		}
		if (bt == undefined) {
			bt = col.getTransform();
		}
		
		var performFunction:Function = function (inPerc:Number) : Boolean {
			// inPerc = percentage counting down from {@link #END_VALUE} to {@link #START_VALUE}
			ColorUtils.setMixTransform( inMC, at, bt, inPerc );
			return true;
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}
	
}