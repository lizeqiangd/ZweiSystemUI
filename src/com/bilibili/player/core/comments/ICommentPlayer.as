package com.bilibili.player.core.comments
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import com.bilibili.player.net.comment.CommentProvider

	/**
	 * 从视频播放分离出来的弹幕播放引擎
	 */
	public interface ICommentPlayer
	{
		/**
		 * 获取弹幕层
		 */
		function get clip():Sprite;
		/**
		 * 获取弹幕屏幕的遮罩层
		 */
		function get maskClip():DisplayObject;
		/**
		 * 获取provider
		 */
		function get provider():CommentProvider;
		/**
		 * 加载弹幕文件
		 * @param url 弹幕文件URL
		 */
		function load(url:String):void;
		/**
		 * 设置是否为live(直播模式)
		 */
		function get liveMode():Boolean;
		function set liveMode(value:Boolean):void;
		/**
		 * 设置是否需要使用弹幕遮罩层
		 */
		function get useMask():Boolean;
		function set useMask(value:Boolean):void;
		/**
		 * 是否正在播放
		 */
		function get paused():Boolean;
		/**
		 * 当前时间轴时间/s, liveMode下没有意义
		 */
		function get time():Number;
		/**
		 * 设置弹幕时间轴/在paused==false的情况下,通过不停地给更新time,推进弹幕时间轴
		 * /s
		 */
		function set time(value:Number):void;
		/**
		 * 显示/隐藏弹幕
		 */
		function get commentVisible():Boolean;
		function set commentVisible(value:Boolean):void;
		/**
		 * 是否允许弹幕覆盖视频?
		 */
		function get isCommentsCovered():Boolean;
		function set isCommentsCovered(value:Boolean):void;
		/**
		 * 重新检测在屏弹幕的是否已经屏蔽,并且设置已经屏蔽的弹幕为隐藏
		 */
		function refreshBlockedComments():void;
		/**
		 * 进入弹幕播放状态
		 */
		function play():void;
		/**
		 * 进入暂停状态
		 */
		function pause():void;
		/**
		 * 清除当前屏幕上的弹幕
		 */
		function clear():void;
		/**
		 * 设置弹幕区域大小
		 * @param width 宽度
		 * @param height 高度
		 * @param videoHeight 视频高度(假设该视频垂直居中),为0时使用 height,计算防止挡字幕的高度
		 * 当参数为0时,使用上次的大小
		 */
		function resize(width:Number=0, height:Number=0, videoHeight:Number=0):void;
	}
}