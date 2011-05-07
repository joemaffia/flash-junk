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

import org.casaframework.textfield.DispatchableTextField;
import org.casaframework.util.MovieClipUtil;

/**
	Dispatches TextField event handler notification using {@link EventDispatcher}.
	
	@author Aaron Clinger
	@version 06/21/07
	@example
		<code>
			function onTextChanged(sender:EventTextField):Void {
				trace("Text has changed to: " + sender.text);
			}
			
			var myText_mc:EventTextField = EventTextField.create(this, "text_mc", null, 250, 50);
			this.myText_mc.border = this.myText_mc.background = true;
			this.myText_mc.type = "input";
			this.myText_mc.text = "Hello World!";
			this.myText_mc.addEventObserver(this, EventTextField.EVENT_CHANGED, "onTextChanged");
		</code>
	@see {@link CoreTextField}
*/

class org.casaframework.textfield.EventTextField extends DispatchableTextField {
	public static var EVENT_CHANGED:String    = 'onChanged';
	public static var EVENT_KILL_FOCUS:String = 'onKillFocus';
	public static var EVENT_SCROLLER:String   = 'onScroller';
	public static var EVENT_SET_FOCUS:String  = 'onSetFocus';
	
	
	/**
		Creates an empty instance of the EventTextField class. Use this instead of a traditional <code>new</code> constructor statement due to limitations of ActionScript 2.0.
		
		@param target: Location where the TextField should be attached.
		@param instanceName: A unique instance name for the TextField.
		@param depth: <strong>[optional]</strong> The depth level where the TextField is placed; defaults to next highest open depth.
		@param width: A positive integer that specifies the width of the new text field.
		@param height: A positive integer that specifies the height of the new text field.
		@return Returns a reference to the created instance.
		@example <code>var myText_mc:EventTextField = EventTextField.create(this, "text_mc", null, 250, 50);</code>
		@since Flash Player 7
	*/
	public static function create(target:MovieClip, instanceName:String, depth:Number, width:Number, height:Number):EventTextField {
		var tf:EventTextField = EventTextField(MovieClipUtil.createMovieRegisterClass('org.casaframework.textfield.EventTextField', target, instanceName, depth));
		
		tf.width  = width;
		tf.height = height;
		
		return tf;
	}
	
	
	private function EventTextField() {
		super();
		
		this.$setClassDescription('org.casaframework.textfield.EventTextField');
	}
	
	/**
		@exclude
		@sends onChanged = function(sender:EventTextField) {}
	*/
	public function onChanged():Void {
		this.dispatchEvent(EventTextField.EVENT_CHANGED, this);
	}
	
	/**
		@exclude
		@sends onKillFocus = function(sender:EventTextField, newFocus:Object) {}
	*/
	public function onKillFocus(newFocus:Object):Void {
		this.dispatchEvent(EventTextField.EVENT_KILL_FOCUS, this, newFocus);
	}
	
	/**
		@exclude
		@sends onScroller = function(sender:EventTextField) {}
	*/
	public function onScroller():Void {
		this.dispatchEvent(EventTextField.EVENT_SCROLLER, this);
	}
	
	/**
		@exclude
		@sends onSetFocus = function(sender:EventTextField, oldFocus:Object) {}
	*/
	public function onSetFocus(oldFocus:Object):Void {
		this.dispatchEvent(EventTextField.EVENT_SET_FOCUS, this, oldFocus);
	}
}