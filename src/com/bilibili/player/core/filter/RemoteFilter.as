package com.bilibili.player.core.filter {
	import com.bilibili.player.core.filter.interfaces.ICommentRemoteFilter;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	//import org.lala.filter.interfaces.ICommentRemoteFilter;
	
	/**
	 * 解析完毕,数据已经转换完成
	 **/
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 服务器端屏蔽列表基类
	 **/
	public class RemoteFilter extends EventDispatcher implements ICommentRemoteFilter
	{
		/**
		 * 数据来源
		 **/
		protected var provider:RemoteLoader;
		
		/**
		 * 初始化
		 * @param provider 数据来源,如果为空将根据url产生一个自己使用的数据源
		 * @param url 数据源的url,在数据源为空时使用
		 **/
		public function RemoteFilter(provider:RemoteLoader = null, url:String=null)
		{
			if(provider == null)
			{
				this.provider = new RemoteLoader(url);
			}
			else
			{
				this.provider = provider;
			}
			
			if(this.provider.state == RemoteLoaderState.LOADED)
			{
				this.parseItems(this.provider.data);
			}
			else if(this.provider.state != RemoteLoaderState.ERROR)
			{
				this.provider.addEventListener(Event.COMPLETE, completeHandler);
			}
		}
		
		public function get state():uint
		{
			return provider.state;
		}
		
		public function load(url:String=null):void
		{
			this.provider.load(url);
		}
		
		public function validate(item:Object):Boolean
		{
			return true;
		}
		
		public function parseItems(data:*):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function completeHandler(event:Event):void
		{
			parseItems(provider.data);
		}
	}
}