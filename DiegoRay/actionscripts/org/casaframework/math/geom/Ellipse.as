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

import org.casaframework.math.geom.BaseShape;
import org.casaframework.math.geom.Point;

/**
	Stores position and size of an ellipse (circle or oval).
	
	@author Aaron Clinger
	@version 08/02/07
*/

class org.casaframework.math.geom.Ellipse extends BaseShape {
	
	
	/**
		Creates new ellipse object.
		
		@param x: The horizontal position of the ellipse.
		@param y: The vertical position of the ellipse.
		@param width: Width of the ellipse at its widest horizontal point.
		@param height: <strong>[optional]</strong> Height of the ellipse at its tallest point. If <code>undefined</code> assumes <code>height</code> matches <code>width</code> (Creates circle).
	*/
	public function Ellipse(x:Number, y:Number, width:Number, height:Number) {
		super(x, y, width, height);
		
		this.$setClassDescription('org.casaframework.math.geom.Ellipse');
	}
	
	/**
		{@inheritDoc}
		
		@return {@inheritDoc}
		@usageNote Calculating the circumference of an ellipse is difficult; this is an approximation but should be fine for most cases.
	*/
	public function getPerimeter():Number {
		return (Math.sqrt(.5 * (Math.pow(this.getWidth(), 2) + Math.pow(this.getHeight(), 2))) * Math.PI * 2) * 0.5;
	}
	
	public function getArea():Number {
		return Math.PI * (this.getWidth() * 0.5) * (this.getHeight() * 0.5);
	}
	
	/**
		Finds the <code>x, y</code> position of the degree along the circumference of the ellipse.
		
		@param degree: Number representing a degree on the ellipse. 
		@return A defined {@link Point} object.
		@usageNote <code>degree</code> can be over <code>360</code> or even negitive numbers; minding <code>0 = 360 = 720</code>, <code>540 = 180</code>, <code>-90 = 270</code>, etc...
	*/
	public function getPointOfDegree(degree:Number):Point {
		var radian:Number  = (degree - 90) * (Math.PI / 180);
		var xRadius:Number = this.getWidth() * 0.5;
		var yRadius:Number = this.getHeight() * 0.5;
		
		return new Point(this.getX() + xRadius + Math.cos(radian) * xRadius, this.getY() + yRadius + Math.sin(radian) * yRadius);
	}
	
	public function containsPoint(pointObject:Point):Boolean {
		var xRadius:Number = this.getWidth() * 0.5;
		var yRadius:Number = this.getHeight() * 0.5;
		var xTar:Number    = pointObject.getX() - this.getX() - xRadius;
		var yTar:Number    = pointObject.getY() - this.getY() - yRadius;
		
		return Math.pow(xTar / xRadius, 2) + Math.pow(yTar / yRadius, 2) <= 1;
	}
	
	/**
		Determines whether the ellipse specified in the <code>ellipseObject</code> parameter is equal to this ellipse object.
		
		@param rectangleObject: A defined {@link Ellipse} object.
		@return {@inheritDoc}
	*/
	public function equals(ellipseObject:Ellipse):Boolean {
		return this.getX() == ellipseObject.getX() && this.getY() == ellipseObject.getY() && this.getWidth() == ellipseObject.getWidth() && this.getHeight() == ellipseObject.getHeight();
	}
	
	/**
		@return A new ellipse object with the same values as this ellipse.
	*/
	public function clone():Ellipse {
		return new Ellipse(this.getX(), this.getY(), this.getWidth(), this.getHeight());
	}
	
	public function destroy():Void {
		super.destroy();
	}
}