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

import org.casaframework.time.Timer;
import org.casaframework.util.ArrayUtil;
import org.casaframework.util.TypeUtil;

/**
	To be used instead of built in <code>setInterval</code> function. 
	
	Advantages over <code>setInterval</code>:
	<ul>
		<li>Auto stopping/clearing of intervals if method called no longer exists.</li>
		<li>Ability to {@link Timer#stop stop} and {@link Timer#start start} intervals without redefining.</li>
		<li>Change the delay with {@link Timer#changeDelay} without redefining.</li>
		<li>Included {@link #setReps} for intervals that only need to fire finitely.</li>
		<li>{@link #setInterval} returns object instead of interval id for better OOP structure.</li>
		<li>Built in events/event dispatcher.</li>
	</ul>
	
	@author Aaron Clinger
	@author Toby Boudreaux
	@author Mike Creighton
	@version 04/19/07
	@example
		<code>
			function exampleFire(firstName:String):Void {
				trace("exampleFire called and passed firstName = " + firstName);
			}
			
			var example_si:Interval = Interval.setInterval(this, "exampleFire", 1000, "Aaron");
			this.example_si.setReps(3);
			this.example_si.start();
		</code>
	@see {@link PropertySetter}.
*/

class org.casaframework.time.Interval extends Timer {
	private var $arguments:Array;
	
	private static var $intervalMap:Array;
	
	
	/**
		Calls a function or a method of an object at periodic intervals.
		
		@param scope: An object that contains the method specified by "methodName".
		@param methodName: A method that exists in the scope of the object specified by "scope".
		@param delay: The time in milliseconds between calls.
		@param param(s): <strong>[optional]</strong> Parameters passed to the function specified by "methodName". Multiple parameters are allowed and should be separated by commas: param1,param2, ...,paramN
		@return: {@link Interval} reference.
	*/
	public static function setInterval(scope:Object, methodName:String, delay:Number, param:Object):Interval {
		if (!TypeUtil.isTypeOf(scope[methodName], 'function'))
			return undefined;
		
		if (Interval.$intervalMap == undefined)
			Interval.$intervalMap = new Array();
		
		var intervalItem:Interval = new Interval(delay);
		intervalItem.setArguments(arguments);
		
		Interval.$intervalMap.push(intervalItem);
		
		return intervalItem;
	}
	
	/**
		Calls a function or a method of an object once after time has elasped, <code>setTimeout</code> defaults {@link #setReps} to 1. 
		
		@param scope: An object that contains the method specified by "methodName".
		@param methodName: A method that exists in the scope of the object specified by "scope".
		@param delay: The time in milliseconds between calls.
		@param param(s): <strong>[optional]</strong> Parameters passed to the function specified by "methodName". Multiple parameters are allowed and should be separated by commas: param1,param2, ...,paramN
		@return: {@link Interval} reference.
	*/
	public static function setTimeout(scope:Object, methodName:String, delay:Number, param:Object):Interval {
		var intervalItem:Interval = Interval.setInterval.apply(null, arguments);
		intervalItem.setReps(1);
		return intervalItem;
	}
	
	/**
		Stops all intervals in a defined location.
		
		@param scope: <strong>[optional]</strong> Object reference that contains a method referenced by one or more Interval instance. If scope is <code>undefined</code>, {@link #stopIntervals} will stop all running intervals.
		@see {@link Timer#stop}
	*/
	public static function stopIntervals(scope:Object):Void {
		var len:Number = Interval.$intervalMap.length;
		
		if (scope == undefined)
			while (len--)
				Interval.$intervalMap[len].stop();
		else
			while (len--)
				if (Interval.$intervalMap[len].$arguments[0] == scope)
					Interval.$intervalMap[len].stop();
	}
	
	
	
	private function Interval(delay:Number) {
		super(delay, undefined);
		
		this.$setClassDescription('org.casaframework.time.Interval');
	}
	
	/**
		Defines the amount of total repetitions/fires. If not set repetitions will continue until {@link Timer#stop} is called.
		
		@param reps: The amount of repetitions.
	*/
	public function setReps(reps:Number):Void {
		this.$reps = reps;
	}
	
	/**
		@exclude
	*/
	public function setArguments(args:Array):Void {
		this.$arguments = args;
	}
	
	private function $onFire():Void {
		var scope:Object      = this.$arguments[0];
		var methodName:String = this.$arguments[1];
		
		if (!TypeUtil.isTypeOf(scope[methodName], 'function')) {
			this.stop();
			return;
		}
		
		this.$fires++;
		
		if (this.$reps != undefined) {
			if (this.$reps <= this.$fires) {
				this.$stopInterval();
				scope[methodName].apply(scope, this.$arguments.slice(3));
				this.dispatchEvent(Timer.EVENT_FIRE, this, this.$fires);
				this.dispatchEvent(Timer.EVENT_COMPLETE, this, this.$fires);
				return;
			}
		}
		
		scope[methodName].apply(scope, this.$arguments.slice(3));
		this.dispatchEvent(Timer.EVENT_FIRE, this, this.$fires);
	}
	
	public function destroy():Void {
		this.$arguments.splice(0);
		delete this.$arguments;
		
		ArrayUtil.removeArrayItem(Interval.$intervalMap, this);
		
		super.destroy();
	}
}