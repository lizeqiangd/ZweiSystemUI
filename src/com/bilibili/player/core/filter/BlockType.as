package com.bilibili.player.core.filter {
	/** 弹幕被屏蔽的原因之类型 **/
	public final class BlockType
	{
		/** 自定义屏蔽:/通用 **/
		public static const CUSTOM_BLOCK:uint = 0;
		/** 自定义屏蔽:/用户屏蔽 **/
		public static const USER_BLOCK:uint = 1; 
		/** 自定义屏蔽:/关键字屏蔽 **/
		public static const KEYWORD_BLOCK:uint = 2; 
		/** 自定义屏蔽:/颜色屏蔽 **/
		public static const COLOR_BLOCK:uint = 3;
		/** 模式/池屏蔽 **/
		public static const MODE_POOL_BLOCK:uint = 4;
		/** 游客屏蔽 **/
		public static const GUEST_BLOCK:uint = 5;
		/** 云屏蔽 **/
		public static const CLOUD_BLOCK:uint = 6;
		/** UP主屏蔽 **/
		public static const UPPER_BLOCK:uint = 7;
		/** 黑名单屏蔽 **/
		public static const BLACKLIST_BLOCK:uint = 8;
		/** 弹幕溢出 **/
		public static const OVERFLOW_BLOCK:uint = 9;
	}
}