package com.bilibili.player.abstract.windows
{
	import com.bilibili.player.events.ApplicationEvent;
	/**
	 * Application的默认接口,方法只有3个:初始化,销毁,和应用程序消息
	 * @author:Lizeqiangd
	 * update:2014.03.28 增加注释,更改路径
	 */
	public interface iApplication
	{
		function init(e:ApplicationEvent):void;
		function applicationMessage(e:Object):void
		function dispose():void
	}
}