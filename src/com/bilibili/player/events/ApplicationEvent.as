package com.bilibili.player.events
{
	import flash.events.Event;
	/**
	 * 本事件类为Application开启关闭等操作的事件.
	 * @author:Lizeqiangd
	 * update:
	 * 2014.03.28:更新备注.
	 * 20141111 为bilibili player更新
	 */
	public class ApplicationEvent extends Event
	{
		/*
		 * 程序被其他管理器初始化前
		 */
		public static var OPEN:String = "app_open";
		/*
		 * 程序被其他管理器初始化后
		 */
		public static var OPENED:String = "app_opened";
		/*
		 * 程序被其他按钮点击关闭后
		 */
		public static var CLOSE:String = "app_close";
		/*
		 * 程序被动画管理器结束后响应
		 */
		public static var CLOSED:String = "app_closed";
		/*
		 * 程序开启动画结束后
		 */
		public static var INIT:String = "app_init";
		/*
		 * 程序本身初始化成功后
		 */
		public static var INITED:String = "app_inited";
		public var data:*;
		
		public function ApplicationEvent(type:String, DispatchData:* = null, bubbles:Boolean = false)
		{
			super(type, bubbles);
			data = DispatchData;
		}
	}
}