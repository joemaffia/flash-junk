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
Internal class for {@link org.asapframework.management.sound.SoundManager} for storing sounds.
@author stephan.bezoen
*/

class org.asapframework.management.sound.SoundMovie {
	private var mName:String;
	private var mClip:MovieClip;
	private var currentLevel:Number;

	/**
	*	Constructor
	*	@param inName: unique identifying name
	*	@param inClip: container clip for sound clips
	*/
	function SoundMovie (inName:String, inClip:MovieClip) {
		mName = inName;
		mClip = inClip;
		currentLevel = 1;
	}

	/**
	*	Unique identifying name
	*/
	public function get name () : String {
		return mName;
	}

	/**
	*	Container movieclip
	*/
	public function get mc () : MovieClip {
		return mClip;
	}

	/**
	*	Create a movieclip for storage of a sound
	*/
	public function createClip (inName:String) : MovieClip {
		return mClip.createEmptyMovieClip(inName, currentLevel++);
	}

	public function toString () : String {
		return "; org.asapframework.management.sound.SoundMovie";
	}
}
