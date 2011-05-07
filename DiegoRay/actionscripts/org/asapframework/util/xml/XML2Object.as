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
Returns a value object from an XML instance, that can be queried using dot syntax.
If a node has more than 1 child with the same name, an array is created with the children contents
The object created will have this structure:
<code>
obj {
nodeName :
	attributes : an object containing the node attributes
	data : an object containing the node contents
}
</code>
@author Arthur Clemens, Alessandro Crugnola
@use With the following xml file:
<code>
<?xml version="1.0" encoding="utf-8" ?>
<days>
	<subscription num="3">8-8-2004</subscription>
</days>
</code>
<code>
var xmlData:Object = XML2Object.parseXML( anXML );
var subscriptionText = xmlData.days.subscription.data;
// returns 8-8-2004
var num = xmlData.days.subscription.attributes.num;
// returns the string '3'
</code>

When you pass true as convertNumbers argument, the string will be converted to number:
<code>
var xmlData:Object = XML2Object.parseXML( anXML, true );
var num = xmlData.days.subscription.attributes.num;
// returns the number 3
</code>

Multiple child nodes of the same parent with the same name will be put into an array. However, there is no way of knowing at parse time whether a single node was meant to be an array. For that purpose, the function makeArray() can be used. 
@example
XML:
<code>
<L1>
	<L2>item 1</L2>
	<L2>item 2</L2>
</L1>
<L3>
	<L4>item 3</L4>
<L3>
</code>
After parsing, {@code L1.L2} will be an array with two items. {@code L3.L4} will be a single Object. With {@code XML2Object.makeArray(L3.L4)} {@code L3.L4} becomes a single item array.
*/

class org.asapframework.util.xml.XML2Object extends XML {
	private static var oResult:Object = new Object ();
	private static var oXML:XML;

	/**
	The xml passed in the parseXML method.
	*/
	public static function get xml () : XML {
		return oXML;
	}

	/**
	Creates an value object from an XML instance.
	@param xmlData XML instance to parse
	@param convertNumbers Set to true to automatically convert number strings to numbers (all text in xml is treated as text otherwise)
	@returns an Object with the contents of the passed XML
	@use <code>XML2Object.parseXML( theXMLtoParse );</code>
	*/
	public static function parseXML (inXmlData:XML, convertNumbers:Boolean) : Object

	{
		XML2Object.oResult = new Object ();
		XML2Object.oXML = inXmlData;
		XML2Object.oResult = XML2Object.translateXML(convertNumbers);
		return XML2Object.oResult;
	}

	/**
	Core translation engine.
	*/
	private static function translateXML (convertNumbers, from, path, name, position) : Object {
		var nodes, node, old_path, a;
		if (path == undefined) {
			path = XML2Object;
			name = "oResult";
		}
		path = path[name];
		if (from == undefined) {
			from = new XML (XML2Object.xml.toString());
			from.ignoreWhite = true;
		}
		if (from.hasChildNodes ()) {
			nodes = from.childNodes;
			if (position != undefined) {
				old_path = path;
				path = path[position];
			}
			while (nodes.length > 0) {
				node = nodes.shift ();
				if (node.nodeName != undefined) {
					var __obj__ = new Object ();
					if (convertNumbers) {
						for (a in node.attributes) {
							if(__obj__.attributes == undefined) {
								__obj__.attributes = new Object();
							}
							var att = node.attributes[a];
							__obj__.attributes[a] = isNaN(Number(att)) ? att : Number(att);
						}
					} else {
						__obj__.attributes = node.attributes;
					}
					var d = node.firstChild.nodeValue;
					if( convertNumbers) {
						// just take the value and find possible number
						__obj__.data = isNaN(Number(d)) ? d : Number (d);
					} else {
						__obj__.data = d;
					}
					if (position != undefined) {
						old_path = path;
					}
					if (path[node.nodeName] != undefined) {
						if (path[node.nodeName] instanceof Array) {
							path[node.nodeName].push (__obj__);
							name = node.nodeName;
							position = path[node.nodeName].length - 1;
						} else {
							var copyObj = path[node.nodeName];
							path[node.nodeName] = new Array ();
							path[node.nodeName].push (copyObj);
							path[node.nodeName].push (__obj__);
							name = node.nodeName;
							position = path[node.nodeName].length - 1;
						}
					} else {
						path[node.nodeName] = __obj__;
						name = node.nodeName;
						position = undefined;
					}
				}
				if (node.hasChildNodes ()) {
					XML2Object.translateXML (convertNumbers, node, path, name, position);
				}
			}
		}
		return XML2Object.oResult;
	}

	/**
	Check whether the input item is an array, if not, make an array with the input item as single value.
	@param inObj:Object
	@return Array
	*/
	public static function makeArray (inObj) : Array {
		if (inObj != undefined) {
			return (inObj instanceof Array) ? inObj : [inObj];
		} else {
			return new Array();
		}
	}
}
