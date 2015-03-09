package com.bilibili.player.abstract.module
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class BaseModule
	{
		private var _modulename:String = "DefaultModuleName"
		private var _eventDispatch:EventDispatcher
		
		public function BaseModule()
		{
			_eventDispatch = new EventDispatcher
		}
		
		/**
		 * 添加侦听器
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_eventDispatch.addEventListener(type, listener, useCapture, priority, useWeakReference)
		}
		
		/**
		 * 移除侦听器
		 */
		public function removeEventListener(type:String, listener:Function, userCapture:Boolean):void
		{
			_eventDispatch.removeEventListener(type, listener, userCapture)
		}
		
		/**
		 * 调度事件
		 * @param	event
		 * @return
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			return _eventDispatch.dispatchEvent(event)
		}
		
		public function set setModuleName(value:String):void					
		{
			_modulename = value
		}
		
		public function get getModuleName():String
		{
			return _modulename
		}
	
	}

}