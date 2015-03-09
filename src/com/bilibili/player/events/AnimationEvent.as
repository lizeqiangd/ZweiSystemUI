package com.bilibili.player.events
{
	import flash.events.Event;
	/**
	 * Animation事件, 用于表示动画的流程.
	 * @author:Lizeqiangd
	 */
	public class AnimationEvent extends Event
	{
		//常规动画流程
		public static var START:String = "anime_start";
		public static var PLAYING:String = "anime_playing";
		public static var COMPLETE:String = "anime_complete";
		public static var Repeat:String = "anime_repeat";
		//特殊用途动画流程
		public static var OPENED:String = "anime_opened";
		public static var CLOSED:String = "anime_closed";
		public var data:*;
		
		public function AnimationEvent(type:String, DispatchData:* = null, bubbles:Boolean = false)
		{
			super(type, bubbles);
			data = DispatchData;
		}
	}
}