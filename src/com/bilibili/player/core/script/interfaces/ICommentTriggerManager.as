package com.bilibili.player.core.script.interfaces
{
	/**
	 * 管理用于自定义刚刚发送的弹幕的呈现方式,是否使用脚本弹幕定义呈现方式
	 **/ 
	public interface ICommentTriggerManager
	{
		/**
		 * 添加commentTrigger
		 **/
		function addTrigger(f:Function):void;
		/**
		 * 移除commentTrigger
		 **/
		function removeTrigger(f:Function):void;
		/**
		 * @param item 弹幕数据
		 * 返回true,替代刚刚发送的弹幕显示.但是以后的弹幕仍用原方法显示
		 * 返回false,表示起作用
		 **/
		function trigger(item:Object):Boolean;
	}
}