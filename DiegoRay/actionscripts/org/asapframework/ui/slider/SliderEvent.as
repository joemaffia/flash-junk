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

import org.asapframework.events.Event;
import org.asapframework.ui.slider.Slider;


/**
Used by the {@link Slider} to send events about the state of a slider.
*/

class org.asapframework.ui.slider.SliderEvent extends Event {
	
	public static var ON_SLIDE:String = "onSliderMoved";
	public static var ON_SLIDE_DONE:String = "onSliderMoveDone";
	
	public var min:Number;
	public var value:Number;
	public var max:Number;
	public var percentage:Number;
	
	function SliderEvent (inType:String,
						  inSource:Slider,
						  inMin:Number,
						  inValue:Number,
						  inMax:Number) {
		
		super(inType, inSource);
		min = inMin;
		value = inValue;
		max = inMax;
		
		percentage = (value - min) / (max - min) * 100;
	}
}