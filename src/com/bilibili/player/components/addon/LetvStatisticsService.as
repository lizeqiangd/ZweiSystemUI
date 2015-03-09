package com.bilibili.player.components.addon
{
	import com.adobe.crypto.MD5;
	import com.bilibili.player.components.encode.DateTimeUtils;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.config.BPSetting;
	//import com.longtailvideo.jwplayer.utils.Strings;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.utils.getTimer;
	
	//import org.lala.utils.ApplicationConstants;
	//import org.lala.utils.CommentConfig;

	/**
	 * 乐视事件上报
	 **/
	public final class LetvStatisticsService
	{
		/**
		 * 心跳周期:ms
		 * 最小心跳间隔;当计数为  0 + 1 + 4 + 12 + 12 时送出
		 **/
		public static const HeartInterval:uint = 15 * 1000;
		/**
		 * 视频状态采样间隔:ms
		 **/
		public static const PlayerStateSampleInterval:uint = 200;
		private static var _vid:String = null;
		/**
		 * 视频长度,秒
		 */
		private static const DC_HOST:String = 'http://dc.letv.com';
//		private static const URLPrefix:String = 'http://42.121.79.24/vq';
		private static const version:String = 'bcloud_1.0.5.31';
//		private static const ch:String = 'bcloud_' + '120211';
		private static const ch:String = 'bcloud_' + '100172';
		private static const cid:String = '100';
		
		private static const ver:String = '2.0';
		private static const p1:String = '3';
		private static const p2:String = '30';
		private static const p3:String = '-';
		
		private static var _uuid:String = null;
		private static var lc:String;
		
		private static var url:String = null;
		private static var ref:String = null;
		
		private static var vlen:int = 0;
		private static var vt:int = 1;
		private static var weid:String = '-';
		
		private static var ru:String;
		private static var numPlay:uint = 0;
		private static var numTimes:uint = 0;
		private static var lastTime:Number = 0;
		/**
		 * 上次已经加载的字节数量
		 */
		private static var lastBytesLoaded:uint = 0;
		
		private static var gslbLoadTime:int;
		
		private static var os:String = '-';
		private static var br:String = '-';
		private static var ro:String = '-';
		
		/**
		 * 是不是自动播放
		 */
		private static var ap:int = 0; 
		
		
		/** 外部发送器 **/
		private static var sender:Object = null;
		/** 发送器加载成功前的消息:不过时间就不对了期望加载比较快 **/
		private static var msgCache:Array = [];
		/**
		 * 初始化客户端的常量
		 * @param letv_vid 乐视的vid
		 * @param duration 视频长度,秒
		 * @param vtStr letv_vt
		 * @param loadTime playurl加载时间
		 **/
		public static function clientInit(letv_vid:String, duration:Number, vtStr:String, loadTime:int):void
		{
			vid = letv_vid;
			vlen = Math.floor(duration);
			vt = getVT(vtStr);
			gslbLoadTime = loadTime;
			ap =ValueObjectManager.getPlayerConfig.autoOpenNextPart ? 1 : 0;
			
			/** 播放器来源 **/
			ru = null;
			
			/** 初始化lc **/
			var so:SharedObject = SharedObject.getLocal(BPSetting.SharedObjectName,'/');
			var letv:Object = so.data['letv'];
			/** 注意在letv命名空间下可能有其他的数据 **/
			if(letv == null)
			{
				lc = createLC();
				so.data['letv'] = {'lc': lc};
				so.flush();
			}
			else
			{
				lc = letv['lc'];
				if(lc == null)
				{
					lc = createLC();
					so.data['letv']['lc'] = lc;
					so.flush();
				}
			}
			
			//js变量
			if(ExternalInterface.available)
			{
				try
				{
					url = ExternalInterface.call('window.location.href.toString');
					ref = ExternalInterface.call("window.document.referrer.toString");
					if(ref == "")
					{
						ref = "-";
					}
					os = ExternalInterface.call("window.navigator.oscpu.toString");
					os = getOS(os);
					br = ExternalInterface.call("window.navigator.userAgent.toString");
					br = getBR(br);
				}
				catch(e:Error)
				{
					url = '-';
					ref = '-'
					if(ref == "")
					{
						ref = "-";
					}
					os = '-';
					os = getOS(os);
					br = '-';
					br = getBR(br);
				}
			}
			
			var loader:Loader = new Loader();
			var context:LoaderContext = new LoaderContext(true, new ApplicationDomain());
			loader.load(new URLRequest("http://yuntv.letv.com/bcloud_bili.swf"), context);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void
			{
				sender = loader.contentLoaderInfo.content;
				
				if(msgCache.length)
				{
					var len:uint = msgCache.length;
					var i:int;
					for(i = 0; i < len; i++)
					{
						sender.sendMessage(msgCache[i]);
					}
				}
			});
		}
		
		/**
		 * 发送Env,当数据充足时便可发送
		 */
		private static function sendEnv():void
		{
			var dt:URLVariables = new URLVariables();
			
			dt['p1'] = p1;
			dt['p2'] = p2;
			dt['p3'] = p3;
			
			dt['lc'] = lc;
			dt['uuid'] = uuid;
			
			dt['ip'] = '-';
			dt['mac'] = '-';
			dt['nt'] = '-';
			dt['os'] = os;
			
			dt['osv'] = '-';
			dt['app'] = '-';
			dt['bd'] = '-';
			dt['xh'] = '-';
			dt['ro'] = Capabilities.screenResolutionX + "_" + Capabilities.screenResolutionY;
			
			dt['br'] = br;
			dt['r'] = Math.random();
			
			sendRequest(DC_HOST + '/env/', dt);
		}
		/**
		 * 视频开始播放时发送日志
		 * @param videorate 视频码率
		 **/
		public static function sendOnInit(videorate:uint):void
		{
	
			//在这里发送ENV,可以保证一个用户只发一次
			sendEnv();
			
			var dt:URLVariables = new URLVariables();
			
			dt['ver'] = ver;
			dt['p1'] = p1;
			dt['p2'] = p2;
			dt['p3'] = p3;

			dt['lc'] = lc;
			dt['uuid'] = uuid;
			dt['uid'] = '-';
			
			dt['ac'] = 'init';
			
			dt['auid'] = '-';
			dt['cid'] = cid;
			dt['pid'] = '-';
			dt['vid'] = vid;
			
			dt['vlen'] = vlen;
			dt['ch'] = ch;
			dt['ry'] = 0;//重试次数
			dt['ty'] = 0;//播放类型
			
			dt['url'] = url;
			dt['ref'] = ref;
			
			dt['pv'] = Capabilities.version;
			dt['st'] = '-';
			dt['ilu'] = 1;
			dt['pcode'] = '-';
			dt['pt'] = 0;
			
			dt['weid'] = weid;
			dt['vt'] = vt;
			dt['py'] = '-';
			dt['err'] = 0;
			dt['ut'] = '-';
			dt['ap'] = ap;
			dt['r'] = Math.random();
			
			sendRequest(DC_HOST + '/pl/', dt);
			
			sendGSLB(gslbLoadTime);	
		}
		/**
		 * 非自动播放情况下用户点击一次，发送一次统计
		 */
		public static function sendOnClientPlay():void
		{
			if(ap == 1)/** 自动播放情况下不发送ap统计 **/
			{
				return;
			}
			
			var dt:URLVariables = new URLVariables();
			
			dt['ver'] = ver;
			dt['p1'] = p1;
			dt['p2'] = p2;
			dt['p3'] = p3;
			
			dt['lc'] = lc;
			dt['uuid'] = uuid;
			dt['uid'] = '-';
			
			dt['ac'] = 'cp';
			
			dt['auid'] = '-';
			dt['cid'] = cid;
			dt['pid'] = '-';
			dt['vid'] = vid;
			
			dt['vlen'] = vlen;
			dt['ch'] = ch;
			dt['ry'] = 0;//重试次数
			dt['ty'] = 0;//播放类型
			
			dt['url'] = url;
			dt['ref'] = ref;
			
			dt['pv'] = Capabilities.version;
			dt['st'] = '-';
			dt['ilu'] = 1;
			dt['pcode'] = '-';
			dt['pt'] = 0;
			
			dt['weid'] = weid;
			dt['vt'] = vt;
			dt['py'] = '-';
			dt['err'] = 0;
			dt['ut'] = '-';
			dt['ap'] = ap;
			dt['r'] = Math.random();
			
			sendRequest(DC_HOST + '/pl/', dt);
		}
		/**
		 * 播放心跳,视频开始播放后每隔三分钟调用一次
		 * @param time 视频当前时间/ms
		 * @param must 不考虑计数,强制上报;用在结束时
		 **/
		public static function sendOnWatching(  time:uint
										  , bytesLoaded:uint
										  , bytesTotal:uint
										  , pauseTime:uint
										  , bufferTime:uint
										  , must:Boolean = false):void
		{
			numTimes ++;
			
			if(lastBytesLoaded < 1024 && bytesLoaded >= 1024)
			{
				var currentTime:int = getTimer();
				sendCload(t - lastTime, true);
			}
			lastBytesLoaded = bytesLoaded;
			
			if(!must)
			{
				/**
				 * 只有上报time时才上报此参数 首次15秒上报，然后相隔1分钟上报播放时长为60;此后每隔3分钟上报一次,最后用户结束播放时上报一次计时。
				 */
				if(numTimes == 1 || numTimes == 5)
				{
				}
				else if(numTimes > 5) 
				{
					if((numTimes - 5) % 12 == 0)
					{
						
					}
					else
					{
						return;
					}
				}
			}
			
			var t:uint = getTimer();
			var pt:uint = Math.floor((t - lastTime) / 1000);//pt取上次play的时间差
			lastTime = t;
			
			var dt:URLVariables = new URLVariables();
			
			dt['ver'] = ver;
			dt['p1'] = p1;
			dt['p2'] = p2;
			dt['p3'] = p3;
			
			dt['lc'] = lc;
			dt['uuid'] = uuid;
			dt['uid'] = '-';
			
			dt['ac'] = 'time';
			
			dt['auid'] = '-';
			dt['cid'] = cid;
			dt['pid'] = '-';
			dt['vid'] = vid;
			
			dt['vlen'] = vlen;
			dt['ch'] = ch;
			dt['ry'] = 0;//重试次数
			dt['ty'] = 0;//播放类型
			
			dt['url'] = url;
			dt['ref'] = ref;
			
			dt['pv'] = Capabilities.version;
			dt['st'] = '-';
			dt['ilu'] = 1;
			dt['pcode'] = '-';
			dt['pt'] = pt;
			
			dt['weid'] = weid;
			dt['vt'] = vt;
			dt['py'] = 'play=1';
			dt['err'] = 0;
			dt['ut'] = '-';
			dt['ap'] = ap;
			dt['r'] = Math.random();
			
			sendRequest(DC_HOST + '/pl/', dt);
		}
		/**
		 * 完成一次播放时发送
		 **/
		public static function sendOnEnd():void
		{
			//结束前强制上报
			sendOnWatching(0, 0, 0, 0, 0, true);
			
			var dt:URLVariables = new URLVariables();
			
			dt['ver'] = ver;
			dt['p1'] = p1;
			dt['p2'] = p2;
			dt['p3'] = p3;
			
			dt['lc'] = lc;
			dt['uuid'] = uuid;
			dt['uid'] = '-';
			
			dt['ac'] = 'end';
			
			dt['auid'] = '-';
			dt['cid'] = cid;
			dt['pid'] = '-';
			dt['vid'] = vid;
			
			dt['vlen'] = vlen;
			dt['ch'] = ch;
			dt['ry'] = 0;//重试次数
			dt['ty'] = 0;//播放类型
			
			dt['url'] = url;
			dt['ref'] = ref;
			
			dt['pv'] = Capabilities.version;
			dt['st'] = '-';
			dt['ilu'] = 1;
			dt['pcode'] = '-';
			dt['pt'] = 0;
			
			dt['weid'] = weid;
			dt['vt'] = vt;
			dt['py'] = 'play=1';
			dt['err'] = 0;
			dt['ut'] = '-';
			dt['r'] = Math.random();
			
			sendRequest(DC_HOST + '/pl/', dt);
		}
		
		/**
		 * 开始播放时发送
		 * @param utime 连接CDN服务器耗时/ms
		 * @param videorate 视频码率
		 * @param time 播放器上的时间/ms
		 **/
		public static function sendOnPlay(utime:uint, videorate:uint, time:uint=0):void
		{
			numPlay ++;
			numTimes = 0;
			lastBytesLoaded = 0;
			lastTime = getTimer();
			
			var dt:URLVariables = new URLVariables();
			
			dt['ver'] = ver;
			dt['p1'] = p1;
			dt['p2'] = p2;
			dt['p3'] = p3;
			
			dt['lc'] = lc;
			dt['uuid'] = uuid;
			dt['uid'] = '-';
			
			dt['ac'] = 'play';
			
			dt['auid'] = '-';
			dt['cid'] = cid;
			dt['pid'] = '-';
			dt['vid'] = vid;
			
			dt['vlen'] = vlen;
			dt['ch'] = ch;
			dt['ry'] = 0;//重试次数
			dt['ty'] = 0;//播放类型
			
			dt['url'] = url;
			dt['ref'] = ref;
			
			dt['pv'] = Capabilities.version;
			dt['st'] = '-';
			dt['ilu'] = 1;
			dt['pcode'] = '-';
			dt['pt'] = 0;
			
			dt['weid'] = weid;
			dt['vt'] = vt;
			dt['py'] = '-';
			dt['err'] = 0;
			dt['ut'] = Math.floor(utime / 1000);
			dt['ap'] = ap;
			dt['r'] = Math.random();
			
			sendRequest(DC_HOST + '/pl/', dt);
		}
		/**
		 * 访问调度系统上报，获取到调度地址之后上报
		 * @param utime playurl加载时间
		 */
		public static function sendGSLB(utime:uint):void
		{
			var dt:URLVariables = new URLVariables();
			
			dt['ver'] = ver;
			dt['p1'] = p1;
			dt['p2'] = p2;
			dt['p3'] = p3;
			
			dt['lc'] = lc;
			dt['uuid'] = uuid;
			dt['uid'] = '-';
			
			dt['ac'] = 'gslb';
			
			dt['auid'] = '-';
			dt['cid'] = cid;
			dt['pid'] = '-';
			dt['vid'] = vid;
			
			dt['vlen'] = vlen;
			dt['ch'] = ch;
			dt['ry'] = 0;//重试次数
			dt['ty'] = 0;//播放类型
			
			dt['url'] = url;
			dt['ref'] = ref;
			
			dt['pv'] = Capabilities.version;
			dt['st'] = '-';
			dt['ilu'] = 1;
			dt['pcode'] = '-';
			dt['pt'] = 0;
			
			dt['weid'] = weid;
			dt['vt'] = vt;
			dt['py'] = '-';
			dt['err'] = 0;
			dt['ut'] = Math.floor(utime / 1000);
			dt['ap'] = ap;
			dt['r'] = Math.random();
			
			sendRequest(DC_HOST + '/pl/', dt);
		}
		
		/**
		 * 连接调度服务器成功并返回视频正片在cdn的文件地址后
		 * 播放器通过文件地址下载视频文件并成功下载1024个字节时触发“视频内容下载”动作的上报
		 * 如果这个过程发生错误，即时上报错误情况。
		 * @param utime 
		 */
		public static function sendCload(utime:int, success:Boolean=true):void
		{
			var dt:URLVariables = new URLVariables();
			
			dt['ver'] = ver;
			dt['p1'] = p1;
			dt['p2'] = p2;
			dt['p3'] = p3;
			
			dt['lc'] = lc;
			dt['uuid'] = uuid;
			dt['uid'] = '-';
			
			dt['ac'] = 'cload';
			
			dt['auid'] = '-';
			dt['cid'] = cid;
			dt['pid'] = '-';
			dt['vid'] = vid;
			
			dt['vlen'] = vlen;
			dt['ch'] = ch;
			dt['ry'] = 0;//重试次数
			dt['ty'] = 0;//播放类型
			
			dt['url'] = url;
			dt['ref'] = ref;
			
			dt['pv'] = Capabilities.version;
			dt['st'] = '-';
			dt['ilu'] = 1;
			dt['pcode'] = '-';
			dt['pt'] = 0;
			
			dt['weid'] = weid;
			dt['vt'] = vt;
			dt['py'] = '-';
			dt['err'] = 0;
			dt['ut'] = Math.floor(utime / 1000);
			dt['ap'] = ap;
			dt['r'] = Math.random();
			
			sendRequest(DC_HOST + '/pl/', dt);
		}
		
		/** 发送请求 **/
		private static function sendRequest(  url:String
											, data:URLVariables
											, method:String=null):void
		{
//			var loader:Loader = new Loader();
//			var loader:URLLoader = new URLLoader();
//			loader.dataFormat = URLLoaderDataFormat.BINARY;
//			loader.addEventListener(Event.COMPLETE, completeHandler);
//			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
//			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			
//			var req:URLRequest = new URLRequest(getGET_URL(url, data));
//
//			if(method != null)
//			{
//				req.method = method;
//			}
//			
//			loader.load(req);
			if(sender)
			{
				sender.sendMessage(getGET_URL(url, data));
			}
			else
			{
				msgCache.push(getGET_URL(url, data));
			}
		}
		
		private static function completeHandler(event:Event):void
		{
			
		}
		
		private static function errorHandler(event:Event):void
		{
			trace("Letv statis error: " + event.toString());
		}

		/**
		 * 取消一些转义处理
		 **/
		private static function getGET_URL(profix:String, dt:URLVariables):String
		{
			var postfix:String = dt.toString();
			var url:String;
			
			if(profix.indexOf("?") != -1)
			{
				url = profix + '&' + postfix;
			}
			else 
			{
				url = profix + '?' + postfix;
			}
			/** _,.- **/
			return url.replace(/%(5f|2d|2e|2c)/ig
				, function(...args):String
				{
//					trace(args);
					return String.fromCharCode(parseInt(args[1], 16));
				});
		}
		
		/**
		 * 返回该用户此次VV的唯一标识ID.
		 */
		private static function get uuid():String
		{
			if(_uuid == null)
			{
				_uuid = MD5.hash(new Date().getTime() + Math.random() + "");
			}
			
			if(numPlay > 0)
			{
				return _uuid + "_" + numPlay;
			}
			else
			{
				return _uuid;
			}
		}
		
		/**
		 * 返回该用户唯一标识ID.
		 */
		private static function createLC():String
		{
			return MD5.hash(new Date().getTime() + Math.random() + "");
		}

		/**
		 * 乐视的vid
		 **/
		private static function get vid():String
		{
			if(_vid == null)
			{
				throw new Error("letv vid has not been initialized.");
				return null;
			}
			return _vid;
		}

		/**
		 * @private
		 */
		private static function set vid(value:String):void
		{
			_vid = value;
		}
		
		private static function getVT(vtStr:String):int
		{
			var m:Object = { FLV_350: 1
				,"3GP_320X240": 2
				,FLV_ENP: 3
				,CHINAFILM_350: 4
				
				,FLV_VIP: 8 // vip
				,MP4: 9
				,FLV_LIVE: 10 // 直播回看
				,UNION_LOW: 11 // 清华合作
				,UNION_HIGH: 12 // 清华合作
				,MP4_800: 13
				
				,FLV_1000: 16
				,FLV_1300: 17
				,FLV_720P: 18
				,MP4_1080P: 19
				,FLV_1080P6M: 20
				,MP4_350: 21
				,MP4_1300: 22
				,MP4_800_DB: 23 // 杜比 800 mp4
				,MP4_1300_DB: 24 // 杜比 1300 mp4
				,MP4_720P_DB: 25 // 杜比 720p mp4
				,MP4_1080P6M_DB: 26 // 杜比 1080p6m mp4
				,FLV_YUANHUA: 27
				,MP4_YUANHUA: 28
				,FLV_720P_3D: 29
				,MP4_720P_3D: 30
				,FLV_1080P6M_3D: 31
				,MP4_1080P6M_3D: 32
				,FLV_1080P_3D: 33
				,MP4_1080P_3D: 34
				,FLV_1080P3M: 35
				
				,FLV_4K: 44
				,H265_800: 45
				,H265_1300: 46
				,H265_720P: 47
				,H265_1080P: 48};
			
			var key:String = vtStr.toUpperCase();
			if(m.hasOwnProperty(key))
			{
				return m[key];
			}
			
			return 1;
		}
		
		private static function getOS(osStr:String=null):String
		{
			osStr = Capabilities.os.toLowerCase();
			if(osStr.indexOf("windows xp") >= 0)
			{
				return "winxp";
			}
			if(osStr.indexOf("windows 7") >= 0)
			{
				return "win7";
			}
			if(osStr.indexOf("windows 8") >= 0)
			{
				return "win8";
			}
			if(osStr.indexOf("windows vista") >= 0)
			{
				return "vista";
			}
			if(osStr.indexOf("windows ce") >= 0)
			{
				return "wince";
			}
			if(osStr.indexOf("linux") >= 0)
			{
				return "linux";
			}
			return osStr;
		}
		
		private static function getBR(brStr:String):String
		{
			if(brStr == null)
			{
				return "-";
			}
			brStr = brStr.toLowerCase();
			
			if(brStr.indexOf("msie") >= 0)
			{
				brStr = brStr.split(";")[1];
				brStr = DateTimeUtils.trim(brStr);
				brStr = brStr.split(" ")[1];
				return "ie" + int(brStr);
			}
			if(brStr.indexOf("360se") >= 0)
			{
				return "360";
			}
			if(brStr.indexOf("tencent") >= 0)
			{
				return "qq";
			}
			if(brStr.indexOf("se 2.x") >= 0)
			{
				return "sogou";
			}
			if(brStr.indexOf("tencent") >= 0)
			{
				return "qq";
			}
			if(brStr.indexOf("firefox") >= 0)
			{
				return "ff";
			}
			if(brStr.indexOf("chrome") >= 0)
			{
				return "chrome";
			}
			if(brStr.indexOf("safari") >= 0)
			{
				return "safa";
			}
			if(brStr.indexOf("opera") >= 0)
			{
				brStr="opera";
			}
			return "other";
		}
	}
}