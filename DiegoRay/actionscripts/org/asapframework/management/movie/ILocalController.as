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
Interface for the LocalController class. See {@link LocalController} for details.
*/

interface org.asapframework.management.movie.ILocalController {
	public function notifyMovieInitialized () : Void;
	public function kill () : Void;
	public function start () : Void;
	public function stop () : Void;
	public function show () : Void;
	public function hide () : Void;
	public function getName () : String;
	public function setName (inName:String) : Void;
	public function getTimeline () : MovieClip;
	public function isStandalone () : Boolean;
}
