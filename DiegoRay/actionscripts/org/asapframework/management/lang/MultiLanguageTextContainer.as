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

// ASAP classes
import org.asapframework.management.lang.IMultiLanguageTextContainer;
import org.asapframework.management.lang.ItemData;
import org.asapframework.management.lang.LanguageManager;

/**
Basic implementation of {@link IMultiLanguageTextContainer} to be used with the {@link LanguageManager} to provide language dependent texts in an application.

To use this class, perform the following steps:
<ol>
<li>Create a new movieclip in the library</li>
<li>Give it a significant name containing font information, p.e. "arial 11px center"; this allows for easy reuse of containers</li>
<li>Link it to the class org.asapframework.management.lang.MultiLanguageTextContainer</li>
<li>Inside the movieclip, create a dynamic textfield. Name it "tf_txt"</li>
<li>Set font embedding as necessary</li>
<li>Place instances of the library item on the stage where necessary.</li>
<li>Name the instances whatever you like, as long as the name ends with underscore, followed by the integer id of the text to be associated with the instance. P.e.: "helloWorld_1"</li>
<li>In your application, load an xml file containing texts into the LanguageManager: <code>LanguageManager.getInstance().loadXML("texts_en.xml");</code></li>
</ol>

This class can be used either
<ul><li>directly,</li>
<li>as base class for further extension or </li>
<li>as example of how to implement the {@link IMultiLanguageTextContainer} interface.</li></ul>
*/

class org.asapframework.management.lang.MultiLanguageTextContainer extends MovieClip implements IMultiLanguageTextContainer {

	private var tf_txt:TextField;

	private var base_x:Number;
	private var base_y:Number;
	private var base_w:Number;

	/**
	Handle MovieClip onLoad event
	*/
	private function onLoad () : Void {
		base_x = tf_txt._x;
		base_y = tf_txt._y;
		base_w = tf_txt._width;

		var id:Number = parseInt(_name.substring(_name.lastIndexOf("_")+1), 10);

		LanguageManager.getInstance().addContainer(id, this);
	}
	
	/**
	Handle MovieClip onUnload event
	*/
	private function onUnload () : Void {
		LanguageManager.getInstance().removeContainer(this);
	}
	
	/**
	IMultiLanguageTextContainer implementation
	Set the data for the container
	@param inData: the object containing the data
	*/
	public function setData (inData : ItemData) : Void {
		setText(inData.text);
		
		tf_txt._x = base_x + inData.x_offset;
		tf_txt._y = base_y + inData.y_offset;
		tf_txt._width = base_w + inData.width_offset;
	}
	
	/**
	IMultiLanguageTextContainer implementation
	Set the text for the container
	@param inText: the string containing the text
	*/
	public function setText (inText:String) : Void {
		var tf:TextFormat = tf_txt.getTextFormat();
		tf_txt.autoSize = tf.align;

		if (tf_txt.html) {
			tf_txt.htmlText = inText;
		} else {
			tf_txt.text = inText;
		}
	}

	public function toString() : String {
		return ";org.asapframework.management.lang.MultiLanguageTextContainer";
	}
}
