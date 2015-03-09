package com.bilibili.player.core.filter.interfaces {
	public interface ICommentFilter
	{
		/**
		 * 检验该条弹幕是否允许显示
		 * @param item 弹幕数据|检测后可能会在弹幕数据上设置一些flag
		 * @return true/允许;false/不允许
		 **/
		function validate(item:Object):Boolean;
	}
}