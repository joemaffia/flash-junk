/*
Copyright 2005-2006 by the authors of asapframework, http://asapframework.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Adobe classes
//import flash.geom.*;
// Still support Flash 7:
import org.asapframework.util.types.*;

// ASAP classes
import org.asapframework.util.actionqueue.*;


/**
<code>AQSpring.spring</code> controls a movieclip with spring effect.
@author Arthur Clemens
*/

class org.asapframework.util.actionqueue.AQSpring {

	private static var DEFAULT_HALT_SPEED:Number = 0.001;
	
	/**
	@param inMC : movieclip to move
	@param inTargetLoc : the location around which the movieclip moves defined as Point
	@param inSpring : stiffness variable, for instance: 10
	@param inDamp : friction variable, for instance: 0.9
	@param inMass : mass of movieclip, for instance: 10
	@param inShouldHalt : (optional) when true, the spring calculation will stop as soon as the speed is below a certain threshold (see parameter inHaltSpeed); default false
	@param inHaltSpeed : (optional) speed threshold when this method is stopped; default 0.001 pixels per frame
	@return true (this method has an onEnterFrame) (to flag optimization for ActionQueue).
	@example
	This example moves a movieclip around location (400, 300), until the final speed of 0.0001 is reached:
	<code>
	queue.addAction( AQSpring.spring, spring_mc, new Point(400, 300), 10, 0.9, 10, true, 0.0001);
	</code>
	*/
	
	public static function spring (inMC:MovieClip,
								   inTargetLoc:Point,
								   inSpring:Number,
								   inDamp:Number,
								   inMass:Number,
								   inShouldHalt:Boolean,
								   inHaltSpeed:Number) : ActionQueuePerformData {
		// Mass = Inertia effects
		// Spring = Stiffness effects
		// Damper = Friction effects
		var targetLoc:Point = (inTargetLoc != undefined) ? inTargetLoc : new Point(inMC._x, inMC._y);
		if (targetLoc.x == null) targetLoc.x = inMC._x;
		if (targetLoc.y == null) targetLoc.y = inMC._y;
		var haltSpeed = (inHaltSpeed != undefined) ? inHaltSpeed : DEFAULT_HALT_SPEED;
		
		var x:Number, y:Number;
		var xp:Number = 0;
		var yp:Number = 0;
		var c:Number = inSpring; // spring constant
		var k:Number = Math.sqrt( c / inMass );

		var springFunction:Function = function() : Boolean {
			x = -inMC._x + targetLoc.x;
			y = -inMC._y + targetLoc.y;
			
			xp = (xp * inDamp) + (x * k);
			yp = (yp * inDamp) + (y * k);

			inMC._x += xp;
			inMC._y += yp;
			if ( inShouldHalt && Math.abs(xp) < inHaltSpeed) {
				return false;
			}
			return true;
		};
		
		return new ActionQueuePerformData(springFunction, 0);
	}
}