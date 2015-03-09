package com.bilibili.player.components.browser
{
	import flash.external.ExternalInterface;
/**
 * 通过把所有与js通信的代码放在本类
 * 大量使用原A9大大的代码...基本上就是全部..
 * @author:Lizeqiangd
 * 20141204 增加webstorage
 */
	public class JavaScriptInterfaces
	{
		/**
		 * 通过js接口使用Html5 localStorage加载配置, 获取键为key的存储值(已经反序列化)
		 * @param key 存储键
		 * @param default_val 当调用失败或者没有相关值时返回该值
		 */
		public static function loadByWebStorage(key:String, default_val:Object=null):Object
		{
			try
			{
				if(ExternalInterface.available)
				{
					var str:String = ExternalInterface.call("function(key){return localStorage[key];}", key) as String;
					return JSON.parse(decodeURIComponent(str));
				}
				else {
					return default_val;
				}
			}
			catch(e:Error)
			{
				return default_val;
			}
			return default_val;
		}
		/**
		 * 通过js接口使用html5 localStorage存储配置, 将值为value存储到key键下
		 * @param key 存储键
		 * @param value 存储的值
		 */
		public static function saveByWebStorage(key:String, value:Object):void
		{
			try
			{
				if(ExternalInterface.available)
				{
					ExternalInterface.call("function(key, val_str){localStorage[key]=val_str;}",
						key,
						encodeURIComponent(JSON.stringify(value)) );
				}
			}
			catch(e:Error)
			{
			}
		}
	}
}