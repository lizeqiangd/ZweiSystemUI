package com.bilibili.player.core.script.interfaces
{
	import flash.display.DisplayObjectContainer;

	public interface IExternalScriptLibrary
	{
		/** 
		 * 初始化外部库:主要用于绑定类名,显示元件,处理元件的回收等
		 * @param scope 运行环境的全局命名空间
		 * @param clip 显示列表根节点
		 * @param manager 脚本产生的元件的管理器
		 **/
		function initVM(scope:Object, clip:DisplayObjectContainer, manager:IScriptManager):uint;
	}
}