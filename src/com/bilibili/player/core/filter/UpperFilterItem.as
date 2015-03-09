package com.bilibili.player.core.filter {
	/**
	 * UP主的屏蔽列表项
	 **/
	public final class UpperFilterItem
	{
		/** 类型:文本/正则/用户 **/
		public var type:uint;
		/** 屏蔽表达式 **/
		public var exp:String;
		
		public function UpperFilterItem()
		{
		}
	}
}