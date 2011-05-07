import flash.display.BitmapData;
class com.pixelfumes.Reflect {
	private var version:String = "3.0";
	private var mcBMP:BitmapData;
	private var reflectionBMP:BitmapData;
	private var updateInt:Number;
	private var bounds:Object;
	private var clip:MovieClip;
	private var distance:Number = 0;
	
	function Reflect(args:Object) {
		var mc:MovieClip = args.mc;
		var alpha:Number = args.alpha;
		var ratio:Number = args.ratio;
		var updateTime:Number = args.updateTime;
		var reflectionAlpha:Number = args.reflectionAlpha;
		var reflectionDropoff:Number = args.reflectionDropoff;
		var distance:Number = args.distance;
		
		//class reference to reflected clip
		clip = mc;
		var mcHeight = (mc._height/mc._yscale)*100;
		var mcWidth = (mc._width/mc._xscale)*100;
		//
		bounds = new Object();
		bounds.width = mcWidth;
		bounds.height = mcHeight;
		//
		var matrixHeight:Number;
		if (reflectionDropoff<=0) {
			matrixHeight = bounds.height;
		} else {
			matrixHeight = bounds.height/reflectionDropoff;
		}
		//
		mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
		mcBMP.draw(mc);
		//
		reflectionBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
		reflectionBMP.draw(mc);
		//
		mc.createEmptyMovieClip("reflection_mc", mc.getNextHighestDepth());
		mc.reflection_mc.attachBitmap(mcBMP, 1);
		mc.reflection_mc._yscale = -100;
		mc.reflection_mc._y = (bounds.height*2) + distance;
		mc.reflection_mc._alpha = reflectionAlpha;
		//create the gradient mask
		mc.createEmptyMovieClip("gradientMask_mc", mc.getNextHighestDepth());
		var fillType:String = "linear";
		var colors:Array = [0xFFFFFF, 0xFFFFFF];
		var alphas:Array = [alpha, 0];
		var ratios:Array = [0, ratio];
		var matrix = {matrixType:"box", x:0, y:0, w:bounds.width, h:matrixHeight, r:(90/180)*Math.PI};
		
		var spreadMethod:String = "pad";
		mc.gradientMask_mc.beginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod);
		mc.gradientMask_mc.moveTo(0, 0);
		mc.gradientMask_mc.lineTo(0, bounds.height);
		mc.gradientMask_mc.lineTo(bounds.width, bounds.height);
		mc.gradientMask_mc.lineTo(bounds.width, 0);
		mc.gradientMask_mc.lineTo(0, 0);
		mc.gradientMask_mc.endFill();
		mc.gradientMask_mc._y = bounds.height + distance;
		mc.reflection_mc.cacheAsBitmap = true;
		mc.gradientMask_mc.cacheAsBitmap = true;
		mc.reflection_mc.setMask(mc.gradientMask_mc);
		//
		if(updateTime != null){
			updateInt = setInterval(this, "update", updateTime, mc);
		}
	}
	private function redrawBMP(mc:MovieClip):Void {
		// redraws bitmap - Mim Gamiet [2006]
		mcBMP.dispose();
		mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
		mcBMP.draw(mc);
	}
	private function update(mc):Void {
		mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
		mcBMP.draw(mc);
		reflectionBMP.draw(mc);
		mc.reflection_mc.attachBitmap(mcBMP, 1);
	}
	private function setBounds(w:Number,h:Number):Void{
		bounds.width = w;
		bounds.height = h;
		reflectionBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
		clip.gradientMask_mc._width = bounds.width;
		redrawBMP(clip);
	}
	private function destroy():Void{
		reflectionBMP.dispose();
		mcBMP.dispose();
		clearInterval(updateInt);
		removeMovieClip(clip.reflection_mc);
		removeMovieClip(clip.gradientMask_mc);
	}
}
