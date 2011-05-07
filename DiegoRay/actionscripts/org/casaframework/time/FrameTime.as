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
import org.casaframework.time.EnterFrame;

/**
	Creates a common time which isn't affected by delays caused by code execution; the time is only updated every frame.
	
	@author Aaron Clinger
	@version 08/02/07
	@example
		<code>
			var frameTimeInstance:FrameTime = FrameTime.getInstance();
			var field:TextField;
			var total:Number = 25;
			
			while (total--) {
				var field = this.createTextField("timer" + total + "_txt", this.getNextHighestDepth(), 0, total * 22, 500, 22);
				field.text = "Time when this field was created = " + frameTimeInstance.getTime();
			}
		</code>
*/

class org.casaframework.time.FrameTime extends CoreObject {
	private static var $frameTimeInstance:FrameTime;
	private var $enterFrame:EnterFrame;
	private var $time:Number;
	
	
	/**
		@return {@link FrameTime} instance.
	*/
	public static function getInstance():FrameTime {
		if (FrameTime.$frameTimeInstance == undefined)
			FrameTime.$frameTimeInstance = new FrameTime();
		
		return FrameTime.$frameTimeInstance;
	}
	
	private function FrameTime() {
		super();
		
		this.$enterFrame = EnterFrame.getInstance();
		this.$enterFrame.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$updateTime');
		
		this.$updateTime();
		
		this.$setClassDescription('org.casaframework.time.FrameTime');
	}
	
	/**
		@return Returns the number of milliseconds from when the SWF started playing to the last <code>onEnterFrame</code> event.
	*/
	public function getTime():Number {
		return this.$time;
	}
	
	private function $updateTime():Void {
		this.$time = getTimer();
	}
}