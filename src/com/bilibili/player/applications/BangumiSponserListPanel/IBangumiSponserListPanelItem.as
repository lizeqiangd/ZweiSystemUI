package com.bilibili.player.applications.BangumiSponserListPanel
{
	import flash.display.DisplayObject;

	public interface IBangumiSponserListPanelItem
	{
		/**
		 * @param info 显示用数据
		 * 数据格式: http://www.bilibili.com/widget/ajaxGetBP?aid={aid} 返回的list数组中的项
		 * 查看 tv.bilibili.components.BangumiSponserListPanelItem.setConfig 了解其中一些数据
		 * @see tv.bilibili.components.BangumiSponserListPanelItem
		 */
		function setConfig(info:Object):void;
		/**
		 * 显示对象,用于加到显示列表中以显示数据
		 */
		function get view():DisplayObject;
	}
}