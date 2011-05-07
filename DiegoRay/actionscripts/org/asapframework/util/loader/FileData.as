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

class org.asapframework.util.loader.FileData {

	private var mLocation:MovieClip;
	private var mUrl:String;
	private var mName:String;
	private var mVisible:Boolean;
	private var mBytesTotal:Number;
	private var mBytesLoaded:Number;

	/**
	
	*/
	public function FileData (inLoc:MovieClip, inUrl:String, inName:String, inIsVisible:Boolean) {
		mLocation = inLoc;
		mUrl = inUrl;
		mName = inName;
		mVisible = inIsVisible;
	}
	
	/**
	
	*/
	public function set location (inLocation:MovieClip) : Void {
		mLocation = inLocation;
	}
	public function get location () : MovieClip {
		return mLocation;
	}
	
	/**
	
	*/
	public function set url(inUrl:String) : Void {
		mUrl = inUrl;
	}
	public function get url() : String {
		return mUrl;
	}
	
	/**
	
	*/
	public function set name(inName:String) : Void {
		mName = inName;
	}
	public function get name() : String {
		return mName;
	}
	
	/**
	
	*/
	public function set visible(inIsVisible:Boolean) : Void {
		mVisible = inIsVisible;
	}
	public function get visible() : Boolean {
		return mVisible;
	}
	
	/**
	
	*/
	public function set bytesTotal(inTotal:Number) : Void {
		mBytesTotal = inTotal;
	}
	public function get bytesTotal() : Number {
		return mBytesTotal;
	}
	
	/**
	
	*/
	public function set bytesLoaded(inLoaded:Number) : Void {
		mBytesLoaded = inLoaded;
	}
	public function get bytesLoaded() : Number {
		return mBytesLoaded;
	}
	
	/**
	
	*/
	public function toString () : String {
		return "FileData; location=" + mLocation + "; url=" + mUrl + "; name=" + mName + "; total bytes=" + mBytesTotal + "; loaded bytes=" + mBytesLoaded;
	}
}
