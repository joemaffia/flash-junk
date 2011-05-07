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

import org.casaframework.textfield.CoreTextField;
import org.casaframework.event.DispatchableInterface;
import org.casaframework.event.EventDispatcher;
import org.casaframework.util.MovieClipUtil;

/**
	Base "TextField" that includes {@link EventDispatcher} and extends {@link CoreTextField}.
	
	@author Aaron Clinger
	@version 06/21/07
	@see {@link CoreTextField}
*/

class org.casaframework.textfield.DispatchableTextField extends CoreTextField implements DispatchableInterface {
	private var $eventDispatcher:EventDispatcher;
	
	
	/**
		Creates an empty instance of the DispatchableTextField class. Use this instead of a traditional <code>new</code> constructor statement due to limitations of ActionScript 2.0.
		
		@param target: Location where the TextField should be attached.
		@param instanceName: A unique instance name for the TextField.
		@param depth: <strong>[optional]</strong> The depth level where the TextField is placed; defaults to next highest open depth.
		@param width: A positive integer that specifies the width of the new text field.
		@param height: A positive integer that specifies the height of the new text field.
		@return Returns a reference to the created instance.
		@example <code>var myText_mc:DispatchableTextField = DispatchableTextField.create(this, "text_mc", null, 250, 50);</code>
		@since Flash Player 7
	*/
	public static function create(target:MovieClip, instanceName:String, depth:Number, width:Number, height:Number):DispatchableTextField {
		var tf:DispatchableTextField = DispatchableTextField(MovieClipUtil.createMovieRegisterClass('org.casaframework.textfield.DispatchableTextField', target, instanceName, depth));
		
		tf.width  = width;
		tf.height = height;
		
		return tf;
	}
	
	
	private function DispatchableTextField() {
		super();
		
		this.$eventDispatcher = new EventDispatcher();
		
		this.$setClassDescription('org.casaframework.textfield.DispatchableTextField');
	}
	
	public function addEventObserver(scope:Object, eventName:String, eventHandler:String):Boolean {
		return this.$eventDispatcher.addEventObserver(scope, eventName, eventHandler);
	}
	
	public function removeEventObserver(scope:Object, eventName:String, eventHandler:String):Boolean {
		return this.$eventDispatcher.removeEventObserver(scope, eventName, eventHandler);
	}
	
	public function removeEventObserversForEvent(eventName:String):Boolean {
		return this.$eventDispatcher.removeEventObserversForEvent(eventName);
	}
	
	public function removeEventObserversForScope(scope:Object):Boolean {
		return this.$eventDispatcher.removeEventObserversForScope(scope);
	}
	
	public function removeAllEventObservers():Boolean {
		return this.$eventDispatcher.removeAllEventObservers();
	}
	
	/**
		{@inheritDoc}
		
		@param eventName: {@inheritDoc}
		@param param(s): {@inheritDoc}
		@return {@inheritDoc}
	*/
	public function dispatchEvent(eventName:String):Boolean {
		return this.$eventDispatcher.dispatchEvent.apply(this.$eventDispatcher, arguments);
	}
	
	public function destroy():Void {
		this.$eventDispatcher.destroy();
		delete this.$eventDispatcher;
		
		super.destroy();
	}
}