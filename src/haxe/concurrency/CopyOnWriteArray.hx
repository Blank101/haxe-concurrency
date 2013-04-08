/****
* Copyright (C) 2013 Sam MacPherson
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
****/

package haxe.concurrency;

#if neko
import neko.vm.Mutex;
#elseif cpp
import cpp.vm.Mutex;
#end

/**
 * A thread safe array. The array is copied completely during a write. Useful for read-heavy usage.
 * Be very careful when iterating by index as the array length can change during this.
 * It is a better idea to iterate by the default iterator and store an index variable alongside the iteration.
 * 
 * @author Sam MacPherson
 */

class CopyOnWriteArray<T> {
	
	public var length(_length, null):Int;
	
	var lock:Mutex;	//Write mutex
	var arr:Array<T>;

	public function new () {
		arr = new Array<T>();
	}
	
	function _length ():Int {
		return arr.length;
	}
	
	public function concat (a:CopyOnWriteArray<T>):CopyOnWriteArray<T> {
		return fromArray(arr.concat(a.arr));
	}
	
	public function copy ():CopyOnWriteArray<T> {
		return fromArray(arr);
	}
	
	public function get (pos:Int):Null<T> {
		return arr[pos];
	}
	
	public function set (pos:Int, x:T):T {
		lock.acquire();
		var a = arr.copy();
		a[pos] = x;
		arr = a;
		lock.release();
		return x;
	}
	
	public function insert (pos:Int, x:T):Void {
		var a = new Array();
		var index = 0;
		lock.acquire();
		for (i in arr) {
			if (index == pos) a.push(x);
			a.push(i);
			index++;
		}
		arr = a;
		lock.release();
	}
	
	public function iterator ():Iterator<T> {
		return arr.iterator();
	}
	
	public function join (sep:String):String {
		return arr.join(sep);
	}
	
	public function pop ():Null<T> {
		lock.acquire();
		var a = arr.copy();
		var e = a.pop();
		arr = a;
		lock.release();
		return e;
	}
	
	public function push (x:T):Int {
		lock.acquire();
		var a = arr.copy();
		var l = a.push(x);
		arr = a;
		lock.release();
		return l;
	}
	
	public function remove (x:T):Bool {
		lock.acquire();
		var a = arr.copy();
		var b = a.remove(x);
		arr = a;
		lock.release();
		return b;
	}
	
	public function reverse ():Void {
		lock.acquire();
		var a = arr.copy();
		a.reverse();
		arr = a;
		lock.release();
	}
	
	public function shift ():Null<T> {
		lock.acquire();
		var a = arr.copy();
		var e = a.shift();
		arr = a;
		lock.release();
		return e;
	}
	
	public function slice (pos:Int, ?end:Int):CopyOnWriteArray<T> {
		return fromArray(arr.slice(pos, end));
	}
	
	public function sort (f:T->T->Int):Void {
		lock.acquire();
		var a = arr.copy();
		a.sort(f);
		arr = a;
		lock.release();
	}
	
	public function splice (pos:Int, len:Int):CopyOnWriteArray<T> {
		return fromArray(arr.splice(pos, len));
	}
	
	public function toString ():String {
		return arr.toString();
	}
	
	public function unshift (x:T):Void {
		lock.acquire();
		var a = arr.copy();
		a.unshift(x);
		arr = a;
		lock.release();
	}
	
	inline static function fromArray<T> (a:Array<T>):CopyOnWriteArray<T> {
		var b = new CopyOnWriteArray<T>();
		b.arr = a;
		return b;
	}
	
}