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

import org.asapframework.util.postcenter.PostCenterMessage;

/**
*	@author Arthur Clemens, Martijn de Visser (added support for 'window' parameter)
*	@description Windows IE cannot handle getURL messages that are send quickly in succession; PostCenter functions as intermediary and queues messages to send them in a batch. If you need to sent getURLs from multiple places in your application it becomes a difficult task to manage the timings of these messages. It is safer to let PostCenter deal with this.
*	@use PostCenter uses the static method <code>send</code>, so you don't need to create a class instance. The method can be called from multiple places in your application by using <code>PostCenter.send(message)</code>:
	<code>
	var message:String;
	message = "javascript:alert('message one');";
	PostCenter.send(message);
	message = "javascript:alert('message two');";
	PostCenter.send(message);	
	</code>
*	@todo PostCenter currently ignores the getURL parameter 'method' ("GET" or "POST").
*/

class org.asapframework.util.postcenter.PostCenter {

	private static var sMessages:Array = [];			// array of PostCenterMessage objects
	static private var sPostInterval:Number = 0; 		// 0 if reset
	private static var SEND_DELAY:Number = 200; 		// number of msecs in between posting
						
	/**
	*	Adds a message to the send queue.
	*	@param message Message string to be sent.
	*	@param window Window to send message to. Will be used as second 'window' parameter in getURL action when message is sent.
	*/
	public static function send ( inMessage:String, inWindow:String ) : Void {
		
		var message:PostCenterMessage = new PostCenterMessage(inMessage,inWindow);
		sMessages.push(message);

		if (sPostInterval == 0) {
			// the first message is sent without delay
			// only subsequent messages are delayed with time SEND_DELAY
			sPostInterval = setInterval(doSendMessages, 0);
		}
	}
	
	/**
	*	Performs the actual posting.
	*/
	private static function doSendMessages () : Void {
		
		clearInterval(sPostInterval);
		sPostInterval = 0;

		if (sMessages.length == 0) {
			return;
		}
		
		// concatenate messages as long as no target window is specified
		var outText:String = "";
		var i:Number, ilen:Number = sMessages.length;
		for (i=0; i<ilen; ++i) {
			if (sMessages[0] && sMessages[0].window != undefined) {
				// if window is specified stop concatenating
				if (outText.length == 0) {
					// if no message has been collected, send the first window message now
					var msg:PostCenterMessage = PostCenterMessage(sMessages.shift());
					getURL(msg.message, msg.window);
					sPostInterval = setInterval(doSendMessages, SEND_DELAY);
					return;
				}
				break;
			} else {
				var msg:PostCenterMessage = PostCenterMessage(sMessages.shift());
				outText += msg.message;
			}
		}
		getURL(outText);
		
		// for subsequent messages:
		sPostInterval = setInterval(doSendMessages, SEND_DELAY);
	}
}