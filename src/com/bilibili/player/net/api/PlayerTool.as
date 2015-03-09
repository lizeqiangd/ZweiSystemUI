package com.bilibili.player.net.api
{
	import com.bilibili.interfaces.CModule;
	import com.bilibili.interfaces.getSign;
	import com.bilibili.player.applications.BangumiSponserListPanel.BangumiSponserListPanel;
	import com.bilibili.player.components.addon.LetvStatisticsService;
	import com.bilibili.player.core.utils.AppRouter;
	import com.bilibili.player.events.MukioEvent;
	import com.bilibili.player.manager.AccessConsumerManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.net.comment.CommentServer;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.valueobjects.media.PlaylistItem;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	/**
	 * 播放器常用方法集
	 * 播放sina视频可以直接调用Player的load方法,因为有SinaMediaProvider
	 * 但是播放youku视频要借用SinaMediaProvider,
	 * 此外还要对视频信息作解析,这些任务顺序可能较为复杂,因此放在该类中,保证主文件的清洁
	 * @author aristotle9
	 * @editor lizeqiangd
	 * 20141208 太迟了..我的魔抓已经伸向这个东西了..为了只有一个目的..那就是把他归类到ValueObjectManager
	 **/
	public class PlayerTool extends EventDispatcher /*implements IAccessConfigConsumer*/
	{
		private var sinaFallback:String = null;
		/** 是否是外链播放器 **/
		public var isMiniPlay:Boolean = false;
		/**
		 * playurl 开始加载时间/ms
		 */
		private var playurlStartTime:int = 0;
		/**
		 * 是否是复用
		 */
		private var isReload:Boolean = false;
		/**
		 * 直播视频画质
		 */
		private var liveQuality:String = null;
		
		public function PlayerTool( /*p:Player, conf:CommentConfig*/)
		{
			com.bilibili.interfaces.CModule.startAsync(this);
			
			ValueObjectManager.getEventBus.addEventListener("letv-rollback", letvRollBackHandler);
			AccessConsumerManager.addAccessConfigChangeFunction(onAccessConfigUpdate)
		}
		
		private function onAccessConfigUpdate( /*accessConfig:AccessConfig*/):void
		{
			/**
			 * 清晰度固定的列表生成
			 * 0  1 2 3  4
			 * 默 低 高 超  原
			 */			
			if (ValueObjectManager.getAccessConfig.vtype == 'qq')
			{
				var definitionConfig:Object = {current: ValueObjectManager.getPlayerConfig.highQualityEnabled ? '4' : '1', list: [{id: '1', name: '流畅', type: 'qq'}, {id: '4', name: '高清', type: 'qq'}]};
				ValueObjectManager.getEventBus.sendMukioEvent('setLetvDefinitionConfig', definitionConfig);
				ValueObjectManager.getEventBus.addEventListener('setLetvDefinition', setQQDefinitionHandler);
			}
		}
		
		/**
		 * QQ清晰度选择
		 */
		private function setQQDefinitionHandler(event:MukioEvent):void
		{
			var info:Object = event.data;
			if (info.type == 'qq')
			{
				var newConfig:Boolean = info.id == '4' ? true : false;
				if (newConfig != ValueObjectManager.getPlayerConfig.highQualityEnabled)
				{
					ValueObjectManager.getPlayerConfig.highQualityEnabled = newConfig;
					ValueObjectManager.getEventBus.sendMukioEvent("reloadVideo", true);
				}
			}
		}
		
		/**
		 * 播放单个文件,借用SinaMediaProvider,因为控制逻辑与原有的MediaProvider有不同
		 * @param url 视频文件的地址
		 **/
		public function loadSingleFile(url:String):void
		{
			/** 文件没有视频信息:所以直接加载成功 **/
			dispatchEvent(new Event('videoInfoComplete'));
			//var pli:PlaylistItem=new PlaylistItem
			
			ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'sina', file: 'videoInfo', videoInfo: {length: 0, items: [{'url': url, length: 0}]}}));
		}
		
		/**
		 * 播放https重新定向的url
		 * @param vid 定向参数
		 **/
		public function loadRedirectVideo(vid:String):void
		{
			loadSingleFile('https://secure.bilibili.com/offsite,' + vid);
		}
		
		/**
		 * 播放主站的视频:可以快速跳跃
		 * @param avid av参数
		 **/
		public function loadAVVideo(avid:String):void
		{
			/** 文件没有视频信息:所以直接加载成功 **/
			dispatchEvent(new Event('videoInfoComplete'));
			var url:String = "http://pl.bilibili.com/" + avid.replace("levelup", "/") + ".flv";
			ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'sina', file: 'videoInfo', videoInfo: {length: 0, items: [{'url': url, length: 0}], 'fastSeek': true, 'fastSeekParameterName': 'start', 'fastSeekByTime': false}}));
		}
		
		/**
		 * 播放sina视频//本地缓存的视频也使用新浪格式,也使用该方法播放(有两次缓存判断,重复)
		 * @param vid sina视频的vid
		 **/
		public function loadSinaVideo(vid:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, sinaInfoCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			
			var url:String = getSinaVideoInfoURL(vid);
			loader.load(new URLRequest(url));
		}
		
		/**
		 * 播放letv视频
		 **/
		public function loadLetvVideo(vid:String):void
		{
//			LetvStatisticsService.vid = vid;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(Event.COMPLETE, letvCompleteHandler);
			
			var url:String = getLetvVideoInfoUrl(vid);
			var req:URLRequest = new URLRequest(url);
			loader.load(req);
		}
		
		/**
		 * 播放cid视频;
		 * http://interface.bilibili.com/playurl?cid=<cid>,格式为sina格式
		 * 可以有高速缓存
		 * @param vid 视频cid
		 * @param reload 是否是连续播放
		 **/
		public function loadCidVideo(vid:String, reload:Boolean = false):void
		{
			isReload = reload;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(Event.COMPLETE, cidCompleteHandler);
			
			var url:String = getCidVideoInfoUrl(vid);
			var arr:Array = url.split('?');
			var query:String = com.bilibili.interfaces.getSign(arr[1] + '&player=1');
			var req:URLRequest = new URLRequest(arr[0] + '?' + query);
			//EventTimer.getInstance().begin(EventTimerEvent.LOAD_VIDEO_INFO);
			
			ValueObjectManager.getTimeLogCollector.createTimeLog("onLoadVideo", "解析视频地址")
			loader.load(req);
			playurlStartTime = getTimer();
		}
		
		/**
		 * 播放qq视频
		 * @param vid qq视频的vid
		 **/
		public function loadQqVideo(vid:String):void
		{
			if (ValueObjectManager.getAccessConfig.cached && (ValueObjectManager.getPlayerConfig.videoAcceleration === true || (ValueObjectManager.getAccessConfig.acceptAccel && ValueObjectManager.getPlayerConfig.videoAcceleration === null)))
			{
				loadSinaVideo(vid);
				return;
			}
			/** 可以考虑把地址弄进配置文件 **/
			loadSingleFile(QQTool.defaultSrc(vid));
		}
		
		/**
		 * 加载实际的视频信息
		 * @param aid 文章id
		 * @param page 视频章节
		 **/
		public function loadVideoInfo(aid:String, page:String):void
		{
			var videoInfoLoader:VideoInfoLoader = new VideoInfoLoader(aid, page);
			videoInfoLoader.addEventListener("complete", function(event:MukioEvent):void
				{
					event.data.data.aid = aid;
					dispatchEvent(new MukioEvent('videoInfo', event.data.data)); //这一步会引发accessConfig更新
					loadByAppRouter(event.data.appRouter);
				});
			videoInfoLoader.load();
		}
		
		/**
		 * 播放rtmp流
		 * @params bid bilibili API参数
		 **/
		public function loadBStream(bid:String):void
		{
			var infoLoader:URLLoader = new URLLoader();
			infoLoader.addEventListener(Event.COMPLETE, bStreamLoaderComplete);
			infoLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			infoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			infoLoader.load(new URLRequest('http://interface.bilibili.com/playurl?' + getSign('player=1&cid=' + bid + '&quality=' + (liveQuality || '0'))));
			log('API:开始获取地址');
		}
		
		/**
		 * p2p模式播放
		 * @param url 文件地址,是一个文件名
		 **/
		public function loadBytesStream(url:String):void
		{
			//使用 file而不是url,因为JW判断必须要有file参数
			ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'bytes', file: url}));
		}
		
		/**
		 * 新浪视频加载完毕
		 **/
		protected function sinaInfoCompleteHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			try
			{
				var data:XML = new XML(loader.data);
			}
			catch (error:Error)
			{
				if (sinaFallback !== null && sinaFallback !== "nomore") //新浪fallback
				{
					loadSinaVideo(sinaFallback);
					sinaFallback = "nomore"; //保证只回滚一次
					return;
				}
				/** 视频信息错误 **/
				dispatchEvent(new Event('videoInfoError'));
				log("新浪视频信息出错:不是有效的XML文件.");
				return;
			}
			
			var items:Array = [];
			for each (var itm:XML in data.descendants('durl'))
			{
				if (String(itm.url).length == 0)
				{
					continue;
				}
				var item:Object = {url: String(itm.url), length: parseInt(itm.length)};
				var backups:Array = [];
				/** 解析备用地址 **/
				var backup_url:XMLList = itm.descendants('backup_url');
				if (backup_url.length())
				{
					for each (var bkitm:XML in backup_url[0].descendants('url'))
					{
						backups.push(String(bkitm));
					}
				}
				item.backups = backups;
				items.push(item);
			}
			
			var info:Object = {'length': parseInt(data.timelength), 'items': items, 'fastSeek': true, 'fastSeekParameterName': 'start', 'fastSeekByTime': false, 'isSinaVideo': true, 'isLetvVideo': false};
			
			if (ValueObjectManager.getAccessConfig.vtype === 'qq' && info.items[0].url.indexOf("qq") !== -1)
			{
				info['isSinaVideo'] = false;
				info['fastSeek'] = false;
				info['isLetvVideo'] = false;
			}
			
			/** 自定义fast seek参数 **/
			if (String(data.seek_param).length > 0)
			{
				info["fastSeek"] = true;
				/** String(data.seek_param): String 参数名 **/
				info["fastSeekParameterName"] = String(data.seek_param);
				/** String(data.seek_type): offset|second 参数类型 **/
				info["fastSeekByTime"] = String(data.seek_type) === "second" ? true : false;
			}
			
			/** 使用乐视SDK **/
			var letv:Boolean = String(data.stream) === 'letv' && String(data['args']) !== "";
			
			/** 乐视非SDK源禁止fast seek **/
			if (!letv && String(data.from) === 'letv')
			{
				info["isSinaVideo"] = false;
				info["fastSeek"] = false;
			}
			
			if (data.child("letv-args").length() && String(data['letv-args']) == "")
			{
				LetvStatisticsService.clientInit(String(data.letv_vid), item.length / 1000, String(data.letv_vtype), getTimer() - playurlStartTime);
				info['isLetvVideo'] = true;
			}
			
			/** P2P相关参数 **/
			info.cid = ValueObjectManager.getAccessConfig.chatId.toString();
			info.src = String(data.src);
			info.isCloud = false;
			
			/** 开启p2p **/
			if (String(data.stream) === 'cloud')
			{
				info.isCloud = true;
			}
			
			if (!info.length)
			{
				if (info.length === 0 && info.items.length === 1)
				{
					/** 自己缓存的视频,如果只有一个文件,可能没有时间信息 **/ /** 正常处理!! **/
				}
				else if (letv) //乐视,但是没有rollback
				{
					/**
					 * 保证没有fallback时, videoInfo为null
					 */
					info = null;
				}
				else
				{
					if (sinaFallback !== null && sinaFallback !== "nomore") //新浪fallback
					{
						loadSinaVideo(sinaFallback);
						sinaFallback = "nomore"; //保证只回滚一次
						return;
					}
					else if (String(data.result) == 'error' && String(data.message).match(/video is encoding.|视频正在转码中，请稍后再试。/) && sinaFallback !== 'nomore') //视频转码中,播放转码中视频
					{
						loadSingleFile('http://static.hdslb.com/encoding.flv'); //视频转码中的cid
						sinaFallback = "nomore";
						return;
					}
					/** 视频信息错误 **/
					dispatchEvent(new Event('videoInfoError'));
					log('新浪视频出错!');
					return;
				}
			}
			/**
			 * 承包计划: 延长视频
			 */
			if (ValueObjectManager.getAccessConfig.cf)
			{
				var extend_length:uint = BangumiSponserListPanel.BLANK_VIDEO_LENGTH * 1000;
				info.items.push({url: BangumiSponserListPanel.BLANK_VIDEO_URL, length: extend_length});
				if (info.length > 0)
				{
					info.length += extend_length;
				}
				info.cf = true; //承包标志
			}
			
			/** 视频信息加载成功 **/
			dispatchEvent(new Event('videoInfoComplete'));
			/** 加载时间统计 **/
			//EventTimer.getInstance().end(EventTimerEvent.LOAD_VIDEO_INFO, {from: String(data.from)});
			ValueObjectManager.getTimeLogCollector.setTimeLogEnd("onLoadVideo")
			var bytes:Boolean = String(data.stream) == "bytes";
			
			/** 使用字节流来加载视频：
			 * 视频文件为一个，文件长度必须给出
			 * 文件的http服务器支持 byte-range request header
			 **/
			var bytesInfo:Object = null;
			
			if (bytes)
			{
				ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'bytes', file: true, info: data //在provider 内解析
					}));
			}
			else /** 乐视视频,使用乐视内核播放 **/if (letv)
			{
				ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'letv-swf', file: String(data.args), videoInfo: info //用于乐视错误时,rollback
					}));
			}
			else
			{
				if (isReload)
				{
					/** 不这样设置不会调用model的load **/
					ValueObjectManager.getEventBus.sendMukioEvent('reload', {});
					
					ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'sina', file: 'videoInfo', videoInfo: info}));
				}
				else
				{
					ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'sina', file: 'videoInfo', videoInfo: info}));
				}
			}
		}
		
		/**
		 * 乐视回滚
		 */
		private function letvRollBackHandler(event:MukioEvent):void
		{
			ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'sina', file: 'videoInfo', videoInfo: event.data}));
		}
		
		/**
		 * 新浪视频信息地址
		 * @param vid 视频vid
		 * @return 视频信息地址
		 **/
		private function getSinaVideoInfoURL(vid:String):String
		{
			var prefix:String = '';
			/**
			 * 启用海外加速的前提
			 **/
			if (ValueObjectManager.getAccessConfig.cached && (ValueObjectManager.getPlayerConfig.videoAcceleration === true || (ValueObjectManager.getAccessConfig.acceptAccel && ValueObjectManager.getPlayerConfig.videoAcceleration === null)))
			{
				prefix = 'http://interface.bilibili.com/v_cdn_play?id=';
			}
			else
			{
				if (ValueObjectManager.getAccessConfig.sinapi && sinaFallback === null)
				{
					prefix = 'http://interface.bilibili.com/playurl?vid=';
					sinaFallback = vid;
					/** 不需要r参数 **/
					return prefix + vid;
				}
				else
				{
					prefix = 'http://v.iask.com/v_play.php?vid=';
				}
			}
			return prefix + vid;
		}
		
		/**
		 * cid视频文件信息地址
		 **/
		private function getCidVideoInfoUrl(cid:String):String
		{
			/**
			 * 启用海外加速的前提
			 **/
			var prefix:String = '';
			if (ValueObjectManager.getAccessConfig.cached && (ValueObjectManager.getPlayerConfig.videoAcceleration === true || (ValueObjectManager.getAccessConfig.acceptAccel && ValueObjectManager.getPlayerConfig.videoAcceleration === null)))
			{
				prefix = 'http://interface.bilibili.com/playurl?accel=1&cid=';
			}
			else
			{
				if (ValueObjectManager.getPlayerConfig.highQualityEnabled && ValueObjectManager.getAccessConfig.vtype === "youku")
				{
					prefix = 'http://interface.bilibili.com/playurl?' + (isMiniPlay ? 'from=miniplay&' : '') + 'quality=2&cid=';
				}
				else if (ValueObjectManager.getPlayerConfig.highQualityEnabled && ValueObjectManager.getAccessConfig.vtype === 'qq') //qq源高清quality = 4
				{
					prefix = 'http://interface.bilibili.com/playurl?' + (isMiniPlay ? 'from=miniplay&' : '') + 'quality=4&cid=';
				}
				else
				{
					prefix = 'http://interface.bilibili.com/playurl?' + (isMiniPlay ? 'from=miniplay&' : '') + 'cid=';
				}
			}
			/**
			 * 通过flashvars的urlparam可以附加任意参数:k=v&k2=v2, =& 转义 %3D%26
			 */
			var extraParams:String = "";
			var loaderInfo:LoaderInfo = ValueObjectManager.getAppRouter.loaderInfo;
			if (loaderInfo.parameters.hasOwnProperty("urlparam"))
			{
				extraParams = "&" + loaderInfo.parameters["urlparam"];
			}
			return prefix + cid + extraParams;
		}
		
		/**
		 * cid视频信息加载完成
		 **/
		private function cidCompleteHandler(event:Event):void
		{
//			var loader:URLLoader = event.target as URLLoader;

			ValueObjectManager.getTimeLogCollector.createTimeLog('test','loading complete')
			sinaInfoCompleteHandler(event);
		}
		
		/**
		 * letv视频信息的xml文件加载完成
		 **/
		private function letvCompleteHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			try
			{
				var data:XML = new XML(loader.data);
			}
			catch (error:Error)
			{
				if (sinaFallback !== null && sinaFallback !== "nomore") //新浪fallback
				{
					loadSinaVideo(sinaFallback);
					sinaFallback = "nomore"; //保证只回滚一次
					return;
				}
				/** 视频信息错误 **/
				dispatchEvent(new Event('videoInfoError'));
				log("Letv视频信息出错:不是有效的XML文件.");
				return;
			}
			
			var items:Array = [];
			for each (var itm:XML in data.descendants('durl'))
			{
				items.push({url: String(itm.url), length: parseInt(itm.length)});
			}
			
			var info:Object = {'length': parseInt(data.timelength), 'items': items, 'fastSeek': true, 'fastSeekParameterName': 'start', 'fastSeekByTime': false, 'isSinaVideo': true, 'isLetvVideo': false};
			
			if (!info.length)
			{
				if (info.length === 0 && info.items.length === 1)
				{
					/** 自己缓存的视频,如果只有一个文件,可能没有时间信息 **/ /** 正常处理!! **/
				}
				else
				{
					if (sinaFallback !== null && sinaFallback !== "nomore") //新浪fallback
					{
						loadSinaVideo(sinaFallback);
						sinaFallback = "nomore"; //保证只回滚一次
						return;
					}
					/** 视频信息错误 **/
					dispatchEvent(new Event('videoInfoError'));
					log('Letv视频出错!');
					return;
				}
			}
			
			/** 视频信息加载成功 **/
			dispatchEvent(new Event('videoInfoComplete'));
			ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'sina', file: 'videoInfo', videoInfo: info}));
		}
		
		/**
		 * 获取Letv视频信息
		 **/
		private function getLetvVideoInfoUrl(vid:String):String
		{
			return getCidVideoInfoUrl(vid);
		}
		
		private function bStreamLoaderComplete(event:Event):void
		{
			var info:XML = XML(event.target.data as String);
			//清晰度设置
			var qualities:Array = []
			if (String(info['accept_quality']).length)
			{
				qualities = String(info['accept_quality']).split(',');
			}
			else if (String(info['accept_qualities']).length)
			{
				qualities = String(info['accept_qualities']).split(',');
			}
			if (qualities.length && !liveQuality)
			{
				liveQuality = qualities[0];
				//quality 0 1 2 3 4, 默认 低清 高清 超清 原画
				var names:Object = {0: "默认", 1: "低清", 2: "高清", 3: "超清", 4: "原画"};
				var list:Array = [];
				for (var i:int = 0; i < 5; i++)
				{
					if (qualities.indexOf(String(i)) != -1)
					{
						list.push({id: String(i), name: names[i], type: 'live'});
					}
				}
				var definitionConfig:Object = {current: qualities[0], list: list};
				ValueObjectManager.getEventBus.sendMukioEvent('setLetvDefinitionConfig', definitionConfig);
				ValueObjectManager.getEventBus.addEventListener('setLetvDefinition', setLiveDefinitionHandler);
			}
			
			if (String(info["stream"]) == 'rtmp')
			{
				var server:String = info['durl']['application'];
				var name:String = info['durl']['name'];
				ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'rtmp', streamer: server, file: name}));
			}
			else if (String(info["stream"]) == 'http')
			{
				/** 网速的http直播流 **/
				var url:String = String(info.durl[0].url);
				ValueObjectManager.getMediaProvider.load(new PlaylistItem({type: 'live-video', file: url}));
			}
			else
			{
				trace('未找到直播流!');
					//throw "错误的类型: " + String(info['stream']);
			}
		}
		
		/**
		 * 直播清晰度选择
		 */
		private function setLiveDefinitionHandler(event:MukioEvent):void
		{
			var info:Object = event.data;
			if (info.type == 'live')
			{
				//自动重载视频
				liveQuality = info.id;
				ValueObjectManager.getMediaProvider.stop();
			}
		}
		
		private function errorHandler(event:Event):void
		{
			ValueObjectManager.getTimeLogCollector.createTimeLog('test',event.type)
			if (sinaFallback !== null && sinaFallback !== "nomore") //新浪fallback
			{
				loadSinaVideo(sinaFallback);
				sinaFallback = "nomore"; //保证只回滚一次
				return;
			}
			/** 视频信息错误 **/
			dispatchEvent(new Event('videoInfoError'));
			log(String(event));
		}
		
		/**
		 * 加载一般弹幕文件
		 * @params url 弹幕文件地址
		 **/
		public function loadCmtFile(url:String):void
		{
			ValueObjectManager.getCommentProvider.load(url);
		}
		
		/**
		 * 加载AMF弹幕文件
		 * @params server 弹幕服务器
		 **/
		public function loadCmtData(server:CommentServer):void
		{
			ValueObjectManager.getCommentProvider.load('', BPSetting.CommentFormat_AMFCMT, server);
		}
		
		//以下两个函数在代理测试时使用        
		/**
		 * 加载bili弹幕文件
		 * @params cid 弹幕id
		 **/
		public function loadBiliFile(cid:String):void
		{
		//ValueObjectManager.getTimeLogCollector.createTimeLog('log',cid)
			loadCmtFile('http://comment.bilibili.com/' + cid + '.xml');
		}
		
		/**
		 * 使用老的地址加载bili弹幕文件
		 * @params cid 弹幕id
		 **/
		public function loadBiliFileOld(cid:String):void
		{
			loadCmtFile('http://comment.bilibili.com/dm,' + cid);
		}
		
		/**
		 * 加载bili历史弹幕
		 * @param chatId 频道id
		 * @param timestamp 历史弹幕时间戳
		 **/
		public function loadBiliHistoricFile(chatId:uint, timestamp:int):void
		{
			loadCmtFile('http://comment.bilibili.com/dmroll,' + timestamp + ',' + chatId);
		}
		
		private function log(message:String):void
		{
			ValueObjectManager.getEventBus.log(message);
		}
		
		/**
		 * 加载视频与弹幕
		 * @param router bilibili参数解析器
		 **/
		public function loadByAppRouter(router:AppRouter):void
		{
			switch (router.type)
			{
				case 'bili2': 
					loadCidVideo(router.vid);
					break;
				case 'sina': 
					loadSinaVideo(router.vid);
					break;
				case 'qq': 
					loadQqVideo(router.vid);
					break;
				case 'redirect': 
					loadRedirectVideo(router.vid);
					break;
				case 'bili': 
					loadAVVideo(router.vid);
					break;
				case 'video': 
					loadSingleFile(router.vid);
					break;
				case 'page': 
					loadVideoInfo(router.vid, router.cid);
					//不加载弹幕.
					return;
					break;
				case 'stream': 
					loadBStream(router.vid);
					return;
					break;
				case 'letv': 
					loadLetvVideo(router.vid);
					break;
				default: 
					ValueObjectManager.getEventBus.log("参数错误", true);
					return; //错误情况,什么都不做
			}
			//如果是外链播放器,没有用户权限文件,所以弹幕直接从cid加载
			if (ValueObjectManager.getAccessConfig.chatId === 0)
			{
				loadBiliFile(router.cid);
			}
			else
			{
				loadBiliFile(ValueObjectManager.getAccessConfig.chatId.toString());
			}
			ValueObjectManager.getTimeLogCollector.setTimeLogEnd("network_loading")
		}
	}
}