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

import org.casaframework.core.CoreObject;
import org.casaframework.math.geom.ShapeInterface;
import org.casaframework.math.geom.Point;

/**
	Base shape class. Class needs to be extended further to function properly.
	
	@author Aaron Clinger
	@version 08/02/07
*/

class org.casaframework.math.geom.BaseShape extends CoreObject implements ShapeInterface {
	private var $x:Number;
	private var $y:Number;
	private var $width:Number;
	private var $height:Number;
	
	
	private function BaseShape(x:Number, y:Number, width:Number, height:Number) {
		super();
		
		this.setX((x == undefined) ? 0 : x);
		this.setY((y == undefined) ? 0 : y);
		this.setWidth((width == undefined) ? 0 : width);
		this.setHeight((height == undefined) ? this.getWidth() : height);
		
		this.$setClassDescription('org.casaframework.math.geom.BaseShape');
	}
	
	public function getX():Number {
		return this.$x;
	}
	
	public function setX(x:Number):Void {
		this.$x = x;
	}
	
	public function getY():Number {
		return this.$y;
	}
	
	public function setY(y:Number):Void {
		this.$y = y;
	}
	
	public function getPosition():Point {
		return new Point(this.getX(), this.getY());
	}
	
	public function setPosition(pointObject:Point):Void {
		this.setX(pointObject.getX());
		this.setY(pointObject.getY());
	}
	
	public function getCenterPoint():Point {
		return new Point(this.getX() + this.getWidth() * .5, this.getY() + this.getHeight() * .5);
	}
	
	public function getWidth():Number {
		return this.$width;
	}
	
	public function setWidth(width:Number):Void {
		this.$width = width;
	}
	
	public function getHeight():Number {
		return this.$height;
	}
	
	public function setHeight(height:Number):Void {
		this.$height = height;
	}
	
	public function getPerimeter():Number {
		return null;
	}
	
	public function getArea():Number {
		return null;
	}
	
	public function containsPoint(pointObject:Point):Boolean {
		return null;
	}
	
	public function equals(shape:ShapeInterface):Boolean {
		return null;
	}
	
	public function clone():ShapeInterface {
		return null;
	}
	
	public function destroy():Void {
		delete this.$x;
		delete this.$y;
		delete this.$width;
		delete this.$height;
		
		super.destroy();
	}
}