package com.bilibili.player.core.script.interfaces
{
	/** 具有移动策略的图形元件 **/
	public interface IMotionElement
	{
		/** 获取元件的移动管理器 **/
		function get motionManager():IMotionManager;
	}
}