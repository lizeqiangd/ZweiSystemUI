package com.bilibili.player.core.filter {	
	import com.bilibili.player.core.filter.interfaces.IRemoteDataProvider;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	//import org.lala.filter.interfaces.IRemoteDataProvider;
	
	/**
	 * 列表加载并解析完毕,数据源可用
	 * 当使用者错过这个事件时,则手工检测源的状态,如果为LOADED则直接使用,否则源无效
	 **/
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * 远程数据源
	 * 可以是json/xml
	 * 加载完成后供具体的使用者使用
	 **/
	public class RemoteLoader extends EventDispatcher implements IRemoteDataProvider
	{
		protected var url:String = null;
		protected var _state:uint = RemoteLoaderState.UNLOAD;
		protected var _data:* = null;
		protected var loader:URLLoader;
		
		public function RemoteLoader(url:String=null)
		{
			this.url = url;
		}
		
		public function get state():uint
		{
			return _state;
		}
		
		public function set state(value:uint):void
		{
			_state = value;
		}
		
		public function load(url:String=null):void
		{
			if(state == RemoteLoaderState.UNLOAD)
			{
				state = RemoteLoaderState.LOADING;
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				var req:URLRequest;
				if(url)
					req = new URLRequest(url);
				else
					req = new URLRequest(this.url);
				loader.load(req);
			}
		}
		
		public function get data():*
		{
			return _data;
		}
		
		public function parseItems(data:*):*
		{
			//默认使用json解析
			try
			{
				return JSON.parse(data)
			}
			catch(e:Error)
			{
				return {};
			}
		}
		
		protected function completeHandler(event:Event):void
		{
			state = RemoteLoaderState.LOADED;
			_data = parseItems(loader.data);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function errorHandler(event:ErrorEvent):void
		{
			state = RemoteLoaderState.ERROR;
		}
	}
}