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
import org.casaframework.control.ResumeableInterface;
import org.casaframework.time.EnterFrame;
import org.casaframework.time.FrameTimeStopwatch;
import org.casaframework.math.Percent;

/**
	Simple and easily extendable tween class.
	
	Advantages of using this tween class over others:
	<ul>
		<li>Does not include any tweening equations, only the equation(s) a user defines. This allows for a much smaller class/swf file.</li>
		<li>Using built in events/event dispatcher you are able to tween more than one value.</li>
		<li>Ability to tween any value, not only MovieClip properties.</li>
		<li>Works with all easing equations that follow the currentTime, startPosition, endPosition, totalTime standard.</li>
	</ul>

	@author Aaron Clinger
	@author Mike Creighton
	@version 07/11/07
	@example
		<code>
			function onEasePosition(sender:Tween, position:Number):Void {
				this.box_mc._x = this.box_mc._y = position;
			}
			
			var slideMotion:Tween = new Tween(com.robertpenner.easing.Bounce.easeOut, 0, 250, 1.5);
			slideMotion.addEventObserver(this, Tween.EVENT_POSITION, "onEasePosition");
			slideMotion.start();
		</code>
		
		If you want to tween an item on a curve you can use the {@link Ellipse} class and its {@link Ellipse#getPointOfDegree getPointOfDegree} function:
		<code>
			function onCurvePosition(sender:Tween, degree:Number):Void {
				var position:Point = this.curve.getPointOfDegree(degree);
				this.box_mc._x = position.getX();
				this.box_mc._y = position.getY();
			}
			
			var curve:Ellipse = new Ellipse(20, 50, 300, 200);
			var slideMotion:Tween = new Tween(com.robertpenner.easing.Elastic.easeInOut, 0, 360, 4);
			slideMotion.addEventObserver(this, Tween.EVENT_POSITION, "onCurvePosition");
			slideMotion.start();
		</code>
	@usageNote If you want to tween a property use {@link PropertyTween}.
	@see <a href="http://www.robertpenner.com/easing/">Robert Penner's easing equations</a>
	@see {@link PropertySetter}
*/

class org.casaframework.transitions.Tween extends EventDispatcher implements ResumeableInterface {
	public static var EVENT_START:String    = 'onStart';
	public static var EVENT_STOP:String     = 'onStop';
	public static var EVENT_RESUME:String   = 'onResume';
	public static var EVENT_POSITION:String = 'onPosition';
	public static var EVENT_PROGRESS:String = 'onProgress';
	public static var EVENT_COMPLETE:String = 'onComplete';
	
	private var $framePulse:EnterFrame;
	private var $stopwatch:FrameTimeStopwatch;
	private var $equat:Function;
	private var $destroyed:Boolean;
	private var $useFrames:Boolean;
	private var $completed:Boolean;
	private var $stopped:Boolean;
	private var $currentPosition:Number;
	private var $frameFires:Number;
	private var $begin:Number;
	private var $time:Number;
	private var $diff:Number;
	private var $end:Number;
	
	/**
		Creates and defines tween.
		
		@param equation: Tween equation.
		@param startPos: The starting value of the tween.
		@param endPos: The ending value of the tween.
		@param duration: Length of time of the tween.
		@param useFrames: <strong>[optional]</strong> Indicates to use frames <code>true</code>, or seconds <code>false</code> in relation to the value specified in the <code>duration</code> parameter; defaults to <code>false</code>.
		
		@usageNote The function specified in the <code>equation</code> parameter must follow the (currentTime, startPosition, endPosition, totalTime) parameter standard.
		@see <a href="http://www.robertpenner.com/easing/">Robert Penner's easing equations</a>
	*/
	public function Tween(equation:Function, startPos:Number, endPos:Number, duration:Number, useFrames:Boolean) {
		super();
		
		this.$setClassDescription('org.casaframework.transitions.Tween');
		
		this.$equat     = equation;
		this.$begin     = this.$currentPosition = startPos;
		this.$end       = endPos;
		this.$diff      = this.$end - this.$begin;
		this.$time      = duration;
		this.$useFrames = (useFrames == undefined) ? false : useFrames;
		
		if (!this.$useFrames) {
			this.$time *= 1000;
			this.$stopwatch = new FrameTimeStopwatch();
		}
		
		this.$framePulse = EnterFrame.getInstance();
		
		this.$stopped   = true;
		this.$destroyed = false;
	}
	
	/**
		Starts tween from start position.
		
		@sends onStart = function(sender:Tween) {}
	*/
	public function start():Void {
		if (this.$destroyed)
			return;
		
		if (this.$useFrames)
			this.$frameFires = 0;
		else
			this.$stopwatch.start();
		
		this.$stopped = this.$completed = false;
		this.$framePulse.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onFrame');
		this.dispatchEvent(Tween.EVENT_START, this);
	}
	
	/**
		Stops tween at current position.
		
		@sends onStop = function(sender:Tween) {}
	*/
	public function stop():Void {
		if (this.$stopped || this.$completed || this.$destroyed)
			return;
		
		this.$stopped = true;
		
		if (!this.$useFrames)
			this.$stopwatch.stop();
		
		this.$framePulse.removeEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onFrame');
		this.dispatchEvent(Tween.EVENT_STOP, this);
	}
	
	/**
		Resumes tween from {@link Tween#stop stopped} position.
		
		@sends onResume = function(sender:Tween) {}
	*/
	public function resume():Void {
		if (!this.$stopped || this.$completed || this.$destroyed)
			return;
		
		this.$stopped = false;
		
		if (!this.$useFrames)
			this.$stopwatch.resume();
		
		this.$framePulse.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onFrame');
		this.dispatchEvent(Tween.EVENT_RESUME, this);
	}
	
	/**
		Instructs to tween from its current position to a new finish and duration position.
		
		@param endPos: The ending value of the tween.
		@param duration: Length of time of the tween.
		@usageNote Will automatically start tween if currently stopped.
	*/
	public function continueTo(endPos:Number, duration:Number):Void {
		if (this.$destroyed)
			return;
		
		this.$begin = this.$currentPosition;
		this.$end   = endPos;
		this.$diff  = this.$end - this.$begin;
		this.$time  = (this.$useFrames) ? duration : duration * 1000;
		
		this.start();
	}
	
	/**
		@sends onProgress = function(sender:Tween, progress:Percent) {}
		@sends onPosition = function(sender:Tween, position:Number) {}
		@sends onComplete = function(sender:Tween) {}
	*/
	private function $onFrame():Void {
		var finished:Boolean = false;
		var timePos:Number   = this.$getProgress();
		var duration:Number  = this.$time;
		
		if (timePos >= duration) {
			if (duration == 0)
				duration = 1;
			
			timePos  = duration;
			finished = true;
		}
		
		this.$currentPosition = this.$equat(timePos, this.$begin, this.$diff, duration);
		
		this.dispatchEvent(Tween.EVENT_PROGRESS, this, new Percent(timePos / duration));
		this.dispatchEvent(Tween.EVENT_POSITION, this, this.$currentPosition);
		
		if (finished) {
			if (!this.$useFrames)
				this.$stopwatch.stop();
			
			this.$framePulse.removeEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onFrame');
			this.$stopped = this.$completed = true;
			this.dispatchEvent(Tween.EVENT_COMPLETE, this);
		}
	}
	
	private function $getProgress():Number {
		if (this.$useFrames)
			return ++this.$frameFires;
		else
			return this.$stopwatch.getTime();
	}
	
	public function destroy():Void {
		this.$destroyed = true;
		
		this.$framePulse.removeEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onFrame');
		this.$stopwatch.destroy();
		
		delete this.$framePulse;
		delete this.$stopwatch;
		delete this.$equat;
		delete this.$useFrames;
		delete this.$completed;
		delete this.$stopped;
		delete this.$currentPosition;
		delete this.$frameFires;
		delete this.$begin;
		delete this.$time;
		delete this.$diff;
		delete this.$end;
		
		super.destroy();
	}
}
