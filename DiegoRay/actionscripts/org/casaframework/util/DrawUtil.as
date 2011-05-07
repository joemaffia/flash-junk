/*
	CASA Framework for ActionScript 2.0
	Copyright (C) 2007  CASA Framework
	http://casaframework.org
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

import org.casaframework.math.geom.Ellipse;
import org.casaframework.math.geom.Rectangle;

/**
	@author Aaron Clinger
	@version 02/08/07
*/

class org.casaframework.util.DrawUtil {
	
	/**
		Draws a circular wedge into a MovieClip.
		
		@param target_mc: MovieClip in which to draw the wedge.
		@param ellipse: Defined Ellipse object that contains the size and position of the shape.
		@param startAngle: The starting angle of wedge in degrees.
		@param arc: The sweep of the wedge in degrees.
		@usage
			<code>
				this.createEmptyMovieClip('wedge_mc', this.getNextHighestDepth());
				var myOval:Ellipse = new Ellipse(10, 10, 150, 50);
				
				this.wedge_mc.beginFill(0xFF00FF);
				DrawUtil.drawWedge(this.wedge_mc, myOval, 0, 270);
				this.wedge_mc.endFill();
			</code>
	*/
	public static function drawWedge(target_mc:MovieClip, ellipse:Ellipse, startAngle:Number, arc:Number):Void {
		if (Math.abs(arc) >= 360) {
			DrawUtil.drawEllipse(target_mc, ellipse);
			return;
		}
		
		startAngle += 90;
		
		var radius:Number   = ellipse.getWidth() * .5;
		var yRadius:Number  = ellipse.getHeight() * .5;
		var x:Number        = ellipse.getX() + radius;
		var y:Number        = ellipse.getY() + yRadius;
		var segs:Number     = Math.ceil(Math.abs(arc) / 45);
		var segAngle:Number = -arc / segs;
		var theta:Number    = -(segAngle / 180) * Math.PI;
		var angle:Number    = -(startAngle / 180) * Math.PI;
		var ax:Number       = x + Math.cos(startAngle / 180 * Math.PI) * radius;
		var ay:Number       = y + Math.sin(-startAngle / 180 * Math.PI) * yRadius;
		var angleMid:Number;
		
		target_mc.moveTo(x, y);
		target_mc.lineTo(ax, ay);
		
		var i:Number = -1;
		while (++i < segs) {
			angle += theta;
			angleMid = angle - (theta * .5);
			
			target_mc.curveTo(x + Math.cos(angleMid) * (radius / Math.cos(theta * .5)), y + Math.sin(angleMid) * (yRadius / Math.cos(theta * .5)), x + Math.cos(angle) * radius, y + Math.sin(angle) * yRadius);
		}
		
		target_mc.lineTo(x, y);
	}
	
	/**
		Draws an ellipse (circle or oval) into a MovieClip.
		
		@param target_mc: MovieClip in which to draw the ellipse.
		@param ellipse: Defined Ellipse object that contains the size and position of the shape.
		@usage
			<code>
				this.createEmptyMovieClip('oval_mc', this.getNextHighestDepth());
				var myOval:Ellipse = new Ellipse(10, 10, 150, 50);
				
				this.oval_mc.beginFill(0xFF00FF);
				DrawUtil.drawEllipse(this.oval_mc, myOval);
				this.oval_mc.endFill();
			</code>
	*/
	public static function drawEllipse(target_mc:MovieClip, ellipse:Ellipse):Void {
		var radius:Number  = ellipse.getWidth() * .5;
		var yRadius:Number = ellipse.getHeight() * .5;
		var x:Number       = radius + ellipse.getX();
		var y:Number       = yRadius + ellipse.getY();
		var theta:Number   = Math.PI * .25;
		var xrCtrl:Number  = radius / Math.cos(theta * .5);
		var yrCtrl:Number  = yRadius / Math.cos(theta * .5);
		var angle:Number   = 0;
		var angleMid:Number;
		
		target_mc.moveTo(x + radius, y);
		
		var i:Number = -1;
		while (++i < 8) {
			angle += theta;
			angleMid = angle - (theta * .5);
			target_mc.curveTo(x + Math.cos(angleMid) *  xrCtrl, y + Math.sin(angleMid) * yrCtrl, x + Math.cos(angle) * radius, y + Math.sin(angle) * yRadius);
		}
	}
	
	/**
		Draws a rectangle (or square) into a MovieClip.
		
		@param target_mc: MovieClip in which to draw the rectangle.
		@param rectangle: Defined Rectangle object that contains the size and position of the shape.
		@usage
			<code>
				this.createEmptyMovieClip('rect_mc', this.getNextHighestDepth());
				var myRect:Rectangle = new Rectangle(10, 10, 150, 50);
				
				this.rect_mc.beginFill(0xFF00FF);
				DrawUtil.drawRectangle(this.rect_mc, myRect);
				this.rect_mc.endFill();
			</code>
	*/
	public static function drawRectangle(target_mc:MovieClip, rectangle:Rectangle):Void {
		var width:Number = rectangle.getX() + rectangle.getWidth();
		var height:Number = rectangle.getY() + rectangle.getHeight();
		
		with (target_mc) {
			moveTo(rectangle.getX(), rectangle.getY());
			lineTo(width, rectangle.getY());
			lineTo(width, height);
			lineTo(rectangle.getX(), height);
			lineTo(rectangle.getX(), rectangle.getY());
		}
	}
	
	/**
		Draws a rectangle with rounded corners into a MovieClip.
		
		@param target_mc: MovieClip in which to draw the rectangle.
		@param rectangle: Defined Rectangle object that contains the size and position of the shape.
		@param cornerRadius: The rounded radius of the rectangle's corners.
		@usage
			<code>
				this.createEmptyMovieClip('rect_mc', this.getNextHighestDepth());
				var myRect:Rectangle = new Rectangle(10, 10, 150, 50);
				
				this.rect_mc.beginFill(0xFF00FF);
				DrawUtil.drawRoundedRectangle(this.rect_mc, myRect, 15);
				this.rect_mc.endFill();
			</code>
	*/
	public static function drawRoundedRectangle(target_mc:MovieClip, rectangle:Rectangle, cornerRadius:Number):Void {
		if (cornerRadius <= 0 || cornerRadius == undefined) {
			DrawUtil.drawRectangle(target_mc, rectangle);
			return;
		}
		
		var width:Number             = rectangle.getX() + rectangle.getWidth();
		var height:Number            = rectangle.getY() + rectangle.getHeight();
		var xPlusCorner:Number       = rectangle.getX() + cornerRadius;
		var yPlusCorner:Number       = rectangle.getY() + cornerRadius;
		var widthMinusCorner:Number  = width - cornerRadius;
		var heightMinusCorner:Number = height - cornerRadius;
		
		with (target_mc) {
			moveTo(xPlusCorner, rectangle.getY());
			lineTo(widthMinusCorner, rectangle.getY());
			curveTo(width, rectangle.getY(), width, yPlusCorner);
			lineTo(width, heightMinusCorner);
			curveTo(width, height, widthMinusCorner, height);
			lineTo(xPlusCorner, height);
			curveTo(rectangle.getX(), height, rectangle.getX(), heightMinusCorner);
			lineTo(rectangle.getX(), yPlusCorner);
			curveTo(rectangle.getX(), rectangle.getY(), xPlusCorner, rectangle.getY());
		}
	}
	
	private function DrawUtil() {} // Prevents instance creation
}
