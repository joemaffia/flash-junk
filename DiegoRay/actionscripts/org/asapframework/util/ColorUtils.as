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
A collection of color utility functions.
@author Arthur Clemens
*/

class org.asapframework.util.ColorUtils {

	/**
	Retrieves the hex number (0xff0033) from a hex number or hex string ("ff0033").
	@param inHexColor : a hex number (0xff0033) or hex string ("ff0033")
	@return A hex number (for instance 0xff3300).
	*/
	public static function getHexNumber (inHexColor:Object) : Number {
		if (typeof(inHexColor) == "number") {
			return Number(inHexColor);
		} else if (typeof(inHexColor) == "string") {
			return parseInt( String(inHexColor), 16);
		}
	}
	
	/**
	Returns a hex number (<code>0xff0033</code> or <code>6697932</code>) as a hexadecimal String, for instance <code>"ff0033"</code>.
	@param inHexColorNumber : a hex number (0xff0033 or 6697932)
	@return A hex String (for instance "ff3300").
	*/
	public static function getHexString (inHexColorNumber:Number) : String {
		return inHexColorNumber.toString(16);
	}
	
	/**
	Set a movieclip's color to a color number (0xff3300) or string ("ff3300").
	@param inMC : the movieclip to set the color of
	@param inHexColor : hexadecimal number (0xff3300) or string ("ff3300") of the new color; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@example
	This example turns a movieclip red:
	<code>
	ColorUtils.setColor( clip_mc, 0xff0000 );
	</code>
	THe following line makes it yellow:
	<code>
	ColorUtils.setColor( clip_mc, "ffff00" );
	</code>
	@implementationNote Calls Color.setRGB(hexColorNum).
	*/
	public static function setColor (inMC:MovieClip,
									 inHexColor:Object) : Void {	
		var col:Color = new Color(inMC);
		var hexColorNum:Number = ColorUtils.getHexNumber(inHexColor);
		col.setRGB(hexColorNum);
	}
	
	/**
	Sets the movieclip's colors using Color.setTransform.
	@param inMC : movieclip which color should be transformed
	@param inTransformObject : the color transform object to set the movieclip's color.
	A transform object has these properties:
	<blockquote>
	ra is the percentage for the red component (-100 to 100)
	rb is the offset for the red component (-255 to 255)
	ga is the percentage for the green component (-100 to 100)
	gb is the offset for the green component (-255 to 255)
	ba is the percentage for the blue component (-100 to 100)
	bb is the offset for the blue component (-255 to 255)
	aa is the percentage for alpha (-100 to 100)
	ab is the offset for alpha (-255 to 255)
	</blockquote>
	@example
	<code>
	var t:Object = { ra: '50', rb: '244', 
					 ga: '40', gb: '112',
					 ba: '12', bb: '90',
					 aa: '100', ab: '0' };
	ColorUtils.setTransform( my_mc, t );
	</code>
	You can also create a transform object from a hex color using {@link #getTransformObject}:
	<code>
	var t:Object = ColorUtils.getTransformObject( 0xff0000 );
	ColorUtils.setTransform( my_mc, t );
	</code>
	*/
	public static function setTransform (inMC:MovieClip,
									 	 inTransformObject:Object) : Void {
		var col:Color = new Color(inMC);
		col.setTransform(inTransformObject);
	}

	/**
	Creates and returns a hexadecimal number that is a mix of two color numbers.
	@param inStartColor : the start color to mix; hexadecimal number (0xff3300) or string ("ff3300") of the new color; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@param inMixColor : the color that is mixed in (the amount of which is given by inPercentage); hexadecimal number (0xff3300) or string ("ff3300") of the new color; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@param inPercentage : the amount of mix color that is added to the start color; a value between 0.0 and 1.0
	@return The mixed hexadecimal number value.
	*/
	public static function getMixColorNumber (inStartColor:Object,
											  inMixColor:Object,
											  inPercentage:Number) : Number {	
		var obj1Num:Number = ColorUtils.getHexNumber(inStartColor);
		var obj1:Object = ColorUtils.HEXtoRGB(obj1Num);
		var obj2Num:Number = ColorUtils.getHexNumber(inMixColor);
		var obj2:Object = ColorUtils.HEXtoRGB(obj2Num);
		var p:Number = inPercentage * 100;
		var t:Object = new Object();
		var r:Number = ColorUtils.mixValues(obj1.r, obj2.r, p);
		var g:Number = ColorUtils.mixValues(obj1.g, obj2.g, p);
		var b:Number = ColorUtils.mixValues(obj1.b, obj2.b, p);
		return (r<<16 | g<<8 | b);
	}
	
	/**
	Creates a color transform object from a hex number/hex string.
	A transform object has these properties:
	<blockquote>
	ra is the percentage for the red component (-100 to 100)
	rb is the offset for the red component (-255 to 255)
	ga is the percentage for the green component (-100 to 100)
	gb is the offset for the green component (-255 to 255)
	ba is the percentage for the blue component (-100 to 100)
	bb is the offset for the blue component (-255 to 255)
	aa is the percentage for alpha (-100 to 100)
	ab is the offset for alpha (-255 to 255)
	</blockquote>
	@param inHexColor : the color to use for the color component offsets; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@param inComponentPercentage : (optional) the percentage value used for ra, ga, ba and aa; default 100 is assumed; use values greater than 100 for light effects
	@return A color transform object:
	<code>
	{ ra: [componentPercentage value], rb: [color r value], 
	  ga: [componentPercentage value], gb: [color g value],
	  ba: [componentPercentage value], bb: [color b value],
	  aa: [componentPercentage value], ab: '0'};
	</code>
	*/
	public static function getTransformObject (inHexColor:Object,
											   inComponentPercentage:Number) : Object {
		var componentPercentage:Number = (inComponentPercentage != undefined) ? inComponentPercentage : 100;
		var hexNum:Number = ColorUtils.getHexNumber(inHexColor);
		var rgbObj:Object = ColorUtils.HEXtoRGB(hexNum);
		return { ra: componentPercentage, rb: rgbObj.r, 
				 ga: componentPercentage, gb: rgbObj.g,
				 ba: componentPercentage, bb: rgbObj.b,
				 aa: componentPercentage, ab: '0'};
	}
	
	/**
	Sets a movieclip's color by mixing two colors using Color.setRGB.
	@param inMC : the movieclip to set the color of
	@param inStartColor : the start color to mix; hexadecimal number (0xff3300) or string ("ff3300") of the new color; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@param inMixColor : the color that is mixed in (the amount of which is given by inPercentage); hexadecimal number (0xff3300) or string ("ff3300") of the new color; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@param inPercentage : the amount of mix color that is added to the start color; a value between 0.0 and 1.0
	@example
	This code sets the color of a movieclip to dark orange (40% of black mixed into ff6600):
	<code>
	ColorUtils.setMixColor( movies_mc.title_mc, 0xff6600, 0x000000, 0.4 ); 
	</code>
	@implementationNote Calls {@link #setColor}.
	*/
	public static function setMixColor (inMC:MovieClip,
										inStartColor:Object,
										inMixColor:Object,
										inPercentage:Number) : Void {	
		ColorUtils.setColor( inMC, ColorUtils.getMixColorNumber(inStartColor, inMixColor, inPercentage) );
	}
	
	/**
	Mixes two color transform objects and returns the new transform object.
	@param inStartTransform : start color (color transformation object); use {@link #getTransformObject} to create a color transform object from a hex number
	@param inMixTransform : mix color (color transformation object)
	@param inPercentage : the amount of mix color that is added to the start color; a value between 0.0 and 1.0
	@return The mixed color transform object; see {@link #setTransform} for a description of the transform object.
	*/
	public static function getMixTransformObject (inStartTransform:Object,
												  inMixTransform:Object,
												  inPercentage:Number) : Object {
		var t:Object = new Object();
		var percentage:Number = inPercentage * 100;
		t.ra = mixValues( inStartTransform.ra, inMixTransform.ra, percentage );
		t.ga = mixValues( inStartTransform.ga, inMixTransform.ga, percentage );
		t.ba = mixValues( inStartTransform.ba, inMixTransform.ba, percentage );
		t.rb = mixValues( inStartTransform.rb, inMixTransform.rb, percentage );
		t.gb = mixValues( inStartTransform.gb, inMixTransform.gb, percentage );
		t.bb = mixValues( inStartTransform.bb, inMixTransform.bb, percentage );
		return t;
	}
	
	/**
	Sets a movieclip's color by mixing two colors using Color.setTransform.
	@param inMC : the movieclip to set the color of
	@param inStartTransform : start color (color transformation object); use {@link #getTransformObject} to create a color transform object from a hex number
	@param inMixTransform : mix color (color transformation object)
	@param inPercentage : the amount of mix color that is added to the start color; a value between 0.0 and 1.0
	@return The mixed color transform object; see {@link #setTransform} for a description of the transform object.
	@example forthcoming
	@implementationNote Calls {@link #getMixTransformObject}.
	*/
	public static function setMixTransform (inMC:MovieClip,
											inStartTransform:Object,
											inMixTransform:Object,
											inPercentage:Number) : Object {	
		var t:Object = ColorUtils.getMixTransformObject(inStartTransform, inMixTransform, inPercentage);
		var col:Color = new Color(inMC);
		col.setTransform(t);
		return t;
	}
	
	/**
	Restores the true color of the movieclip, making it appear as in the Library.
	@param inMC : movieclip or button to set the color of
	@example
	The following code first sets the movieclip color to red, then restores it again:
	<code>
	ColorUtils.setColor( clip_mc, 0xff0000 );
	ColorUtils.restoreColor, clip_mc );
	</code>
	*/
	public static function restoreColor (inMC:MovieClip) : Void {
		var col:Color = new Color(inMC);
		var t:Object = new Object();
		t.ra = 100; // percentage
		t.ga = 100;
		t.ba = 100;
		t.rb = 0; // color offset
		t.gb = 0;
		t.bb = 0;
		col.setTransform(t);
	}
	
	/**
	Stores a color variable as "base color" property in the movieclip.
	Use the base color when you plan to change the color of the movieclip, and you want to revert or animate back to the original set color.
	For instance, {@link AQColor#mixColors} allows to use the base color (using the string "base") as mix color.
	@param inMC : movieclip that will store the property
	@param inBaseColor : a color hex number (for instance 0xff3300) or hex string ("ff3300"); you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@param inShouldSetColor : (optional) if true the movieclip's color is set immediately using Color.setRGB(baseColorNum); default is false (no color change)
	@implementationNote The color number is stored in the movieclip's custom property <code>_ASAP_baseColorNum</code>.
	*/
	public static function setBaseColor (inMC:MovieClip,
										 inBaseColor:Object,
										 inShouldSetColor:Boolean) : Void {
		var baseColorNum:Number = ColorUtils.getHexNumber(inBaseColor);
		inMC._ASAP_baseColorNum  = baseColorNum;
		if (inShouldSetColor) {
			var col:Color = new Color(inMC);
			col.setRGB(baseColorNum);
		}
	}
	
	/**
	Creates the base color by mixing two colors.
	@param inMC : movieclip that will store the property
	@param inStartColor : the start color to mix; hexadecimal number (0xff3300) or string ("ff3300") of the new color; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@param inMixColor : the color that is mixed in (the amount of which is given by inPercentage); hexadecimal number (0xff3300) or string ("ff3300") of the new color; you can use negative hex numbers as well: (-0xff3300 or "-ff3300")
	@param inPercentage : the amount of mix color that is added to the start color; a value between 0.0 and 1.0
	@param inShouldSetColor : (optional) if true the movieclip's color is set immediately using Color.setRGB(baseColorNum); default is false (no color change)
	@implementationNote Calls {@link #getMixColorNumber} and {@link #setBaseColor}.
	*/
	public static function setMixBaseColor (inMC:MovieClip,
											inStartColor:Object,
											inMixColor:Object,
											inPercentage:Number,
											inShouldSetColor:Boolean) : Void {
		var baseColorNum:Number = ColorUtils.getMixColorNumber(inStartColor, inMixColor, inPercentage);
		ColorUtils.setBaseColor(inMC, baseColorNum, inShouldSetColor);
	}
	
	/**
	Retrieves the stored base color variable from the movieclip.
	The base color must have been set before calling this method (see {@link #setBaseColor}).
	@param inMC : movieclip to retrieve the property from
	@return : The color hex number (for instance 0xff3300).
	*/
	public static function getBaseColor (inMC:MovieClip) : Number {
		return inMC._ASAP_baseColorNum ;
	}
	
	/**
	Sets the color of a movieclip (back) to the color value stored in its base color. The base color must have been set before calling this method.
	@param inMC : movieclip or button to set the color of
	*/
	public static function setToBaseColor (inMC:MovieClip) : Void {
		var col:Color = new Color(inMC);
		col.setRGB( ColorUtils.getBaseColor(inMC) );
	}
	
	/**
	@param inHexNumber: the hex number to derive a rgb color object from
	@return An object with the properties r, g, b.
	*/
	private static function HEXtoRGB (inHexNumber:Number) : Object {
		var r:Number = inHexNumber >> 16;
		var g:Number = (inHexNumber ^ (r << 16)) >> 8;
		var b:Number = (inHexNumber ^ (r << 16)) ^ (g << 8);
		return {r:r, g:g, b:b};
	}
	
	
	/**
	Mixes two numbers by a mix percentage value.
	@param inA : first number to mix
	@param inB : second number to mix
	@param inMix : percentage value (0-100) by which the numbers should be mixed
	@return The outcome of the mix calculation (a value between number a and number b)
	@example
	The following values returns 128:
	<code>
	AQCOmixValues(255, 128, 100);
	</code>
	The following values returns 191.5:
	<code>
	AQCOmixValues(255, 128, 50);
	</code>
	*/
	private static function mixValues (inA:Number,
									   inB:Number,
									   inMix:Number) : Number {
		return ( inA * (100 - inMix) + inB * inMix ) * 0.01;
	}
	
}
