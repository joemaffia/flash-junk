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

/*
	ValueObject class for Postcenter
*/

class org.asapframework.util.postcenter.PostCenterMessage {

	public var message:String;
	public var window:String;

	/**
	Creates a new PostCenterMessage.
	@param inMessage : the text to send
	@param inWindow : (optional) see GetURL window parameters (	"self", "_blank", "_parent", "_top")
	*/
	public function PostCenterMessage ( inMessage:String, inWindow:String) {
	
		message = inMessage;
		if (inWindow != undefined) window = inWindow;
	}
}
