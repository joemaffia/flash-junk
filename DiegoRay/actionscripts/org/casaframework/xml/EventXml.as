/*
	CASA Framework for ActionScript 2.0
	Copyright (C) 2007  CASA Framework
	http://casaframework.org
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

import org.casaframework.xml.DispatchableXml;

/**
	Dispatches XML event handler notification using {@link EventDispatcher}.
	
	@author Aaron Clinger
	@author Mike Creighton
	@version 04/03/07
	@example
		<code>
			import org.casaframework.xml.EventXml;
			
			function onXmlLoad(sender:EventXml, success:Boolean, status:Number):Void {
				if (success) {
					trace("Xml loaded: " + sender);
				} else {
					trace("Xml error: " + status);
				}
			}
			
			var myXml:EventXml = new EventXml();
			this.myXml.addEventObserver(this, EventXml.EVENT_LOAD, "onXmlLoad");
			this.myXml.load("example.xml");
		</code>
*/

class org.casaframework.xml.EventXml extends DispatchableXml {
	public static var EVENT_LOAD:String        = 'onLoad';
	public static var EVENT_DATA:String        = 'onData';
	public static var EVENT_HTTP_STATUS:String = 'onHttpStatus';
	
	
	/**
		@param text: The XML text parsed to create the new XML object.
	*/
	public function EventXml(text:String) {
		super(text);
		
		this.$setClassDescription('org.casaframework.xml.EventXml');
	}
	
	/**
		@exclude
		@sends onData = function(sender:EventXml, src:String) {}
	*/
	public function onData(src:String) {
		super.onData(src);
		this.dispatchEvent(EventXml.EVENT_DATA, this, src);
	}
	
	/**
		@exclude
		@sends onHttpStatus = function(sender:EventXml, httpStatus:Number) {}
	*/
	public function onHTTPStatus(httpStatus:Number) {
		super.onHTTPStatus(httpStatus);
		this.dispatchEvent(EventXml.EVENT_HTTP_STATUS, this, httpStatus);
	}
	
	/**
		@exclude
		@sends onLoad = function(sender:EventXml, success:Boolean, status:Number) {}
	*/
	public function onLoad(success:Boolean) {
		super.onLoad(success);
		this.dispatchEvent(EventXml.EVENT_LOAD, this, success, this.status);
	}
}