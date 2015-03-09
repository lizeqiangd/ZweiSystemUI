package com.bilibili.player.events
{
	import flash.events.Event;
	
	/**
	 * 播放器控制的反馈
	 * @author:Lizeqiangd
	 * update
	 * 20150106 增加隐藏弹幕 静音
	 */
	public class PlayerControlEvent extends Event
	{
		
		public static const PAUSE:String = "player_pause";
		public static const PLAY:String = "player_play";
		public static const SEEK:String = "player_seek";
		public static const VOLUME:String = "player_volume";
		public static const REPEAT:String = "player_repeat";
		public static const HIDE_COMMENT:String = 'player_hide_comment'
		public static const MUTE:String = 'player_mute'
		public var data:*;
		
		public function PlayerControlEvent(type:String, DispatchData:* = null, bubbles:Boolean = false)
		{
			super(type, bubbles);
			data = DispatchData;
		}
	}
}