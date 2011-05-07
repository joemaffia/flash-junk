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

import org.casaframework.event.EventDispatcher;
import org.casaframework.control.RunnableInterface;

/**
	Timer is used for executing code at a specific callback frequency.
	
	@author Aaron Clinger
	@version 04/09/07
	@example
		<code>
			function onFire(sender:Timer, fires:Number):Void {
				trace("onFire has been called " + fires + " times.");
			}
			
			var myTimer:Timer = new Timer(1000, 3);
			this.myTimer.addEventObserver(this, Timer.EVENT_FIRE, "onFire");
			this.myTimer.start();
		</code>
*/

class org.casaframework.time.Timer extends EventDispatcher implements RunnableInterface {
	public static var EVENT_START:String    = 'onStart';
	public static var EVENT_STOP:String     = 'onStop';
	public static var EVENT_FIRE:String     = 'onFire';
	public static var EVENT_COMPLETE:String = 'onComplete';
	private var $id:Number;
	private var $reps:Number;
	private var $delay:Number;
	private var $fires:Number;
	
	/**
		Defines the Timer object that dispatches an event at a specific frequency.
		
		@param delay: The time in milliseconds between calls.
		@param reps: The amount of repetitions.
	*/
	public function Timer(delay:Number, reps:Number) {
		super();
		
		this.$delay = delay;
		this.$reps  = reps;
		
		this.$setClassDescription('org.casaframework.time.Timer');
	}
	
	/**
		Starts or restarts the timer. Resets reps/fires to 0.
		
		@sends onStart = function(sender:Timer) {}
	*/
	public function start():Void {
		if (this.isFiring())
			this.$stopInterval();
		
		this.dispatchEvent(Timer.EVENT_START, this);
		
		this.$startInterval();
	}
	
	/**
		Stops the timer.
		
		@sends onStop = function(sender:Timer) {}
	*/
	public function stop():Void {
		if (!this.isFiring())
			return;
		
		this.$stopInterval();
		delete this.$fires;
		
		this.dispatchEvent(Timer.EVENT_STOP, this);
	}
	
	/**
		Changes the time between repetitions. Does NOT reset reps/fires.
		
		@param delay: The time in milliseconds between calls.
	*/
	public function changeDelay(delay:Number):Void {
		var fires:Number = this.getFires();
		this.$stopInterval();
		this.$delay = delay;
		
		if (this.isFiring()) {
			this.$startInterval();
			this.$fires = fires;
		}
	}
	
	/**
		@return Returns the time between repetitions.
	*/
	public function getDelay():Number {
		return this.$delay;
	}
	
	/**
		Determines in the timer is running.
		
		@return Returns <code>true</code> if Timer instance is running/firing; otherwise <code>false</code>.
	*/
	public function isFiring():Boolean {
		return this.$id != undefined;
	}
	
	/**
		Returns the number of fires.
		
		@return The number of elapsed fires.
	*/
	public function getFires():Number {
		return this.$fires;
	}
	
	/**
		@sends onFire = function(sender:Timer, fires:Number) {}
		@sends onComplete = function(sender:Timer, fires:Number) {}
	*/
	private function $onFire():Void {
		this.dispatchEvent(Timer.EVENT_FIRE, this, ++this.$fires);
		
		if (this.$reps != undefined) {
			if (this.$reps <= this.$fires) {
				this.$stopInterval();
				this.dispatchEvent(Timer.EVENT_COMPLETE, this, this.$fires);
			}
		}
	}
	
	private function $startInterval():Void {
		this.$fires = 0;
		this.$id    = _global.setInterval(this, '$onFire', this.$delay);
	}
	
	private function $stopInterval():Void {
		_global.clearInterval(this.$id);
		delete this.$id;
	}
	
	public function destroy():Void {
		if (this.isFiring())
			this.$stopInterval();
		
		delete this.$reps;
		delete this.$delay;
		delete this.$fires;
		
		super.destroy();
	}
}
