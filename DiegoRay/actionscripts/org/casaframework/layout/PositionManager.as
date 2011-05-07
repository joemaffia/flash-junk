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
import org.casaframework.stage.EventStage;
import org.casaframework.util.StyleSheetUtil;
import org.casaframework.util.TypeUtil;
import TextField.StyleSheet;

/**
	Gives the ablility to position and size <code>MovieClip</code>s, <code>TextField</code>s and <code>Button</code>s with either an external CSS file or an internal <code>StyleSheet</code> object.

	@author Aaron Clinger
	@version 04/06/07
	@since Flash Player 7
	@example
		<code>
			var positionManager:PositionManager = new PositionManager();
			
			this.positionManager.setStyleSheet(this.styleSheet);
			
			this.positionManager.addItem(this.text_txt);
			this.positionManager.addItem(this.button_btn);
			this.positionManager.addItem(this.movie_mc, {left:"0", height:"100%"});
			this.positionManager.positionItems();
		</code>
	@see "For information on which CSS properties are supported by {@link PositionManager} see {@link StyleSheetUtil#positionItemWithStyleObject}."
*/
//@TODO Add DistributionCollection support.
class org.casaframework.layout.PositionManager extends CoreObject {
	private var $style:StyleSheet;
	private var $updateItemsMap:Object;
	
	
	/**
		Creates a new PositionManager instance.
	*/
	public function PositionManager() {
		super();
		
		this.$updateItemsMap = new Object();
		
		this.$setClassDescription('org.casaframework.layout.PositionManager');
	}
	
	/**
		Defines a global stylesheet. 
		
		Class maps style IDs to instance names of added items. Style <code>#square_mc { width: 200px; height: 200px; }</code> would apply to an item with an instance name of <code>"square_mc</code>.
		
		@param style: A StyleSheet to apply to added items.
		@see "For information on which CSS properties are supported by {@link PositionManager} see {@link StyleSheetUtil#positionItemWithStyleObject}."
	*/
	public function setStyleSheet(style:StyleSheet):Void {
		this.$style = style;
		this.positionItems();
	}
	
	/**
		Adds item to be positioned and sized by styles.
		
		@param item: A <code>MovieClip</code>, <code>TextField</code> or <code>Button</code>.
		@param style: <strong>[optional]</strong> An object with style properties defined. Any properties defined here overwrite the values of any identical properties that may have been defined by {@link #setStyleSheet}.
		@return Returns <code>true</code> if item was of type <code>MovieClip</code>, <code>TextField</code> or <code>Button</code> and was successfully added; otherwise <code>false</code>.
		@example <code>this.positionManager.addItem(this.movie_mc, {left:"0", height:"100%"});</code> or <code>this.positionManager.addItem(this.movie_mc, this.styleSheet.getStyle("styleName"));</code>
		@see "For information on which CSS properties are supported by {@link PositionManager} see {@link StyleSheetUtil#positionItemWithStyleObject}."
	*/
	public function addItem(item:Object, style:Object):Boolean {
		switch (TypeUtil.getTypeOf(item)) {
			case 'movieclip' :
			case 'textfield' :
			case 'button' :
				var positionItem:Object = new Object();
				positionItem.item  = item;
				positionItem.name  = item._name;
				if (style != undefined) positionItem.style = style;
				
				this.$updateItemsMap[item] = positionItem;
				break;
			default :
				return false;
		}
		
		return true;
	}
	
	/**
		Removes item previously added with {@link #addItem} from receiving style and position updates from PositionManager. Leaves item at its current size and position.
		
		@param item: A <code>MovieClip</code>, <code>TextField</code> or <code>Button</code> you wish to remove.
		@return Returns <code>true</code> if item was successfully found and removed; otherwise <code>false</code>.
	*/
	public function removeItem(item:Object):Boolean {
		if (this.$updateItemsMap[item] != undefined) {
			delete this.$updateItemsMap[item];
			
			return true;
		}
		
		return false;
	}
	
	/**
		Positions all items added with {@link #addItem} with the defined styles.
		
		@usageNote <code>positionItems</code> is automatically called after {@link #setStyleSheet}.
	*/
	public function positionItems():Void {
		var style:Object;
		var positionItem:Object;
		var isGlobalStyle:Boolean = this.$style != undefined;
		
		for (var i:String in this.$updateItemsMap) {
			positionItem = this.$updateItemsMap[i];
			
			if (isGlobalStyle) {
				style = this.$style.getStyle('#' + positionItem.name);
				
				if (style != undefined)
					StyleSheetUtil.positionItemWithStyleObject(positionItem.item, style);
			}
			
			if (positionItem.style != undefined)
				StyleSheetUtil.positionItemWithStyleObject(positionItem.item, positionItem.style);
		}
	}
}
