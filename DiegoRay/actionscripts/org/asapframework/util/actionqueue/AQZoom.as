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
import org.asapframework.util.RectangleUtils;
import org.asapframework.util.PointUtils;
import org.asapframework.util.MovieClipUtils;


/**
Collection of ActionQueue methods to zoom in or out a movieclip. The movieclip is enlarged (or shrunk) by scaling it and held in the correct position by moving it. Any position can be given as view loc 'pivot' point ({@link #zoom}). The movieclip can be moved while zooming ({@link #zoomAndMove}), or panned (inverse moved, relative to a view port ({@link #zoomAndPan}).


@usageNote From Flash 8 Help: <em>Avoid zooming into cached surfaces. If you overuse bitmap caching, a large amount of memory is consumed (see previous bullet), especially if you zoom in on the content.</em>
@author Arthur Clemens
*/
	
class org.asapframework.util.actionqueue.AQZoom {
	
	private static var START_VALUE:Number = 1; /**< Start animation value to be returned to the perform function. */
	private static var END_VALUE:Number = 0; /**< End animation value to be returned to the perform function. */
	
	/**
	Zooms a movieclip in or out.
	@param inMC : movieclip to zoom and pan
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant zoom
	@param inStartScale : the movieclip's scaling to start zooming from; if null then inMC's current scale value (_xscale and _yscale) is used
	@param inEndScale : the movieclip's scaling to end zooming to; if null then inMC's current scale value (_xscale and _yscale) is used
	@param inViewLoc : (optional) The movieclip's point from where zooming occurs, relative to the clip's origin; if null then point (0,0) is used. Use <code>RectangleUtils.centerPointOfMovieClip(my_mc, my_mc)</code> to get the center of the movieclip (in case the movieclip is not already centered). Note: by default the view loc is not used to center the clip when panning - use <code>inViewLocEndMoveLoc</code>.
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return The return value of {@link #zoomAndMove}.
	@implementationNote This method calls {@link #zoomAndMove}.
	@example
	This code fragment zooms in a movieclip in 1 second to a scale of 200:
	<code>
	queue.addAction( AQZoom.zoom, my_mc, 1.0, null, 200 );
	</code>
	
	This code fragment uses the zoom from above, with a easing out effect:
	<code>
	import mx.transitions.easing.*;
	
	queue.addAction( AQZoom.zoom, my_mc, 1.0, null, 200, null, Strong.easeOut );
	</code>
	
	The following code fragment uses the bottom right corner of a clip to zoom in from:
	<code>
	import org.asapframework.util.RectangleUtils;
	
	var rect:Rectangle = RectangleUtils.rectOfMovieClip(my_mc);
	var viewLoc:Point = new Point(rect.right, rect.bottom);
	queue.addAction( AQZoom.zoom, my_mc, 1.0, null, 200, viewLoc);
	</code>
	*/
	public static function zoom (inMC:MovieClip,
								 inDuration:Number,
								 inStartScale:Number,
								 inEndScale:Number,
								 inViewLoc:Point,
								 inEffect:Function) : ActionQueuePerformData {

		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(6, arguments.length - 6);
		
		var args:Array = [inMC, inDuration, inStartScale, inEndScale, inViewLoc, null, null, null, inEffect];
		if (effectParams != undefined) {
			args.concat(effectParams);
		}
		return AQZoom.zoomAndMove.apply(null, args);
	}
	
	/**
	Panning is the horizontal movement of a camera viewing at a scene. When the camera pans to the right, the scene moves (relatively) to the left. Vertical panning is also known as tilting, where the same principle occurs: the camera tilts up, and the scene moves relatively down.
	<code>zoomAndPan</code> works with the metaphor of a camera moving (inStartCameraLoc and inEndCameraLoc) over a scene (the movieclip inMC). The camera is always positioned at the center of a view port (inViewPort; most likely the Stage the movieclip is on).
	@param inMC : movieclip to zoom and pan
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant zoom
	@param inStartScale : the movieclip's scaling to start zooming from; if null then inMC's current scale value (_xscale and _yscale) is used
	@param inEndScale : the movieclip's scaling to end zooming to; if null then inMC's current scale value (_xscale and _yscale) is used
	@param inViewPort : the framed area on the screen behind which the scene (inMC) moves
	@param inStartCameraLoc : the starting camera position
	@param inEndCameraLoc : the end camera position
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return The return value of {@link #zoomAndMove}.
	@implementationNote This method calls {@link #zoomAndMove}.
	*/
	public static function zoomAndPan (inMC:MovieClip,
									   inDuration:Number,
									   inStartScale:Number,
									   inEndScale:Number,
									   inViewPort:Rectangle,
									   inStartCameraLoc:Point,
									   inEndCameraLoc:Point,
									   inEffect:Function) : ActionQueuePerformData {
									   
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(8, arguments.length - 8);
		
		var startCameraLoc:Point = (inStartCameraLoc != undefined) ? inStartCameraLoc : new Point(inMC._x, inMC._y);
		
		var viewCenter:Point = RectangleUtils.getCenter(inViewPort);
		var endCameraLoc:Point = PointUtils.multiply(inEndCameraLoc, inEndScale/100);
		endCameraLoc = viewCenter.subtract(endCameraLoc);
		
		var args:Array = [inMC, inDuration, inStartScale, inEndScale, null, startCameraLoc, endCameraLoc, null, inEffect];
		if (effectParams != undefined) {
			args.concat(effectParams);
		}
		return AQZoom.zoomAndMove.apply(null, args);
	}
	
	/**
	Zooms a movieclip from one rectangle size to another.
	@param inMC : movieclip to zoom
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant zoom
	@param inStartRect : the movieclip start bounds; if null, the current clip bounds are used relative to the clip's parent 
	@param inEndRect : the movieclip end bounds; if null, the current clip bounds are used relative to the clip's parent
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return The return value of {@link #zoomAndMove}.
	@implementationNote This method calls {@link #zoomAndMove}.
	*/
	public static function zoomRect (inMC:MovieClip,
									 inDuration:Number,
									 inStartRect:Rectangle,
									 inEndRect:Rectangle,
									 inEffect:Function) : ActionQueuePerformData {
		
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(5, arguments.length - 5);
				
		var startRect:Rectangle = (inStartRect != undefined) ? inStartRect : RectangleUtils.boundsOfMovieClip(inMC, inMC._parent);
		var endRect:Rectangle = (inEndRect != undefined) ? inEndRect : RectangleUtils.boundsOfMovieClip(inMC, inMC._parent);
		
		var startScale:Number = MovieClipUtils.getNormalizedScale(inMC, new Point(startRect.width, startRect.height));
		var endScale:Number = MovieClipUtils.getNormalizedScale(inMC, new Point(endRect.width, endRect.height));
		
		var startCameraLoc:Point = RectangleUtils.getCenter(startRect);
		var endCameraLoc:Point = RectangleUtils.getCenter(endRect);
		
		var args:Array = [inMC, inDuration, startScale, endScale, null, startCameraLoc, endCameraLoc, null, inEffect];
		if (effectParams != undefined) {
			args.concat(effectParams);
		}
		return AQZoom.zoomAndMove.apply(null, args);
	}
	

	/**
	Zooms a movieclip in or out, and optionally moves the clip while zooming.
	@param inMC : movieclip to zoom and move
	@param inDuration : length of animation in seconds; 0 is used for perpetual animations - use -1 for instant zoom
	@param inStartScale : the movieclip's scaling to start zooming from; if null then inMC's current scale value (_xscale and _yscale) is used
	@param inEndScale : the movieclip's scaling to end zooming to; if null then inMC's current scale value (_xscale and _yscale) is used
	@param inViewLoc : (optional) The movieclip's point from where zooming occurs, relative to the clip's origin; if null then point (0,0) is used. Use <code>RectangleUtils.centerPointOfMovieClip(my_mc, my_mc)</code> to get the center of the movieclip (in case the movieclip is not already centered). Note: by default the view loc is not used to center the clip when panning - use <code>inViewLocEndMoveLoc</code>.
	@param inStartMoveLoc : (optional) the movieclip's position to start moving from; if null then inMC's current (_x,_y) position is used
	@param inEndMoveLoc : (optional) the movieclip's position to end moving to; if null then inMC's current (_x,_y) position is used
	@param inViewLocEndMoveLoc: (optional) the position to move the clip's <em>view loc</em> to
	@param inEffect : (optional) An effect function, for instance one of the mx.transitions.easing methods. Arguments to pass the effect function may be appended as a comma-separated list.
	@return A new ActionQueuePerformData object.
	@example
	The following example zooms a movieclip from the movieclip center to a target point with an easing out effect. See explanation below.
	<code>
	import mx.transitions.easing.*;
	import org.asapframework.util.RectangleUtils;
	
	var viewLoc:Point = RectangleUtils.centerPointOfMovieClip(my_mc, my_mc); // the center of the clip
	var targetLoc:Point = new Point(300,170);
	var duration:Number = 2.5;
	var endScale:Number = 200;
	
	var queue:ActionQueue = new ActionQueue();
	queue.addAction( AQZoom.zoomAndMove, my_mc, duration, null, endScale, viewLoc, null, targetLoc, targetLoc, Strong.easeOut );
	queue.run();
	</code>
	AQZoom.zoom parameters:
	<ul>
		<li>Zooming is done from the current scale (null) to endScale (200).</li>
		<li>The movieclip is scaled relative to point viewLoc - this has the effect that all sides will move out as the clip grows (which happens naturally when a clip has its anchor point in the center).</li>
		<li>Moving will occur from the current position (null) to targetLoc.</li>
		<li>The movieclip <em>view loc</em> is moved to targetPoint - this has the effect that the movieclips' center will move to targetPoint.</li>
	</ul>
	*/
	public static function zoomAndMove (inMC:MovieClip,
									    inDuration:Number,
									    inStartScale:Number,
									    inEndScale:Number,
									    inViewLoc:Point,
									    inStartMoveLoc:Point,
									    inEndMoveLoc:Point,
									    inViewLocEndMoveLoc:Point,
									    inEffect:Function) : ActionQueuePerformData {
		
		// get effect parameters that are optionally passed after inEffect
		var effectParams:Array = arguments.splice(9, arguments.length - 9);
		
		var startScaleX:Number = (inStartScale != undefined) ? inStartScale : inMC._xscale;
		var startScaleY:Number = (inStartScale != undefined) ? inStartScale : inMC._yscale;
		var endScaleX:Number = (inEndScale != undefined) ? inEndScale : inMC._xscale;
		var endScaleY:Number = (inEndScale != undefined) ? inEndScale : inMC._yscale;
		var changeScaleX:Number = endScaleX - startScaleX;
		var changeScaleY:Number = endScaleY - startScaleY;		
		
		// the view loc is the point in the clip (relative to the clip) from where zooming occurs
		// calculate the offset from the view loc
		var viewLoc:Point = (inViewLoc != undefined) ? inViewLoc : new Point();
		var viewLocStartOffset:Point = new Point(viewLoc.x * ((100 - startScaleX) * 0.01), viewLoc.y * ((100 - startScaleY) * 0.01));
		var viewLocEndOffset:Point = new Point(viewLoc.x * ((100 - endScaleX) * 0.01), viewLoc.y * ((100 - endScaleY) * 0.01));
		var changeViewLocOffset:Point = viewLocEndOffset.subtract(viewLocStartOffset);
		
		var startMoveLoc:Point = (inStartMoveLoc != undefined) ? inStartMoveLoc : new Point(inMC._x - viewLocStartOffset.x, inMC._y - viewLocStartOffset.y);
		var endMoveLoc:Point = (inEndMoveLoc != undefined) ? inEndMoveLoc : new Point(inMC._x - viewLocStartOffset.x, inMC._y - viewLocStartOffset.y);
		
		if (inViewLocEndMoveLoc) {
			
			//var defaultViewLocEndPoint:Point = endMoveLoc.add(viewLoc);
			// Still support Flash 7:
			var defaultViewLocEndPoint:Point = endMoveLoc.addPoint(viewLoc);
			var viewLocEndPointOffset:Point = inViewLocEndMoveLoc.subtract(defaultViewLocEndPoint);
			//endMoveLoc = endMoveLoc.add(viewLocEndPointOffset);
			// Still support Flash 7:
			endMoveLoc = endMoveLoc.addPoint(viewLocEndPointOffset);
		}
		
		var changeMoveLoc:Point = endMoveLoc.subtract(startMoveLoc);

		var hasOffset:Boolean = (changeViewLocOffset.x == 0 && changeViewLocOffset.y == 0) ? false : true;
		var offset:Point = new Point();
				
		var performFunction:Function = function (inPerc:Number) {
			// inPerc = percentage counting down from START_VALUE to END_VALUE
			inMC._xscale = endScaleX - (inPerc * changeScaleX);
			inMC._yscale = endScaleY - (inPerc * changeScaleY);
			
			inMC._x = endMoveLoc.x - (inPerc * changeMoveLoc.x);
			inMC._y = endMoveLoc.y - (inPerc * changeMoveLoc.y);
			
			if (hasOffset) {
				offset.x = viewLocEndOffset.x - (inPerc * changeViewLocOffset.x);
				offset.y = viewLocEndOffset.y - (inPerc * changeViewLocOffset.y);
				inMC._x += offset.x;
				inMC._y += offset.y;
			}
		};
		
		return new ActionQueuePerformData(performFunction, inDuration, START_VALUE, END_VALUE, inEffect, effectParams);
	}
	
}
