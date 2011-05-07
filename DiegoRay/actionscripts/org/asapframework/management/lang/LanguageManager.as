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
import org.asapframework.events.Dispatcher;
import org.asapframework.events.Event;
import org.asapframework.events.EventDelegate;
import org.asapframework.management.lang.IMultiLanguageTextContainer;
import org.asapframework.management.lang.ItemData;
import org.asapframework.management.lang.MultiLanguageClipData;
import org.asapframework.util.debug.Log;
import org.asapframework.util.xml.XML2Object;
import org.asapframework.util.xml.XMLEvent;
import org.asapframework.util.xml.XMLLoader;

/**
Class for managing language dependencies in an application.
For text, the language dependent texts are expected to be in an xml per language, with the following structure:
<code>
<texts>
	<text id="1">Hello World</text>
	<text id="2" w="10">Hello World wider</text>
	<text id="3" x="50">Hello World shifted to the right</text>
	<text id="4"><[!CDATA[>>>Hello World<<<]]></text>
</texts>
</code>
The 'id' attribute is mandatory, and has to be a number. Attributes 'x', 'y' and 'w' are offsets to be applied to textfields, for the x-position, y-position and width respectively. These are optional.
In case the text contains xml characters, the text has to be wrapped in a {@code  <![CDATA[[]]>} tag.
The id is expected to be unique. When it isn't, the last item is taken.

The xml file containing the language dependent texts has to be loaded with the method {@link #loadXML}. 
When loaded and parsed, the LanguageManager sends an event of type LanguageManager.EVENT_LOADED. Subscribe to this event if you wish to be notified.
No event is sent when the loading fails, only a Log message of level ERROR is output.

Once an xml file has been loaded, data is available by id through {@link #getTextByID} and {@link #getDataByID}. Since the LanguageManager is a Singleton, the language dependent data is available throughout your application.

However, the LanguageManager also contains a mechanism for automatic assignment of data. To use this functionality, use the provided class {@link MultiLanguageTextContainer}, or write your own implementation of {@link IMultiLanguageTextContainer}.
When writing your own class, allow for a way to determine the id of the text that is to be used by a specific instance for your class. In case of the MultiLanguageTextContainer class, this id is retrieved from the name of the movieclip instance to which the class is linked, by taking everything after the last underscore and converting to a number. So "myText_1" gets the text with id=1.
Once the id is known inside your class, add the instance to the LanguageManager with {@link #addContainer}, providing the id and the instance itself as parameters. If data has been loaded, it is provided to the instance immediately. Whenever new data is loaded, the LanguageManager calls "setData" on each instance that was added, thereby updating language dependent text instantaneously.
A good spot to add an instance to the LanguageManager is in its onLoad() function. Make sure to remove it again in its onUnload() function, to allow for proper memory management. This also makes sure that the instance keeps its text when subject to animation key frames.
Instances can share the same id, and thereby have the same text.

By default, the LanguageManager returns an empty string (or provides an empty string in the data) when a requested id is not found. 
This has two drawbacks:
<ul><li>The textfield becomes effectively invisible since there is no text in it</li>
<li>Formatting of the textfield (such as weight or alignment) may be lost when the textfield is cleared</li></ul>
To allow for easier debugging, the flag {@link #generateDebugText} can be set. If an unknown id is requested, the returned text will be ">> id = #id", where #id is replaced with the actually requested id. This makes it easier to find missing texts from the xml files.

<b>Performance note</b>: The LanguageManager stores texts and containers in Arrays, without any sorting. It may be necessary to find more intricate lookup algorithms when dealing with large numbers of texts and/or containers.

@example
<ul>
<li>Loading an xml file into the LanguageManager, specifying a language code to be used in determining the name of the xml file to be loaded.
<code>
// @param inCode: 2-letter ISO language code; will be added to filename. Example: with parameter "en" the file "texts_en.xml" will be loaded.
private function loadLanguage (inCode:String) : Void {
	var lm:LanguageManager = LanguageManager.getInstance();
	lm.addEventListener(LanguageManager.EVENT_LOADED, EventDelegate.create(this, handleLanguageLoaded);
	lm.loadXML("../xml/texts_" + inCode + ".xml");
}

private function handleLanguageLoaded () : Void {
	Log.debug("handleLanguageLoaded: Language file loaded.", toString());
}
</code>
</li>

<li>Assigning a text to a textfield manually from anywhere in your code:
<code>myTextfield.text = LanguageManager.getInstance().getTextByID(23);</code>
</li>

<li>A class that gets a random text from the first 10 texts of the LanguageManager each time it is loaded:
<code>
class MyText extends MovieClip implements IMultiLanguageTextContainer {
	private var mID:Number;
	private var myTextField:TextField;
	
	public function setData (inData : ItemData) : Void {
		setText(inData.text);
	}
	
	public function setText (inText:String) : Void {
		myTextField.text = inText;
	}
	
	private function onLoad () : Void {
		mID = Math.floor(10 * Math.random());
		
		LanguageManager.getInstance().addContainer(mID, this);
	}
	
	private function onUnload () : Void {
		LanguageManager.getInstance().removeContainer(this);
	}
}
</code>
</li>
</ul>
*/

class org.asapframework.management.lang.LanguageManager extends Dispatcher {
	/** The event sent when the language xml has been loaded and parsed */	
	public static var EVENT_LOADED:String = "onLanguageLoaded";

	private var textDataItems:Array;	// of ItemData objects
	private var textClips:Array;		// of MultiLanguageClipData objects
		
	private var mXMLLoader:XMLLoader;
	private var mGenerateDebugText:Boolean = false;
		
	// singleton instance
	private static var instance:LanguageManager = null;
	private static var XML_NAME:String = "languagexml";

	private var mURL : String;
	
	
	
	/**
	@return The singleton instance of the LanguageManager
	*/
	public static function getInstance () : LanguageManager {
		if (instance == null) {
			instance = new LanguageManager();
		}
		return instance;
	}
	
	/**
	Load language XML
	@param inURL: full path of the xml file to be loaded
	*/
	public function loadXML (inURL:String) : Void {
		mURL = inURL;
		
		// start loading
		mXMLLoader.load(inURL,LanguageManager.XML_NAME, true);
	}
		
	/**
	Flag indicates whether items show their id as text when no text is found in the xml. When false, an empty string is returned when no text is found. 
	*/
	public function set generateDebugText (inGenerate:Boolean) : Void {
		mGenerateDebugText = inGenerate;
	}
	
	/**
	Add a multi-laguage container to the LanguageManager.
	If data has been loaded, the container will receive its data immediately.
	If the container had been added already, it will not be added again.
	@param inID: the id to be associated with the container
	@param inContainer: instance of a class implementing {@link IMultiLanguageTextContainer}
	*/
	public function addContainer (inID:Number, inContainer:IMultiLanguageTextContainer) : Void {
		
		if (getClipDataByContainer(inContainer) == null) {
			var mlcd:MultiLanguageClipData = new MultiLanguageClipData(inID, inContainer);
			textClips.push(mlcd);
		}
		inContainer.setData(getDataByID(inID));
	}

	/**
	Remove a multi-laguage container from the LanguageManager
	@param inContainer: previously added instance of a class implementing {@link IMultiLanguageTextContainer}
	*/
	public function removeContainer (inContainer:IMultiLanguageTextContainer) : Void {
		var index:Number = getClipDataIndexByContainer(inContainer); 
		if (index != null) {
			textClips.splice(index, 1);
		}
	}
		
	/**
	Add text for a specific ID to the language manager.
	Set the text in any IMultiLanguageTextContainer instance associated with that id.
	@param inData: {@link ItemData} instance containing necessary data.
	*/
	public function addText (inData:ItemData) : Void {
		
		textDataItems[inData.id] = inData;

		var len:Number = textClips.length;
		for (var i:Number=0; i<len; ++i) {
			var md:MultiLanguageClipData = MultiLanguageClipData(textClips[i]);			
			if (md.id == inData.id) {				
				md.cnt.setData(inData);
			}
		}		
	}
	
	/**
	Retrieve a text
	@param inID: the id for the text to be found
	@return the text if found, an empty string if generateDebugText is set to false, or '>> id = ' + id if generateDebugText is set to true
	*/
	public function getTextByID (inID:Number) : String {
		return getDataByID(inID).text;
	}
	
	/**
	Retrieve text data
	@param inID: the id for the text to be found
	@return the text data with the right text if found, with an empty string if generateDebugText is set to false, or with '>> id = ' + id if generateDebugText is set to true
	*/
	public function getDataByID (inID:Number) : ItemData {
		if (textDataItems[inID] == undefined) {
			if (mGenerateDebugText) {
				return new ItemData(inID, ">> id = " + inID);
			} else {
				return new ItemData(inID, "");
			}
		} else {
			return ItemData(textDataItems[inID]);
		}
	}
	
	/**
	Find the data block for the specified {@link IMultiLanguageTextContainer} instance
	@return the data block for the clip, or null if none was found
	*/
	private function getClipDataByContainer (inContainer:IMultiLanguageTextContainer) : MultiLanguageClipData {
		var len:Number = textClips.length;
		for (var i:Number=0; i<len; ++i) {
			var md:MultiLanguageClipData = MultiLanguageClipData(textClips[i]);
			if (md.cnt == inContainer) return md;
		}
		return null;
	}
	
	/**
	Find the index of the data block for the specified {@link IMultiLanguageTextContainer} instance
	@return the index of the data block, or -1 if none was found
	*/
	private function getClipDataIndexByContainer (inContainer:IMultiLanguageTextContainer) : Number {
		var len:Number = textClips.length;
		for (var i:Number=0; i<len; ++i) {
			var md:MultiLanguageClipData = MultiLanguageClipData(textClips[i]);
			if (md.cnt == inContainer) return i;
		}
		return -1;
	}
	
	/**
	Parses the loaded XML language document
	*/
	private function parseXML (inXML:XML) : Void {

		// convert to native object
		var o:Object = XML2Object.parseXML(inXML);
		
		// make sure <texts> node is interpreted as an Array
		var textDataItems:Array = XML2Object.makeArray(o.texts.text);
		
		// loop nodes
		var len:Number = textDataItems.length;
		for (var i:Number=0; i<len; ++i) {
			
			var t:Object = textDataItems[i];
			var t_a:Object = t.attributes;
			var text:String = t.data;
			
			var id:Number = parseInt(t_a.id.substring(t_a.id.lastIndexOf("_")+1), 10);
			
			// create a new item
			var item:ItemData = new ItemData(id, text);
			
			// check offsets
			if (t_a.w != undefined) item.width_offset = t_a.w;
			if (t_a.x != undefined) item.x_offset = t_a.x;
			if (t_a.y != undefined) item.y_offset = t_a.y;
			
			// add the item
			addText(item);
		}
	}
	
	/**
	Handle event from the XMLLoader that the XML file has been loaded.
	@param e: data for the event
	*/
	private function handleLanguageLoaded (e:XMLEvent) : Void {
		// was language file loaded?
		if (e.name == LanguageManager.XML_NAME) {
			
			// parse data
			parseXML(e.xmlSource);
			
			// dispatch event
			dispatchEvent( new Event( LanguageManager.EVENT_LOADED, this ) );
		}
	}
	
	/**
	Handle error event from the XMLLoader
	*/
	private function handleLanguageLoadError (e:XMLEvent) : Void {
		if (e.name == LanguageManager.XML_NAME) {
			Log.error("Error loading xml at url: " + mURL, toString());
		}
	}
	
	/**
	Private singleton constructor.
	*/
	private function LanguageManager() {
		
		super();
		
		// XML loader
		mXMLLoader = XMLLoader.getInstance();
		mXMLLoader.addEventListener(XMLEvent.ON_LOADED, EventDelegate.create(this,handleLanguageLoaded));
		mXMLLoader.addEventListener(XMLEvent.ON_ERROR, EventDelegate.create(this,handleLanguageLoadError));
		mXMLLoader.addEventListener(XMLEvent.ON_TIMEOUT, EventDelegate.create(this,handleLanguageLoadError));
		
		textDataItems = new Array();
		textClips = new Array();
	}
	
	/**
	@return Package and class name.
	*/
	public function toString () : String {
		return ";org.asapframework.management.lang.LanguageManager";
	}

}
