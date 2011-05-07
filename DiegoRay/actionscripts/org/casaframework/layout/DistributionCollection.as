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
import org.casaframework.math.geom.Rectangle;
import org.casaframework.util.ArrayUtil;
import org.casaframework.util.TypeUtil;

/**
	Creates the mechanism to distribute <code>MovieClip</code>s, <code>TextField</code>s and <code>Button</code>s to a vertical or horzontal grid of columns and rows.
	
	@author Aaron Clinger
	@version 05/09/07
	@example
		<code>
			var distribution:DistributionCollection = new DistributionCollection();
			this.distribution.setRectangle(new Rectangle(10, 10, 400, Number.POSITIVE_INFINITY));
			this.distribution.setMargin(0, 5, 5, 0);
			
			var len:Number = 5;
			while (len--) {
				this.distribution.addItem(this.attachMovie("box", "box" + len + "_mc", this.getNextHighestDepth()));
			}
			
			this.distribution.positionItems();
		</code>
*/

class org.casaframework.layout.DistributionCollection extends CoreObject {
	private var $margin:Object;
	private var $rect:Rectangle;
	private var $bounding:Rectangle;
	private var $collection:Array;
	private var $isVert:Boolean;
	private var $round:Boolean;
	
	
	/**
		Creates a new DistributionCollection instance.
		
		@param snapToPixel: <strong>[optional]</strong> Force the position of all items to whole pixels <code>true</code>, or to let items be positioned on sub-pixels <code>false</code>; defaults to <code>false</code>.
	*/
	public function DistributionCollection(snapToPixel:Boolean) {
		super();
		
		this.$collection = new Array();
		this.$round      = (snapToPixel == undefined) ? false : snapToPixel;
		this.$margin     = new Object();
		this.$margin.top = this.$margin.right = this.$margin.bottom = this.$margin.left = 0;
		
		this.$setClassDescription('org.casaframework.layout.DistributionCollection');
	}
	
	/**
		Defines the area and position of the distribution.
		
		@param rectangle: A rectangle defining either the max width or height boundries of the distribution
		@return Returns <code>true</code> if the rectangle was valid and applied; otherwise <code>false</code>.
		@usageNote Either the rectangle's width or height must defined as <code>Number.POSITIVE_INFINITY</code>.
	*/
	public function setRectangle(rectangle:Rectangle):Boolean {
		if (rectangle.getWidth() == Number.POSITIVE_INFINITY || rectangle.getHeight() == Number.POSITIVE_INFINITY) {
			if (rectangle.getWidth() != Number.POSITIVE_INFINITY) {
				this.$rect   = rectangle.clone();
				this.$isVert = true;
				
				this.positionItems();
				
				return true;
			} else if (rectangle.getHeight() != Number.POSITIVE_INFINITY) {
				this.$rect   = rectangle.clone();
				this.$isVert = false;
				
				this.positionItems();
				
				return true;
			}
		}
		
		return false;
	}
	
	/**
		@return Returns the area and position of the distribution that was defined with {@link #setRectangle}.
	*/
	public function getRectangle():Rectangle {
		return this.$rect.clone();
	}
	
	/**
		@return Returns the actual area and position the items in the distribution occupy.
	*/
	public function getBoundingRectangle():Rectangle {
		return this.$bounding.clone();
	}
	
	/**
		Defines the spacing between items in the distribution.
		
		@param marginTop: Sets the top spacing of an element.
		@param marginRight: Sets the right spacing of an element.
		@param marginBottom: Sets the bottom spacing of an element.
		@param marginLeft: Sets the left spacing of an element.
	*/
	public function setMargin(marginTop:Number, marginRight:Number, marginBottom:Number, marginLeft:Number):Void {
		this.$margin.top    = (marginTop == undefined) ? 0 : marginTop;
		this.$margin.right  = (marginRight == undefined) ? 0 : marginRight;
		this.$margin.left   = (marginLeft == undefined) ? 0 : marginLeft;
		this.$margin.bottom = (marginBottom == undefined) ? 0 : marginBottom;
		
		this.positionItems();
	}
	
	/**
		Adds or reorders item to receive distribution position updates.
		
		@param item: A <code>MovieClip</code>, <code>TextField</code> or <code>Button</code>.
		@param position: <strong>[optional]</strong> An integer that specifies the index of the where the item will be inserted into the distribution; defaults to the end of the distribution.
		@return Returns <code>true</code> if item was of type <code>MovieClip</code>, <code>TextField</code> or <code>Button</code> and was successfully added; otherwise <code>false</code>.
	*/
	public function addItem(item:Object, position:Number):Boolean {
		switch (TypeUtil.getTypeOf(item)) {
			case 'button' :
			case 'movieclip' :
			case 'textfield' :
				var index:Number = ArrayUtil.indexOf(this.$collection, item);
				
				if (index != -1)
					this.$collection.splice(index, 1);
				
				this.$collection.splice((position == undefined) ? this.$collection.length : position, 0, item);
				
				return true;
			default :
				return false;
		}
	}
	
	/**
		Removes item previously added with {@link #addItem} from receiving distribution updates. Leaves item at its current position.
		
		@param item: A <code>MovieClip</code>, <code>TextField</code> or <code>Button</code> you wish to remove.
		@return Returns <code>true</code> if item was successfully found and removed; otherwise <code>false</code>.
	*/
	public function removeItem(item:Object):Boolean {
		if (ArrayUtil.removeArrayItem(this.$collection, item) > 0)
			return true;
		
		return false;
	}
	
	public function getItemAt(position:Number):Object {
		return this.$collection[position];
	}
	
	public function findItemPosition(item:Object):Number {
		return ArrayUtil.indexOf(this.$collection, item);
	}
	
	/**
		Applies the distribution layout for all items added with {@link #addItem}.
		
		@usageNote <code>positionItems</code> is automatically called after {@link #setRectangle} and {@link #setMargin}.
	*/
	public function positionItems():Void {
		if (this.$rect == undefined)
			return;
		
		var i:Number             = -1;
		var row:Number           = 0;
		var column:Number        = 0;
		var largest:Number       = 0;
		var largestWidth:Number  = 0;
		var largestHeight:Number = 0;
		var h:Number             = 0;
		var w:Number             = 0;
		var item:Object;
		
		while (++i < this.$collection.length) {
			item = this.$collection[i];
			
			w = item._width  + this.$margin.left + this.$margin.right;
			h = item._height + this.$margin.top + this.$margin.bottom;
			
			if (this.$isVert) {
				column += w;
				
				if (column > this.$rect.getWidth()) {
					row += (largest == 0) ? row : largest;
					
					largest = 0;
					column  = w;
				}
				
				if (h > largest)
					largest = h;
				
				if (column > largestWidth)
					largestWidth = column;
				
				item._x = column - item._width - this.$margin.right + this.$rect.getX();
				item._y = row + this.$margin.top + this.$rect.getY();
			} else {
				row += h;
				
				if (row > this.$rect.getHeight()) {
					column += (largest == 0) ? column : largest;
					
					largest = 0;
					row     = h;
				}
				
				if (w > largest)
					largest = w;
				
				if (row > largestHeight)
					largestHeight = row;
				
				item._x = column + this.$margin.left + this.$rect.getX();
				item._y = row - item._height - this.$margin.bottom + this.$rect.getY();
			}
			
			if (this.$round) {
				item._x = Math.round(item._x);
				item._y = Math.round(item._y);
			}
		}
		
		if (this.$bounding != undefined)
			this.$bounding.destroy();
		
		this.$bounding = this.$rect.clone();
		this.$bounding.setWidth(this.$isVert ? largestWidth : column + w);
		this.$bounding.setHeight(this.$isVert ? row + h : largestHeight);
	}
	
	public function destroy():Void {
		this.$rect.destroy();
		this.$bounding.destroy();
		
		delete this.$margin;
		delete this.$rect;
		delete this.$bounding;
		delete this.$collection;
		delete this.$isVert;
		delete this.$round;
		
		super.destroy();
	}
}
