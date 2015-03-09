package com.bilibili.player.core.script.interfaces
{
	/**
	 * 脚本工厂
	 * 命名含义:每条脚本弹幕的执行,都会使用一个新的脚本虚拟机(初始化并且添加初始的globals)
	 * 如果虚拟机中的函数没有被外部引用,则该虚拟机应被回收.
	 * 如果虚拟机中的函数被外部引用,则虚拟机将因该引用而继续存在
	 * 脚本工厂,即虚拟机工厂
	 * 因无法不破坏代码结构的情况下用同一个虚拟机执行两条以上的脚本而采取的措施.
	 **/
	public interface ICommentScriptFactory
	{
		/**
		 * @param script 需要执行的脚本
		 * @param debugInfo 是否使用调用信息
		 **/
		function exec(script:String, debugInfo:Boolean=false):void;
	}
}