package com.bilibili.player.net.comment
{
//	import com.bilibili.player.manager.AccessConsumerManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.namespaces.bilibili
	import com.bilibili.player.core.filter.CommentFilter;
	import flash.events.ProgressEvent;
	//import com.bilibili.player.core.utils.EventBus;
	import com.bilibili.player.events.CommentDataEvent;
	import com.bilibili.player.events.MukioEvent;
	import com.bilibili.player.system.config.BPSetting;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	//import mx.collections.ArrayCollection;
	
	//import org.lala.event.CommentDataEvent;
	//import org.lala.event.EventBus;
	//import org.lala.event.MukioEvent;
	//import org.lala.filter.CommentFilter;
	//import org.lala.utils.CommentDataParser;
	//import org.lala.utils.CommentFormat;
	//
	//import tv.bilibili.script.bilibili;
	
	/**
	 * 清空弹幕
	 */
	[Event(name="clear",type="org.lala.event.CommentDataEvent")]
	
	/**
	 * 弹幕数据列表变化:包括增删弹幕,某个弹幕属性变化
	 */
	[Event(name="commentDataChange",type="org.lala.event.CommentDataEvent")]
	/**
	 * 弹幕数据列表变化:新增加弹幕
	 */
	[Event(name="commentDataAppend",type="org.lala.event.CommentDataEvent")]
	/**
	 * 弹幕数据列表变化:弹幕被清空
	 */
	[Event(name="commentDataEmpty",type="org.lala.event.CommentDataEvent")]
	/**
	 * 弹幕数据列表变化:弹幕数据更新
	 */
	[Event(name="commentDataUpdate",type="org.lala.event.CommentDataEvent")]
	
	/**
	 * 弹幕的加载类,用于从外部加载弹幕文件到播放器
	 * 所有弹幕都会经过这里.也就是该类负责加载原始弹幕xml
	 * 然后最新获得的弹幕都会经过这里添加到弹幕库中
	 * 最后屏幕弹幕也会在这里进行一次校验.
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141107 开始理解中
	 * 20141128 这里负责解析弹幕,将a9姥爷最新的功能添加进入.增加推荐弹幕功能.删除arraycollection方法.
	 * 20141204 因为覆盖了a9大大的新功能.所以bug需要重新弄.
	 * 所有弹幕的来往都会经过这里.包括所有弹幕池也在本类的一个array里面.
	 * 会抛出好多好多的CommentDataEvent
	 * filter 也在本类激活
	 * 20150105 重拾代码
	 **/
	public class CommentProvider extends EventDispatcher
	{
		/** 用于网络连接的loader **/
		private var xmlLoader:URLLoader = null;
		/** 弹幕库 **/
		private var _repo:Array;
		/** 过滤器 **/
		private var filter:CommentFilter
		/** 弹幕id计数:程序内部id **/
		private var _length:uint = 0;
		/** 重新加延时器 **/
		private var reloadTimer:uint = 0;
		/** 重新载入计数 **/
		private var reloadCounts:uint = 0;
		private const MaxReload:uint = 10;
		/** live 模式 **/
		private var _liveMode:Boolean = false;
		/** 播放器是否正在播放?live时,暂停状态不接收弹幕 **/
		private var _videoIsPlaying:Boolean = false;
		/**
		 * 当前弹幕是否是推荐弹幕:标志
		 */
		private var _recommend_comment:Boolean = true;
		/**
		 * 访问权限配置
		 */
		//private var _accessConfig:AccessConfig;
		/**
		 * 直播弹幕列表的最大保存数量,当数量达到该数量时,删除最早的弹幕
		 */
		public static const MAX_LIVE_COMMENT_ON_LIST:uint = 5000;
		
		public function CommentProvider()
		{
			_repo = new Array();
			ValueObjectManager.getEventBus.addEventListener(MukioEvent.DISPLAY, displayeHandler);
			ValueObjectManager.getEventBus.addEventListener("newCommentReceived", newCommentHandler);
			ValueObjectManager.getEventBus.addEventListener("commentFilterChange", commentFilterChangeHandler);
			ValueObjectManager.getEventBus.addEventListener("switchRecommendComment", switchRecommendCommentHandler);
			//AccessConsumerManager.addAccessConfigChangeFunction
			filter = ValueObjectManager.getCommentFilter
			//.regist(this);
		}
		
		/**
		 * 设置为实时消息模式
		 **/
		public function set liveMode(value:Boolean):void
		{
			if (_liveMode != value)
			{
				_liveMode = value;
				if (_liveMode)
				{
					ValueObjectManager.getEventBus.removeEventListener("newCommentReceived", newCommentHandler);
					ValueObjectManager.getEventBus.addEventListener("newCommentReceived", newLiveCommentHandler);
				}
				else
				{
					ValueObjectManager.getEventBus.addEventListener("newCommentReceived", newCommentHandler);
					ValueObjectManager.getEventBus.removeEventListener("newCommentReceived", newLiveCommentHandler);
				}
			}
		}
		
		/** 切换消息模式是否是live **/
		public function get liveMode():Boolean
		{
			return _liveMode;
		}
		
		/** 接收内部发送的显示消息 **/
		private function displayeHandler(event:MukioEvent):void
		{
			dispatchCommentData(event.data.msg, event.data);
			
			//自己发的实时弹幕产生一个外部调用
			if (liveMode && ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call("onPlayerComment", event.data, true);
				}
				catch (e:Error)
				{
				}
			}
		}
		
		/**
		 * 收到其他用户的新的弹幕
		 **/
		private function newCommentHandler(event:MukioEvent):void
		{
			var xml:XML =        <root>{event.data}</root>;
			CommentDataParser.bili_parse(xml, dispatchCommentData);
			ValueObjectManager.getEventBus.sendMukioEvent('scrollCommentTable', true);
		}
		
		/**
		 * 收到直播时的弹幕
		 **/
		private function newLiveCommentHandler(event:MukioEvent):void
		{
			var xml:XML =        <root>{event.data}</root>;
			CommentDataParser.bili_parse(xml, dispatchLiveCommentData);
			ValueObjectManager.getEventBus.sendMukioEvent('scrollCommentTable', true);
		}
		
		/** 加载成功 **/
		private function completeHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			xmlLoader = null;
			clear();
			ValueObjectManager.getTimeLogCollector.setTimeLogEnd("loadComment")
			try
			{
				var xml:XML = XML(loader.data);
				parseXML(xml);
			}
			catch (error:Error)
			{
				msg("弹幕文件格式有误,无法正确解析.");
			}
		
		}
		
		/** 错误处理 **/
		private function errorHandler(event:Event):void
		{
			trace('xml loader error;');
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			xmlLoader = null;
			
			if (reloadCounts == 0)
				msg(event.toString() + '5秒钟后尝试再次加载(x10).');
			/** 如果没有弹幕文件则重新加载 **/
			if (reloadTimer != 0)
			{
				clearTimeout(reloadTimer);
				reloadTimer = 0;
			}
			reloadCounts++;
			if (reloadCounts <= MaxReload)
				reloadTimer = setTimeout(reloadHandler, 5000);
		}
		
		/** 错误消除 **/
		private function errorSkipHandler(event:ErrorEvent):void
		{
			trace('xml error skip;');
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorSkipHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorSkipHandler);
//			trace('hehe');
			//强制断开流,不作处理
		}
		
		protected function reloadHandler():void
		{
			clearTimeout(reloadTimer);
			reloadTimer = 0;
			ValueObjectManager.getEventBus.sendMukioEvent('reloadCommentFile', {timestamp: 0});
		}
		
		/** 错误输出 **/
		private function msg(massage:String):void
		{
			ValueObjectManager.getEventBus.log(massage);
		}
		
		/** 加载指定地址和格式的弹幕
		 * @param url 弹幕文件地址,通常是一个xml文件
		 * @param type 弹幕文件格式
		 **/
		public function load(url:String, type:String = "", server:CommentServer = null):void
		{
			ValueObjectManager.debug ? url = "http://comment.bilibili.com/201284.xml" : null
			trace('CommentProvider.load:' + url);
			
			if (type == "")
			{
				type = BPSetting.CommentFormat_OLDACFUN
			}
			if (type == BPSetting.CommentFormat_AMFCMT)
			{
				server.getCmts(dispatchCommentData);
			}
			else
			{
				var request:URLRequest = new URLRequest(url);
				/** 关闭没有返回的流 **/
				if (xmlLoader != null)
				{
					xmlLoader.removeEventListener(Event.COMPLETE, completeHandler);
					xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					xmlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
					
					xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorSkipHandler);
					xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorSkipHandler);
					try
					{
						xmlLoader.close();
					}
					catch (e:Error)
					{
						trace('CommentProvider.load:xmlloader close failed');
					}
				}
				/** 已经进入重载进程的loader **/
				if (reloadTimer != 0)
				{
					trace('clear time out;');
					clearTimeout(reloadTimer);
					reloadTimer = 0;
				}
				
				xmlLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, completeHandler);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				xmlLoader.addEventListener(ProgressEvent.PROGRESS,onCommentLoadProgress)
				xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				
				ValueObjectManager.getTimeLogCollector.createTimeLog("loadComment", "读取弹幕文件")
				//EventTimer.getInstance().begin(EventTimerEvent.LOAD_COMMENT_FILE);
				xmlLoader.load(request);
			}
		}
		
		private function onCommentLoadProgress(e:ProgressEvent):void 
		{
			trace("comment load progress:",e.bytesLoaded,e.bytesLoaded/e.bytesTotal)
		}
		
		/**
		 * 清除弹幕
		 **/
		private function clear():void
		{
			this._repo.splice(0, _repo.length);
			this.dispatchEvent(new CommentDataEvent(CommentDataEvent.CLEAR));
			this.dispatchEvent(new CommentDataEvent(CommentDataEvent.COMMENT_DATA_EMPTY, null));
			this.dispatchEvent(new CommentDataEvent(CommentDataEvent.COMMENT_DATA_CHANGE, _repo));
		}
		
		/**
		 * 解析xml
		 * 把xml解析成一条条弹幕数据,并分发出去
		 * 弹幕数据说明 ...
		 **/
		private function parseXML(xml:XML):void
		{
			//trace(xml)
			if (xml.data.length())
			{
				CommentDataParser.acfun_parse(xml, dispatchCommentData);
			}
			else if (xml.l.length())
			{
				CommentDataParser.acfun_new_parse(xml, dispatchCommentData);
			}
			else if (xml.d.length())
			{
				CommentDataParser.bili_parse(xml, dispatchCommentData, ValueObjectManager.getAccessConfig.suggest_comment, ValueObjectManager.getAccessConfig.maxlimit, _recommend_comment);
			}
			else
			{
				msg("弹幕格式未识别.");
			}
		}
		
		/**
		 * 分发函数,处理单个弹幕数据
		 **/
		private function dispatchCommentData(msg:String, data:Object):void
		{
			//msg 为弹幕的mode  为"1"....
			//trace("CommentProvider.dispatchCommentData",msg,data.text)
			//if(msg=="8"){
				//trace("CommentProvider.dispatchCommentData,代码弹幕测试",data.text)
			//}
			//带有preview属性的不插入弹幕库
			var changed:Boolean = true;
			if (data.preview)
			{
				this.dispatchEvent(new CommentDataEvent(msg, data));
				return;
			}
			else
			{
				data.id = newId();
				/** 经过过滤器验证 **/
				data.blocked = !filter.validate(data);
				this.dispatchEvent(new CommentDataEvent(msg, data));
				this._repo.push(data);
				//if (changed == false)
				changed = true;
			}
			if (changed)
			{
				this.dispatchEvent(new CommentDataEvent(CommentDataEvent.COMMENT_DATA_APPEND, data));
				this.dispatchEvent(new CommentDataEvent(CommentDataEvent.COMMENT_DATA_CHANGE, _repo));
			}
		}
		
		/**
		 * 分发直接时的弹幕
		 **/
		private function dispatchLiveCommentData(msg:String, data:Object):void
		{
			if (videoIsPlaying)
			{
				data.bilibili::stime = getTimer() / 1000.0;
				data.live = true;
				data.preview = true;
				data.id = newId();
				this.dispatchEvent(new CommentDataEvent(msg, data));
				//通知外部接口,
				if (ExternalInterface.available)
				{
					try
					{
						ExternalInterface.call("onPlayerComment", data);
					}
					catch (e:Error)
					{
					}
				}
				/** 经过过滤器验证 **/
//				data.blocked = !filter.validate(data);
//				this._repo.addItem(data);
				/** 超出的弹幕时删除最早的弹幕 **/
				while (this._repo.length >= MAX_LIVE_COMMENT_ON_LIST)
				{
					this._repo.shift();
				}
				this._repo.push(data);
				this.dispatchEvent(new CommentDataEvent(CommentDataEvent.COMMENT_DATA_APPEND, data));
				this.dispatchEvent(new CommentDataEvent(CommentDataEvent.COMMENT_DATA_CHANGE, _repo));
				
			}
		}
		
		/**
		 * 过滤器变更,重新验证每个弹幕
		 **/
		private function commentFilterChangeHandler(event:MukioEvent):void
		{
			for each (var item:Object in _repo)
			{
				item.blocked = !filter.validate(item);
			}
			this.dispatchEvent(new CommentDataEvent(CommentDataEvent.COMMENT_DATA_UPDATE, null));
			this.dispatchEvent(new CommentDataEvent(CommentDataEvent.COMMENT_DATA_CHANGE, _repo));
		}
		
		/**
		 * 切换是否是推荐弹幕
		 */
		private function switchRecommendCommentHandler(event:MukioEvent):void
		{
			var data:Object = event.data;
			_recommend_comment = data.recommend;
			
			ValueObjectManager.getEventBus.sendMukioEvent('reloadCommentFile', {timestamp: 0});
		}
		
		/**
		 * 返回弹幕列表数组:不要在CommentProvider之外修改本数组中的任意元素任意属性!
		 */
		public function get commentResource():Array
		{
			return _repo;
		}
		
		/**
		 * 获取一个新的内部id
		 **/
		protected function newId():uint
		{
			return _length++;
		}
		
		/** 播放器是否正在播放?live时,暂停状态不接收弹幕 **/
		public function get videoIsPlaying():Boolean
		{
			return _videoIsPlaying;
		}
		
		/**
		 * @private
		 */
		public function set videoIsPlaying(value:Boolean):void
		{
			_videoIsPlaying = value;
		}
	
	}
}