package com.bilibili.player.net.api
{
	
	import com.bilibili.player.core.utils.AppRouter;
	import com.bilibili.player.events.MukioEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	//import org.lala.event.MukioEvent;
	
	//[Event(name="complete", type="org.lala.event.MukioEvent")]
	/**
	 * Bilibili视频信息加载器
	 * http://api.bilibili.com/view?type=xml&id=257797&page=1
	 * http://api.bilibili.com/view?type=<类型>&appkey=<appkey>&id=<ID号>&page=<页数>
	 * @author Aristotle9
	 * @editor Lizeqiangd
	 * 20141209 修改路径
	 **/
	public class VideoInfoLoader extends EventDispatcher
	{
		protected var _aid:String;
		protected var _page:String;
		
		/**
		 * 信息加载
		 * @param aid 文章id
		 * @param page 章节,1-n
		 **/
		public function VideoInfoLoader(aid:String, page:String)
		{
			_aid = aid;
			_page = page;
			super(null);
		}
		
		public function load(url:String = null):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, completeHandler);
			if (url === null)
			{
				url = 'http://api.bilibili.com/view?type=json&appkey=8e9fc618fbd41e28&id=' + _aid + '&page=' + _page;
			}
			loader.load(new URLRequest(url));
		}
		
		protected function completeHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			
			var data:Object;
			try
			{
				data = JSON.parse(loader.data);
			}
			catch (e:*)
			{
				data = new XML('<root>' + loader.data + '</root>');
			}
			dispatchEvent(new MukioEvent('complete', parse(data)));
		}
		
		/**
		 * 解析视频信息:
		 * 一部分是原数据,一部分是appRouter
		 **/
		protected static function parse(data:Object):Object
		{
			var obj:Object = {};
			if (data.from != null)
			{
				switch (data.from)
				{
					case 'sina': 
						obj.vid = data.vid;
						break;
					case 'youku': 
						obj.ykid = data.vid;
						break;
				}
			}
			else
			{
				if (data.cid)
				{
					obj.cid = data.cid;
				}
			}
			var ar:AppRouter = new AppRouter
			ar.init(obj)
			return {data: data, appRouter: ar};
		}
	}
}