package com.bilibili.player.events
{
	import flash.events.Event;
	
	public class CommentFilterEvent extends Event
	{
		
		/**
		 * 过滤列表变化
		 */
		//[Deprecated(replacement="EventBus.commentFilterChange")]
		//public static const FILTER_LIST_CHANGE:String = "filterListChange";
		/**
		 * UP主过滤列表变化
		 */
		public static const UPPER_FILTER_CHANGE:String = "upperFilterChange";
		/**
		 * 云屏蔽列表变化
		 */
		public static const CLOUDE_FILTER_CHANGE:String = "cloudFilterChange";
		
		public function CommentFilterEvent(type:String)
		{
			super(type, false, false);
		}
	}
}