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

import org.asapframework.data.filedatatransform.*;
import org.asapframework.util.StringUtilsSplit;

/**
Transforms the contents of a text file to an array by splitting the text in lines.
Lines that start with '#' are ignored.

Important: the file's text file should have Unix or DOS line endings.
@author Arthur Clemens
*/
class org.asapframework.data.filedatatransform.TextFile2Array extends TextFile2Collection {
	
	private var mItemDelimiter:String = newline; /**< Property delimiter. */
	
	/**
	Creates a new TextFile2Array instance.
	@param inFileUrl: url of the text file with data to parse
	@param inListener: (optional) object that receives a {@link TextFile2ArrayEvent#FINISHED} after parsing
	@param inCollection: (optional) existing Array to store the data in; if not provided a new Array will be created
	*/
	public function TextFile2Array (inFileUrl:String,
								    inListener:Object,
								    inArray:Array) 
	{
		super(inFileUrl, inListener, inArray);
	}
	
	/**
	Splits the received text data in lines and adds them to the Array passed in {@link #TextFile2Array}; if no Array was passed to the constructor, a new Array object is created.
	@param inSource: the file data
	@implementationNote After parsing, {@link #notifyFinished} is called.
	*/
	private function parse (inSource:String) : Void
	{
		addEventListener(TextFile2ArrayEvent.FINISHED, mListener);
		var lines:Array = inSource.split(mItemDelimiter);
		mCollection = new Array();
		var i:Number, ilen:Number = lines.length;
		for (i=0; i<ilen; ++i) {
			var line:String = lines[i];
			if (line.substr(0,1) == "#") {
				// comment
				continue;
			}
			mCollection.push(line);
		}
		notifyFinished();
	}

	/**
	Called when parsing is done.
	@sends TextFile2ArrayEvent#FINISHED
	*/
	private function notifyFinished () : Void {
		dispatchEvent(new TextFile2ArrayEvent(TextFile2ArrayEvent.FINISHED, Array(mCollection)));
		if (mListener != undefined) {
			removeEventListener(TextFile2ArrayEvent.FINISHED, mListener);
		}
	}

}