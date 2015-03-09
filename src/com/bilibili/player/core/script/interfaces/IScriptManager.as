package com.bilibili.player.core.script.interfaces
{
	import flash.utils.Timer;

	/** 定时器管理 **/
	public interface IScriptManager
	{
		/**
		 * 将计时器存到管理列表
		 **/
		function pushTimer(t:Timer):void;
		/**
		 * 将计时器弹出管理列表
		 **/
		function popTimer(t:Timer):void;
		/**
		 * 终止所有在运行的定时器
		 **/
		function clearTimer():void;
		/**
		 * 将存入元件到管理列表
		 **/
		function pushEl(m:IMotionElement):void;
		/**
		 * 将元件弹出管理列表
		 **/
		function popEl(m:IMotionElement):void;
		/**
		 * 清理管理列表中的所有元件
		 **/
		function clearEl():void;
		/**
		 **/
		function clearTrigger():void;
	}
}