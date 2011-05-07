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
Gives information about the player environment the movie is playing in.
@author Arthur Clemens
*/

class org.asapframework.util.system.Environment {

	public static var PLUGIN:String = "plugin";
	public static var AUTHORING:String = "authoring";
	public static var STANDALONE:String = "standalone";

	/**
	Utility method to simply ask wether the Flash movie is in authoring mode or not.
	@return True is the movie is playing in authoring mode; false if not.
	*/
	public static function isAuthoringMode () : Boolean
	{
		return (Environment.getEnvironment() == "authoring");
	}

	/**
	Gets the environment in which the Flash movie is playing.
	@return A string as defined by the constants.
	@example
	<code>
	if (Environment.getEnvironment() == Environment.PLUGIN) {
		// do plugin behavior
	}
	</code>
	*/
	public static function getEnvironment () : String
	{
		//System.capabilities.playerType
		//StandAlone ( = standalone)
		//External: Flash IDE ( = authoring)
		//PlugIn ( = plugin)
		//ActiveX from within IE ( = plugin)

		var env:String = Environment.PLUGIN;
		if (CustomActions != undefined) {
			env = Environment.AUTHORING;
		} else if (_root._url.substr(0,4) == "file") {
			env = Environment.STANDALONE;
		}
		return new String(env);
	}
}
