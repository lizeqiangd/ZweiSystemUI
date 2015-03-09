package com.bilibili.player.net.api
{
	import com.adobe.images.PNGEncoder;
	import com.bilibili.player.core.filter.CommentFilterMode;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.net.HttpUtil;
	import com.bilibili.player.net.interfaces.IPackSender;
	
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;


	/** 
	 * 一些改善交互性的服务:一般来说是不需要菔结果的 
	 * @author:Aristotle9
	 * @editor:Lizeqiangd
	 * 20141204 postid ,aid变量交给直接引用.
	 **/
	public class Services
	{
		
		public static var sender:IPackSender;
		
		/** 如果有必要,向服务器发送视频的总长度 
		 * @param duration 总时间/ms
		 **/
		public static function sendDuration(duration:uint):void
		{
			
			HttpUtil.Get(BilibiliApi.getDMDuration,
				{
					cid: ValueObjectManager.getAccessConfig.chatId.toString()
					,dur: duration
				});
		}
		/** 向服务器发送视频的暂停位置
		 * @param position 位置/ms
		 **/
		public static function sendPosition(position:uint):void
		{
			HttpUtil.Get(BilibiliApi.getPausePosition,
				{
					cid: ValueObjectManager.getAccessConfig.chatId.toString()
					,playtime: position
				});
		}
		/** 
		 * 向服务器发送屏蔽关键字
		 * @param type 过滤类型
		 * @param kw 过滤实体
		 **/
		public static function sendKeyword(type:uint, kw:*):void
		{
			if(ValueObjectManager.getAccessConfig.aid == '')
				return;
			
			HttpUtil.Get(BilibiliApi.getCommentBlockAUrl,
				formatFilterItem(type, kw));
		}
		/** 
		 * 向服务器请求取消屏蔽关键字 
		 * @param type 过滤类型
		 * @param kw 过滤实体
		 **/
		public static function sendUnblockKeyword(type:uint, kw:*):void
		{
			if(ValueObjectManager.getAccessConfig.aid == '')
				return;
			
			HttpUtil.Get(BilibiliApi.getCommentUnBlockAUrl,
				formatFilterItem(type, kw));
		}
		/** 
		 * 将过滤项转化为字符串形式:用于向服务器提交数据 
		 * @param type 过滤类型
		 * @param kw 过滤实体
		 * @return 可以直接发送的键值对象 
		 **/
		public static function formatFilterItem(type:uint, kw:*):Object
		{
			var typeStr:String = '';
			var data:String = '';
			if(type == CommentFilterMode.TEXT)
			{
				typeStr = 'keyword';
				data = kw;
			}
			else if(type == CommentFilterMode.USER)
			{
				typeStr = 'user';
				data = kw;
			}
			else if(type == CommentFilterMode.COLOR)
			{
				typeStr = 'color';
				data = (kw as uint).toString(16);
			}
			return {
				type: typeStr
				,data: data
				,aid: ValueObjectManager.getAccessConfig.aid
				,ver: 2
			};
		}
		/**
		 * 反馈一些错误信息
		 * @param info 错误信息,表示什么地方出错
		 * <p>
		 * sp Error:视频错误:表示视频无法播放</br>
		 * dm Error:表示弹幕加载出错(重新加载三次后)</br>
		 * Config Error:配置错误:从旧代码看表示xml配置出错</br>
		 * </p>
		 **/
		public static function sendErrorInfo(info:String):void
		{
			HttpUtil.Post(BilibiliApi.getCommentErrorUrl,
				{
					id: ValueObjectManager.getAccessConfig.chatId.toString()
					,error: info
				});
		}
		/**
		 * 发送新浪视频流畅度统计
		 * @param cid 视频cid
		 * @param time 距离上一次报告的时间/ms
		 * @param filesize 文件总长度
		 * @param duration 视频总时间/ms
		 * @param bufsize 距离上一次报告后的缓冲大小//增量
		 * @param buftime 距离上一次报告的缓冲时间/没有完成时没有定义//增量
		 * @param fileurl 视频地址
		 * @param r_p2p p2p下载量//增量
		 * @param s_p2p p2p上传量//增量
		 * @param r_cdn cdn下载量//增量
		 * @param targeturl 报告发送地址
		 **/
		private static function sendSinaVideoStat(cid:String
												,time:int
												,filesize:int
												,duration:int
												,bufsize:int//delta
												,buftime:int//delta
												,fileurl:String
												,r_p2p:Number//delta
		 										,s_p2p:Number
		  										,r_cdn:Number//delta
												,targeturl:String):void
		{
			var videohost:String = fileurl.match(/^http:\/\/([^\/]+)/i)[1];
			
			var data:URLVariables = new URLVariables();
			data.cid = cid;
			data.time = Math.floor(time/1000);
			data.filesize = filesize;
			data.duration = duration;
			data.bufsize = bufsize;
			data.buftime = buftime;
			data.videohost = videohost;
			data.r_p2p = r_p2p;
			data.s_p2p = s_p2p;
			data.r_cdn = r_cdn;
			
			if(targeturl.indexOf('v_track') != -1) {
				sender.writePack(259, 'vt:' + data.toString());
			}
			else if(targeturl.indexOf('v_buf') != -1) {
				sender.writePack(259, 'vb:' + data.toString());
			}
		}
		/**
		 * 发送新浪视频流畅度统计
		 * @param cid 视频cid
		 * @param pid 分P号,cid,pid确定一个
		 * @param time 距离上一次报告的时间/ms
		 * @param filesize 总文件大小
		 * @param duration 视频总长度/ms
		 * @param bufsize 缓冲大小,总
		 * @param buftime 缓冲完成的时间/没有完成时未定义
		 * @param fileurl 文件地址
		 * @param r_p2p p2p下载量
		 * @param s_p2p p2p上传量
		 * @param r_cdn cdn下载量
		 * @param isEnd 是否是缓冲结束事件?是的话额外调用一个统计
		 * @param isErr 是否是错误报告
		 **/
		public static function sendSinaVideoStat2(cid:String
												,pid:String
												,time:int
												,filesize:int
												,duration:int
												,bufsize:int
												,buftime:int
												,fileurl:String
												,r_p2p:Number
		 										,s_p2p:Number
		  										,r_cdn:Number
												,isEnd:Boolean
												,isErr:Boolean=false):void
		{
			if(isErr)//错误的话发送错误报告
			{
				sendSinaVideoStat(cid, time, filesize, duration, -1, 0, fileurl, r_p2p, s_p2p, r_cdn, 'http://stat.bilibili.com/v_track');
				return;
			}
			
			bufsize = getDeltaAndResetVal(cid, pid, 'bufsize', bufsize);
			buftime = getDeltaAndResetVal(cid, pid, 'buftime', buftime);
			r_p2p = getDeltaAndResetVal(cid, pid, 'r_p2p', r_p2p);
			s_p2p = getDeltaAndResetVal(cid, pid, 's_p2p', s_p2p);
			r_cdn = getDeltaAndResetVal(cid, pid, 'r_cdn', r_cdn);
			
			sendSinaVideoStat(cid, time, filesize, duration, bufsize, buftime, fileurl, r_p2p, s_p2p, r_cdn, 'http://stat.bilibili.com/v_track');
			if(isEnd)
			{
				sendSinaVideoStat(cid, time, filesize, duration, bufsize, buftime, fileurl, r_p2p, s_p2p, r_cdn, 'http://stat.bilibili.com/v_buf');
			}
		}
		/**
		 * 计算delta的缓存
		 */
		private static var deltaCache:Object = {};
		private static function setVal(k1:String, k2:String, k3:String, val:Number):Number
		{
			var k:String = [k1, k2, k3].join('-');
			var ret:Number = 0;
			if(deltaCache.hasOwnProperty(k))
			{
				ret = deltaCache[k];
			}
			
			deltaCache[k] = val;
			return ret;
		}
		/**
		 * 使用delta cache来计算连续数值的差分,只调用一次即可
		 */
		private static function getDeltaAndResetVal(k1:String, k2:String, k3:String, val:Number):Number
		{
			var oldVal:Number = setVal(k1, k2, k3, val);
			if(oldVal > val)
			{
				return val;
			}
			else
			{
				return val - oldVal;
			}
		}
		private static function completeHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, completeHandler);
		}
		private static function errorHandler(event:ErrorEvent):void
		{
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
		}
		/**
		 * 上传弹幕截图
		 **/
		public static function sendDanmuImage(img:BitmapData, time:Number):void
		{
//			var req:URLRequest = new URLRequest("http://danmuimg.dev/danmu-img.php?time=" + time + "&cid=" + PostId);
			var req:URLRequest = new URLRequest("http://vs0.acgvideo.com/weibo.php?time=" + time + "&cid=" + ValueObjectManager.getAccessConfig.chatId.toString());
			req.method = "POST";
			req.data = PNGEncoder.encode(img);
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, imageUploadComplete);
			loader.load(req);
		}
		/**
		 * 上传成功:返回一个微博分享地址,再调用外部URL打开
		 **/
		private static function imageUploadComplete(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var req:URLRequest = new URLRequest(loader.data);
//			System.setClipboard(loader.data);
//			navigateToURL(req, "_blank");
			ValueObjectManager.getEventBus.sendMukioEvent("showShareImageDialog");
			ValueObjectManager.getEventBus.log(loader.data);
			trace(loader.data);
		}
	}
}