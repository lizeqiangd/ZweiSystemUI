package com.bilibili.player.core.comments
{	
	/**
	 * 弹幕类接口:实现必须是flash.display.DisplayObject子孙
	 * @author aristotle9
	 */
	public interface IComment
	{
		function start():void;
		function pause():void;
		function resume():void;
		function set complete(foo:Function):void;
		/** 原始数据 **/
		function get data():CommentData;
		/** 提前结束 **/
		function stop():void;
		/** 填装数据 **/
		function initialize(data:CommentData):void;
	}
}