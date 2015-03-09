package com.bilibili.player.core.script.interfaces
{
	/**
	 * 全局变量存储器
	 * get,set加前缀_,防止与as3 getter,setter语法产生冲突
	 **/
	public interface IGlobal
	{
		/**
		 * 存储变量
		 * @param key 键
		 * @param val 值
		 **/
		function _set(key:String, val:*):void;
		/**
		 * 获取变量
		 * @param key 键
		 **/
		function _get(key:String):*;
		/**
		 * @copy #_get
		 **/
		function _(key:String):*;
	}
}