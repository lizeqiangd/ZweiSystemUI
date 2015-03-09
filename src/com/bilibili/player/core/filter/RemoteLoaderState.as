package com.bilibili.player.core.filter {
	public class RemoteLoaderState
	{
		/** 没有开始加载 **/
		public static const UNLOAD:uint = 0;
		/** 加载中 **/
		public static const LOADING:uint = 1;
		/** 加载成功 **/
		public static const LOADED:uint = 2;
		/** 加载失败 **/
		public static const ERROR:uint = 3;
	}
}