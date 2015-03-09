package com.bilibili.player.core.filter.interfaces {
	/**
	 * 设置在服务器上的,功能独立的过滤列表
	 **/
	public interface ICommentRemoteFilter extends ICommentFilter
	{
		/**
		 * 解析数据/解析完毕后必须发送complete事件
		 * @param data 数据源的数据
		 **/
		function parseItems(data:*):void;
	}
}