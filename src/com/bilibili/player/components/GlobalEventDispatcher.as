package com.bilibili.player.components {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 修改自JWPlayer.
	 * 20141031 脱离JWPlayer
	 * 实例化请去ValueManager操作
	 */
	public class GlobalEventDispatcher extends EventDispatcher {
		
		private var _globalListeners:Dictionary = new Dictionary();
		
		private var _dispatcher:IEventDispatcher;
		
		public function addGlobalListener(listener:Function):void {
			trace("GlobalEventDispatcher.addGlobalListener",listener)
			_globalListeners[listener] = true;
		}
		
		public function removeGlobalListener(listener:Function):void {
			delete _globalListeners[listener];
		}
		
		public override function dispatchEvent(event:Event) : Boolean {
			for (var l:* in _globalListeners) {
				if (l is Function) {
					var listener:Function = l as Function;
					listener(event);
				}
			}
			return super.dispatchEvent(event);
		} 
		
	}
}