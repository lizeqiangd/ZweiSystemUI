package com.bilibili.player.core.filter.interfaces {
	/**
	 * 远程数据来源
	 * 因为同一个数据源加载完成后可以部分分别使用,为了重用数据源,可设一个公共的源
	 **/
	public interface IRemoteDataProvider
	{
		/**
		 * 该过滤列表的加载状态
		 * 分UNLOAD/LOADING/LOADED/ERROR(0/1/2/3)
		 **/
		function get state():uint;
		/**
		 * 开始加载
		 * @param url 该屏蔽列表的URL地址/特定的地址屏蔽列表的格式与解析方法是特定的
		 * 		参数null表示使用默认的地址加载
		 **/
		function load(url:String=null):void;
		/**
		 * 数据,可以是json/xml,由具体的源决定
		 **/
		function get data():*;
		/**
		 * 解析数据/初步的解析,将文本转化为json或者xml
		 * @param data 数据源的数据
		 **/
		function parseItems(data:*):*;
	}
}