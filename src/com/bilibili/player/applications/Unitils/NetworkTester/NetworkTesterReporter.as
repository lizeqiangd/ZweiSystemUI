package com.bilibili.player.applications.Unitils.NetworkTester
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * @author Lizeqiangd
	 * 20141120 用于记录用户流断开时间和重连时间以及用户的ip.用于记录直播视频播放的质量等相关.
	 */
	public class NetworkTesterReporter extends EventDispatcher
	{
		private var ul_ip:URLLoader = new URLLoader
		private var ul_userinfo:URLLoader = new URLLoader
		
		private var userIp:String = "127.0.0.1"
		private var disconnectionData:Array = []
		private var reconnectionData:Array = []
		
			private var _url:String=""
				
		public function NetworkTesterReporter()
		{
			ul_ip = new URLLoader
			ul_ip.load(new URLRequest("http://183.131.11.39/api/net/ReturnUserIP.php"))
			ul_ip.addEventListener(Event.COMPLETE, onIPLoadComplete)
		}
		
		public function setStreamUrl(url:String):void
		{if(_url!=""){
			return
		}
			_url=url	
			dispatchEvent(new UIEvent(UIEvent.REPORT,{type:"url",info:_url}))
		}
		
		public function pushDisconnectionEvent(time:String):void
		{	dispatchEvent(new UIEvent(UIEvent.REPORT,{type:"disconnection",info:time}))
//			trace('pushDisconnectionEvent: ' + time);
		}
		
		public function pushReconnectionEvent(time:String):void
		{
//			trace('pushReconnectionEvent: ' +time);
			dispatchEvent(new UIEvent(UIEvent.REPORT,{type:"reconnection",info:time}))
		}
			
		
		private function onIPLoadComplete(e:Event):void
		{
			userIp = ul_ip.data
			dispatchEvent(new UIEvent(UIEvent.REPORT,{type:"ip",info:userIp}))

		}
		
		public function getUserIp():String
		{
			return userIp
		}
	}
}