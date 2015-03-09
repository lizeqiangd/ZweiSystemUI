package com.bilibili.player.system.config {
	
	/**
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 */
	
	public class BPNotification
	{
		///播放器开始启动.
		public static const PlayerStartingUp:String = "player_starting_up"
		
		///显示弹幕样式面板
		//public static const CommentStylePanelShow:String = "comment_style_panel_show"
		
		///隐藏弹幕样式面板
		//public static const CommentStylePanelHide:String = "comment_style_panel_hide"
		
		///当弹幕样式发生变化的时候.
		//public static const CommentStyleChanged:String = "comment_style_changed"
		
		///弹幕选择发送出去
		public static const CommentPublish:String = "comment_publish"
		
		
		public static const CommentPublishComplete:String = "comment_publish_complete"
		
		
		public static const CommentPublishFailed:String = "comment_publish_failed"
		
		
		public static const CommentSenderBarDisable:String = "comment_sender_bar_disable"
		
		public static const CommentSenderBarEnable:String = "comment_sender_bar_enable"
		
		///当弹幕配置更改的时候调用
		public static const CommentSenderStyleConfigChanged:String ="comment_sneder_style_config_changed"
	}

}