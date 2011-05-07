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

import org.casaframework.event.EventDispatcher;
import org.casaframework.control.RunnableInterface;
import org.casaframework.load.base.LoadInterface;
import org.casaframework.util.ArrayUtil;

/**
	Chains/queues load requests together in the order added. To be used when loading multiple items of same or different type.
	
	@author Aaron Clinger
	@version 06/05/07
	@example
		<code>
			var mediaLoad:MediaLoad = new MediaLoad(this.loadZone_mc, "test.jpg");
			var soundLoad:SoundLoad = new SoundLoad(this.soundContainer_mc, "audio.mp3");
			
			var myLoadQueue:LoadManager = LoadManager.getInstance();
			this.myLoadQueue.addLoad(mediaLoad);
			this.myLoadQueue.addLoad(soundLoad);
			this.myLoadQueue.start();
		</code>
*/

class org.casaframework.load.LoadManager extends EventDispatcher implements RunnableInterface {
	public static var EVENT_LOAD_COMPLETE:String = 'onLoadComplete';
	public static var EVENT_LOAD_ERROR:String    = 'onLoadError';
	private static var $loadInstance:LoadManager;
	private var $isLoading:Boolean;
	private var $threads:Number;
	private var $queue:Array;
	
	
	/**
		@return {@link LoadManager} instance.
	*/
	public static function getInstance():LoadManager {
		if (LoadManager.$loadInstance == undefined)
			LoadManager.$loadInstance = new LoadManager();
		
		return LoadManager.$loadInstance;
	}
	
	
	private function LoadManager() {
		super();
		
		this.$isLoading = false;
		this.$threads   = 1;
		this.$queue     = new Array();
		
		this.$setClassDescription('org.casaframework.load.LoadManager');
	}
	
	/**
		Adds item to be loaded in order. Can also be used to change a file from/to a priority load.
		
		@param loadItem: Load to be added to the load queue. Can be any class that inherits from {@link LoadInterface} and dispatches events <code>"onLoadComplete"</code> and <code>"onLoadError"</code>.
		@param priority: <strong>[optional]</strong> Indicates to add item to beginning of the queue/next file to load <code>true</code>, or to add it at the end of the queue <code>false</code>; defaults to <code>false</code>.
	*/
	public function addLoad(loadItem:LoadInterface, priority:Boolean):Void {
		var loadObj:Object = loadItem;
		
		var i:Number = ArrayUtil.indexOf(this.$queue, loadObj);
		if (i != -1)
			if (!loadObj.isLoading())
				this.$removeLoad(loadObj, i);
		
		if (priority)
			this.$queue.unshift(loadObj);
		else
			this.$queue.push(loadObj);
		
		this.$checkQueue();
	}
	
	/**
		Removes item from the load queue. If file is currently loading the load is stopped.
		
		@param loadItem: Load to be removed from the load queue.
		@return Returns <code>true</code> if item was successfully found and removed; otherwise <code>false</code>.
		@usageNote Load items are automatically removed from LoadManager on load success or error.
	*/
	public function removeLoad(loadItem:LoadInterface):Boolean {
		var i:Number = ArrayUtil.indexOf(this.$queue, loadItem);
		if (i == -1)
			return false;
		
		if (loadItem.isLoading())
			loadItem.stop();
		
		this.$removeLoad(loadItem, i);
		
		return true;
	}
	
	/**
		Removes all items from the load queue and cancels any currently loading.
	*/
	public function removeAllLoads():Void {
		var l:Number = this.$queue.length;
		var loadItem:Object;
		while (l--) {
			loadItem = this.$queue.pop();
			
			if (loadItem.isLoading())
				loadItem.stop();
			
			loadItem.removeEventObserversForScope(this);
		}
	}
	
	/**
		Starts or resumes loading items from the queue.
	*/
	public function start():Void {
		if (this.$isLoading)
			return;
		
		this.$isLoading = true;
		this.$checkQueue();
	}
	
	/**
		Stops loading items from the queue after the currently loading items complete loading.
	*/
	public function stop():Void {
		this.$isLoading = false;
	}
	
	/**
		Determines whether LoadManager is in the process of loading items from the queue.
		
		@return Returns <code>true</code> if the LoadManager is currently actively loading; otherwise <code>false</code>.
	*/
	public function isLoading():Boolean {
		return this.$isLoading;
	}
	
	/**
		Defines the number of simultaneous file requests/downloads.
		
		@param theads: The number of threads the class will theoretically use, though most browsers cap the amount of threads and hold the other requests in a queue. Pass <code>0</code> for unlimited threads.
		@usageNote Class defaults to <code>1</code> thread. 
	*/
	public function setThreads(threads:Number):Void {
		this.$threads = Math.max(0, Math.round(threads));
		this.$checkQueue();
	}
	
	private function $checkQueue():Void {
		if (!this.$isLoading)
			return;
		
		var t:Number = (this.$threads == 0) ? this.$queue.length : this.$threads;
		var i:Number = 0;
		var l:Number = this.$queue.length;
		
		while (l--)
			if (this.$queue[l].isLoading())
				i++;
		
		if (i >= t)
			return;
		
		t -= i;
		l = -1;
		while (++l < this.$queue.length) {
			if (!this.$queue[l].isLoading()) {
				this.$queue[l].addEventObserver(this, 'onLoadComplete', '$loadCompleted');
				this.$queue[l].addEventObserver(this, 'onLoadError', '$loadError');
				this.$queue[l].start();
				
				if (--t == 0)
					return;
			}
		}
	}
	
	/**
		@sends onLoadCompleted = function(loadItem:LoadInterface) {}
	*/
	private function $loadCompleted(sender:LoadInterface):Void {
		this.$removeLoad(sender);
		this.dispatchEvent(LoadManager.EVENT_LOAD_COMPLETE, sender);
	}
	
	/**
		@sends onLoadError = function(loadItem:LoadInterface) {}
	*/
	private function $loadError(sender:LoadInterface):Void {
		this.$removeLoad(sender);
		this.dispatchEvent(LoadManager.EVENT_LOAD_ERROR, sender);
	}
	
	private function $removeLoad(loadItem:Object, position:Number):Void {
		loadItem.removeEventObserversForScope(this);
		
		if (position == undefined)
			ArrayUtil.removeArrayItem(this.$queue, loadItem);
		else
			this.$queue.splice(position, 1);
		
		this.$checkQueue();
	}
}