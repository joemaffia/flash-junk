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

import org.asapframework.util.types.Vector3D;

/**
 * Interface for objects in 3D space with a mapping in 2D space
 */

interface org.asapframework.util.types.I3DObject {
	public function set3DLocation (inLocation:Vector3D) : Void;
	public function get3DLocation () : Vector3D;
	public function set2DLocation (inX:Number, inY:Number, inScale:Number) : Void;
}