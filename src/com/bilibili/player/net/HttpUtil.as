package com.bilibili.player.net
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * 不返回任何必要数据的简单网络通信类
	 * @author Aristotle9
	 * @editor Lizeqiangd
	 * 20141203 转移到新地址
	 */
	public class HttpUtil
	{
		public static function Get(url:String, data:Object):void
		{
			var req:URLRequest = new URLRequest(url);
			req.method = URLRequestMethod.GET;
			var query:URLVariables = new URLVariables();
			for(var k:* in data) {
				if(data.hasOwnProperty(k)) {
					query[k] = data[k];
				}
			}
			req.data = query;
			createLoader().load(req);
		}
		
		public static function Post(url:String, data:Object):void
		{
			var req:URLRequest = new URLRequest(url);
			req.method = URLRequestMethod.POST;
			var form:URLVariables;
			if(data is String)
			{
				form = new URLVariables(data as String);
			}
			else
			{
				form = new URLVariables();
				for(var k:* in data) {
					if(data.hasOwnProperty(k)) {
						form[k] = data[k];
					}
				}
			}
			req.data = form;
			createLoader().load(req);
		}
		
		private static function createLoader():URLLoader
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, handler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, handler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);
			return loader;
		}
		
		private static function handler(event:Event):void
		{
			trace("HttpUtil:",event.type)
		}
	}
}