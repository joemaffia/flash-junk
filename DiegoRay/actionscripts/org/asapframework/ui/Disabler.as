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

/**
Disabler makes stage elements unreceptive for mouse and keyboard events by placing a 'event catching' movieclip on the stage.
@use
<code>
mDisabler = new Disabler(timeline, 0, 0, Stage.width, Stage.height);
// ...
mDisabler.disable(false);
</code>
*/

class org.asapframework.ui.Disabler {
	
	private static var LEVEL:Number = 19999;

	public var mc:MovieClip;


	public function Disabler (inMC:MovieClip, inX:Number, inY:Number, inW:Number, inH:Number) {
		
		mc = inMC.createEmptyMovieClip("disabler", LEVEL);
		mc._x = inX;
		mc._y = inY;

		mc.beginFill(0xFF0000, 0);
		mc.moveTo(0, 0);
		mc.lineTo(inW, 0);
		mc.lineTo(inW, inH);
		mc.lineTo(0, inH);
		mc.lineTo(0, 0);
		mc.endFill();

		mc._visible = false;

		mc.onRelease = function () : Void {};
		mc.enabled = false;
		mc.tabEnabled = false;
	}
	
	public function disable (inDoDisable:Boolean) : Void {
		mc._visible = inDoDisable;
	}
}
