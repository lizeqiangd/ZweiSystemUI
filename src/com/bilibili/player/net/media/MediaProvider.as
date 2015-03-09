package com.bilibili.player.net.media
{
	import com.bilibili.player.components.GlobalEventDispatcher;
	import com.bilibili.player.events.MediaEvent;
	import com.bilibili.player.events.NSEvent;
	import com.bilibili.player.events.PlayerStateEvent;
	import com.bilibili.player.valueobjects.media.PlaylistItem;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	/**
	 * jwplayer5的新浪视频播放模块
	 * 可以用作其他单,多段视频播放模块的原型(使用playItems方法)
	 * 由mukioplayer的jwplayer4的相应文件更改而来,最初的原型参照PADPlayer Project@tamaki
	 *
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141028 尝试更新到新播放器
	 * 20141031 再次删减 尝试冲jwplayer中脱离
	 * 20141105 继续删改 基本脱离了jwplayer框架
	 * 20141126 删除没有用的引用,然后将代理提交给ValueObjectManager管理全局
	 * 20150106 将是否正在播放功能交至本类判断.毕竟的确是这里在判断的.
	 **/
	public class MediaProvider extends EventDispatcher
	{
		/** 是否重复播放 **/
		public var repeat:Boolean = false
		
		/** 是否处于Debug模式 **/
		protected static const DEBUG:Boolean = false;
		/** 视频,显示者 **/
		protected var video:*;
		
		/** 当前播放时间 **/
		protected var _position:Number = 0;
		/** 当前音量  0-1 **/
		private var _volume:Number;
		/** 当前视频状态,请看 @see com.bilibili.player.events.PlayerStateEvent**/
		private var _state:String;
		/** 缓存百分比 **/
		private var _bufferPercent:Number;
		/** NS(网络流)数组,一个NS对应一段视频,即一个网络上的视频文件 **/
		protected var nss:Vector.<SimpleNetStream>;
		/** 视频信息数组,每项的重要数据有视频文件url,视频长度 **/
		protected var ifs:Array = [];
		/** 当前缓冲段索引 **/
		protected var bi:int = -1;
		/** 当前播放段索引 **/
		protected var pi:int = -1;
		/** 总长度,毫秒 **/
		protected var total:int;
		/** 模块状态信息,内部使用 **/
		protected var status:String;
		/** 是否允许seek到未缓冲到的地方 **/
		protected var fastSeekEnabled:Boolean = false;
		/** 等待metaData到后就进行fastSeek的数据 **/
		protected var waitingForMetaData:Object = null;
		/** 事件监听验证(每个时间只有一个ns被监听) **/
		protected var handlersValidator:Vector.<Array> = new Vector.<Array>();
		/** 另一重基于函数本身的验证 **/
		protected var handledBuffer:SimpleNetStream;
		protected var handledPlay:SimpleNetStream;
		/** 是否是准备重新开始播放 **/
		protected var restart:Boolean = false;
		
		/** 检测视频宽度与高度是否变化 **/
		protected var videoResolutionTimer:Timer;
		protected var oldVideoWidth:uint = 0;
		protected var oldVideoHeight:uint = 0;
		/** 视频目前宽度 **/
		protected var _width:Number;
		/** 视频目前高度 **/
		protected var _height:Number;
		
		/** Reference to the currently active playlistitem. **/
		protected var _item:PlaylistItem;
		/** Clip containing graphical representation of the currently playing media **/
		//private var _media:MovieClip;
		/** Handles event dispatching **/
		private var _dispatcher:GlobalEventDispatcher;
		/** Whether or not to stretchthe media **/
		private var _stretch:Boolean;
		/** Queue buffer full event if it occurs while the player is paused. **/
		private var _queuedBufferFull:Boolean;
		/** 是否是新浪视频 **/
		protected var isSinaVideo:Boolean = false;
		/** 是否是Letv **/
		protected var isLetvVideo:Boolean = false;
		/** 视频码率:用于letv **/
		protected var videorate:Number = 0;
		
		/**
		 * 心跳计时器:频率是一秒钟一次,同时记下当前的播放状态
		 * 到时候作统计
		 **/
		//protected var heartTimer:Timer;
		/** 发送心跳 **/
		//protected var heartSendTimer:Timer;
		/** 状态计点 **/
		protected var playPts:uint;
		protected var pausePts:uint;
		protected var bufferPts:uint;
		/** metadata加载时间 **/
		protected var loadtime:Number;
		
		//protected var config:PlayerConfig
		
		public function MediaProvider()
		{
			//_provider = "sina";
			//_dispatcher = ValueObjectManager.GlobalEventDispatch_MediaProvider
			_stretch = true;
		}
		
		/** 插件初始化,在此可以使用播放器的配置了 **/
		public function initializeMediaProvider( /*cfg:PlayerConfig*/):void
		{
			videoResolutionTimer = new Timer(1000);
			videoResolutionTimer.addEventListener(TimerEvent.TIMER, videoResolutionChangeHandler);
			videoResolutionTimer.start();
		}
		
		/**
		 * Load a new playlist item
		 * @param itm The playlistItem to load
		 **/
		public function load(itm:PlaylistItem):void
		{
			//防止启动两次
			if (_item)
			{
				return;
			}
			_item = itm;
			/** videoInfo标志表示传进来的是videoInfo对象,跳过获取xml **/
			if (itm.file == 'videoInfo')
			{
				playeItems(itm.videoInfo);
			}
			//告诉外面文件加载完成?
			dispatchEvent(new MediaEvent(MediaEvent.MEDIA_LOADED));
		}
		
		/**
		 * Resizes the display.
		 *
		 * @param width		The new width of the display.
		 * @param height	The new height of the display.
		 **/
		public function resize(width:Number, height:Number):void
		{
			_width = width;
			_height = height;
			
			sendMediaEvent(MediaEvent.MEDIA_RESIZE, {videoWidth: _width, videoHeight: _height})
			//trace("SinaMediaProvider.resize:", "DisplayResize")
			//TODO: Your code goes here
			//if (media)
			//{
			//Stretcher.stretch(media, width, height, config.stretching);
		/** 弹幕层需要调整大小 **/
		
			//CommentView.getInstance().resize(0, 0);
			//}
		}
		
		/**
		 * Stop playing and loading the item.
		 * 视频停止功能.一般用于播放完成后调用,会导致内部资源回收.(现在还有人会做这个按钮?)
		 */
		public function stop():void
		{
			switch (status)
			{
				case 'prepare': 
				case 'pause': 
					//case 'ready': 
					return;
					break;
				case 'ready': 
					for (var i:int = 0; i < nss.length; i++)
					{
						getns(i).stopV();
							//trace("getns(i).stopV() : ");
					}
					video.clear();
					pi = -1;
					changeNS();
					pause();
					sendMediaEvent(MediaEvent.MEDIA_TIME, {position: 0, duration: total / 1000});
					break;
				default: 
			}
		}
		
		/**
		 * Change the playback volume of the item.
		 * 调节音量是0到100的参数.务必注意
		 * @param vol	The new volume (0 to 100).
		 **/
		public function setVolume(vol:Number):void
		{
			_volume = vol
			for (var i:uint = 0; i < nss.length; i++)
			{
				getns(i).volume = _volume;
			}
			sendMediaEvent(MediaEvent.MEDIA_VOLUME, {'volume': vol});
		}
		
		/**
		 * Resume playback of the item.
		 * 播放操作.
		 * 准备和播放状态 无操作
		 * 准备完成状态   开始缓存
		 * 暂停           播放
		 */
		public function play():void
		{
			switch (status)
			{
				case 'prepare': 
				case 'play': 
					//trace("sinamediaprovider.play:", status)
					return;
					break;
				case 'ready': 
					createBuffer();
					changeNS();
					status = 'play';
					return; //开始缓冲时不发出事件					
					break
				case 'pause': 
					getns(pi).play();
					status = 'play';
					break;
				default: 
				//trace("sinamediaprovider.play:error state", status)
			}
			if (_queuedBufferFull)
			{
				_queuedBufferFull = false;
				setState(PlayerStateEvent.BUFFERING);
				sendMediaEvent(MediaEvent.MEDIA_BUFFER_FULL);
			}
			else
			{
				setState(PlayerStateEvent.PLAYING);
			}
		}
		
		/**
		 * Pause playback of the item.
		 * 暂停操作
		 */
		public function pause():void
		{
			switch (status)
			{
				case "prepare": 
				case 'ready': 
				case "pause": 
					return;
					break;
				case "play": 
					getns(pi).pause();
					status = 'pause';
					break;
				default: 
			}
			setState(PlayerStateEvent.PAUSED);
		}
		
		/**
		 * Seek操作.
		 * @param pos	The position in seconds.
		 **/
		public function seek(pos:Number):void
		{
			if (DEBUG)
			{
				checkNssStatus();
			}
			trace("MediaProvider.seek:", pos)
			switch (status)
			{
				case 'prepare': 
					return;
					break;
				case 'ready': 
				case 'pause': 
					play();
					seek(pos);
					//pause();
					return;
					break;
				default: 
			}
			//trace("MediaProvider.seek2:", pos)
			_position = pos;
			sendMediaEvent(MediaEvent.MEDIA_TIME, {position: _position, duration: total / 1000});
			sendMediaEvent(MediaEvent.MEDIA_SEEK, {position: _position, duration: total / 1000});
			
			pos *= 1000;
			var offsetInfo:Object;
			/** 偏移时间 **/
			var si:int = getPIByTime(pos);
			var partialOffset:uint = pos - nss[si].timeOffset;
			
			getns(pi).pause();
			if (nss[si].isBuffering || nss[si].bufferComplete)
			{
				var ns:SimpleNetStream = nss[si];
				if (pi != si)
				{
					/** 切换播放ns **/
					nss[pi].stop();
					uninstallPlayingHandlers(nss[pi]);
					pi = si;
					installPlayingHandlers(nss[pi]);
					video.attachNetStream(ns.ns);
				}
				
				offsetInfo = getns(pi).getOffset(partialOffset / 1000);
				/** seek点落在缓冲段中 **/
				if (ns.partialBytesOffset <= offsetInfo.offset && ns.partialBytesOffset + ns.ns.bytesLoaded >= offsetInfo.offset)
				{
					seekInPart(pos, si);
					return;
				}
				else
				{
					if (fastSeekEnabled)
					{
						if (ns.hasKeyframes)
						{
							stopBuffering();
							bi = si;
							installBufferingHandlers(ns);
							ns.isPartial = true;
							ns.partialBytesOffset = offsetInfo.offset;
							ns.partialOffset = offsetInfo.time * 1000;
							ns.buffer();
							ns.play();
							return;
						}
						else
						{
							/** 不会出现在这一分支 **/ /** 刚刚开始缓冲,没有关键帧信息 **/
							waitingForMetaData = offsetInfo;
							return;
						}
					}
					else
					{
						/** 不允许fastseek,只切换到那个段 **/
						seekInPart(pos, si);
						return;
					}
				}
			}
			else
			{
				/** 切换播放ns **/
				getns(pi).stopV();
				uninstallPlayingHandlers(nss[pi]);
				stopBuffering();
				/** 开始缓冲那个段 **/
				bi = si - 1;
				waitingForMetaData = {offsetPos: partialOffset};
				createBuffer(); /** bi += 1 **/
				pi = si;
				installPlayingHandlers(nss[pi]);
				video.attachNetStream(getns(pi).ns);
				return;
			}
		}
		
		/**
		 * 播放模块本身定义的播放列表
		 * @param videoInfo:{length:总长度(毫秒数),items:items}
		 * items:{url:视频地址,length:视频长度}
		 * 单个文件的播放是:
		 * {
		 * length:0,
		 * items:[
		 *        {
		 *         url:fileurl,
		 *         length:0
		 *        }
		 *       ]
		 * fastSeek:是否允许快速拖动(false)
		 * fastSeekByTime:使用时间作为快速拖动的参数(false)
		 * fastSeekParameterName:快速拖动的参数名称(start)
		 * }
		 * 长度为零时会自动去metadata事件时填充,播放信息文件的合法性不在这里检验
		 **/
		protected function playeItems(videoInfo:Object):void
		{
			var fastSeekByTime:Boolean = false;
			var fastSeekParameterName:String = 'start';
			
			/** 受到配置的控制:如果配置不允许快速跳转,则最多只能在多P的缝隙间跳转 **/
			fastSeekEnabled = videoInfo.fastSeek //&& CommentConfig.getInstance().fastSeekEnabled;
			if (fastSeekEnabled)
			{
				fastSeekByTime = videoInfo.fastSeekByTime;
				fastSeekParameterName = videoInfo.fastSeekParameterName;
			}
			
			total = videoInfo.length;
			ifs = videoInfo.items;
			
			/** 长度固定 **/
			nss = new Vector.<SimpleNetStream>(ifs.length, true);
			
			var acc:uint = 0;
			/** 偏移数据:每个偏移数据是其之前的偏移 **/
			for (var i:uint = 0; i < ifs.length; i++)
			{
				nss[i] = new SimpleNetStream(ifs[i].url, acc, i, ifs[i].backups);
				if (fastSeekEnabled)
				{
					nss[i].fastSeekByTime = fastSeekByTime;
					nss[i].fastSeekParameterName = fastSeekParameterName;
				}
				acc += ifs[i].length;
			}
			pi = -1;
			bi = -1;
			
			//item['duration'] = total / 1000;
			//调用父方法,语义同下
			//super.pause();
			
			setState(PlayerStateEvent.PAUSED);
			//播放模块的内部状态设置
			status = 'ready';
			//加载完成后播放
			//if (CommentConfig.getInstance().autoBuffering)
			//{
			play();
			pause();
			//}
			//else
			//{
			/** 显示视频长度 **/
			if (item['duration'])
			{
				sendMediaEvent(MediaEvent.MEDIA_TIME, {position: 0, duration: total / 1000});
			}
			//}
		}
		
		/** 缓冲下一段,如果有的话 **/
		protected function createBuffer():void
		{
			bi += 1;
			if (ifs[bi])
			{
				/** 已经缓冲并且完整的段不再缓冲 **/
				if (nss[bi].isPartial == false && nss[bi].bufferComplete)
				{
					/** 更新一下buffer条(已经缓冲满的ns不会发送buffer相关事件) **/
					bufferingHandler(new NSEvent('', 1));
					/** 缓冲下一段 **/
					return createBuffer();
				}
				/** 部分缓冲的段 **/
				if (nss[bi].isPartial)
				{
					nss[bi].close();
				}
//                trace("create buffer : " + bi);
				var ns:SimpleNetStream = nss[bi];
				installBufferingHandlers(ns);
				
				ns.volume = _volume;
				ns.buffer();
				return;
			}
//            trace('buffer all full');
		}
		
		/** 停止buffer **/
		protected function stopBuffering():void
		{
			if (bi >= 0 && bi < nss.length)
			{
				var ns:SimpleNetStream = nss[bi];
				uninstallBufferingHandlers(ns);
				ns.close();
			}
		}
		
		/** 安装buffering监听 **/
		protected function installBufferingHandlers(ns:SimpleNetStream):void
		{
			if (DEBUG)
			{
				if (handledBuffer == null)
				{
					handledBuffer = ns;
				}
				else
				{
					trace('Big Error##');
					throw new Error();
				}
				handlersValidator.push([1, ns.id]);
				validateHandlers()
			}
			
			ns.addEventListener(NSEvent.BUFFERING, bufferingHandler);
			ns.addEventListener(NSEvent.CHECK_FULL, checkfullHandler);
			ns.addEventListener(NSEvent.META_DATA, metadataHandler);
		}
		
		/** 撤销buffering监听 **/
		protected function uninstallBufferingHandlers(ns:SimpleNetStream):void
		{
			if (DEBUG)
			{
				if (handledBuffer == ns)
				{
					handledBuffer = null;
				}
				else
				{
					trace("Big Error!!");
//					throw new Error();
					ns = handledBuffer;
					handledBuffer = null;
				}
				handlersValidator.push([-1, ns.id]);
				validateHandlers()
			}
			ns.removeEventListener(NSEvent.BUFFERING, bufferingHandler);
			ns.removeEventListener(NSEvent.CHECK_FULL, checkfullHandler);
			ns.removeEventListener(NSEvent.META_DATA, metadataHandler);
		}
		
		/** 安装playing监听 **/
		protected function installPlayingHandlers(ns:SimpleNetStream):void
		{
			if (DEBUG)
			{
				if (handledPlay == null)
				{
					handledPlay = ns;
				}
				else
				{
					trace("Play Error##");
					throw new Error();
				}
				handlersValidator.push([2, ns.id]);
				validateHandlers()
			}
			ns.addEventListener(NSEvent.PLAYING, playingHandler);
			ns.addEventListener(NSEvent.STOP, stopHandler);
		}
		
		/** 撤销playing监听 **/
		protected function uninstallPlayingHandlers(ns:SimpleNetStream):void
		{
			if (DEBUG)
			{
				if (handledPlay == ns)
				{
					handledPlay = null;
				}
				else
				{
					trace("Play Error!!");
					throw new Error();
				}
				handlersValidator.push([-2, ns.id]);
				validateHandlers()
			}
			ns.removeEventListener(NSEvent.PLAYING, playingHandler);
			ns.removeEventListener(NSEvent.STOP, stopHandler);
		}
		
		/** DEBUG用,打印并验证是否具有唯一的监听源 **/
		protected function validateHandlers():void
		{
			var i:uint;
			var ret:Array = [];
			/** 检测buffer是否正常 **/
			for (i = 0; i < handlersValidator.length; i++)
			{
				if (handlersValidator[i][0] == 1 || handlersValidator[i][0] == -1)
				{
					ret.push(handlersValidator[i]);
				}
			}
			trace(ret.join(' '));
			
			ret = [];
			/** 检测play是否正常 **/
			for (i = 0; i < handlersValidator.length; i++)
			{
				if (handlersValidator[i][0] == 2 || handlersValidator[i][0] == -2)
				{
					ret.push(handlersValidator[i]);
				}
			}
			trace(ret.join(' '));
			trace('------------------------------');
		}
		
		/** 切换下一段播放 **/
		protected function changeNS():void
		{
			if (pi >= 0 && pi < ifs.length)
			{
				nss[pi].stop();
			}
			if (pi + 1 < nss.length)
			{
				pi += 1;
				/** 遇到一个部分缓冲的ns **/
				if ((nss[pi].isPartial || (!nss[pi].isBuffering && !nss[pi].bufferComplete)))
				{
					/** 停止正在缓冲的段 **/
					stopBuffering();
					
					bi = pi - 1;
					createBuffer(); /** bi ++ **/
					pi -= 1;
					changeNS();
					return;
				}
				installPlayingHandlers(nss[pi]);
				getns(pi).seekV(0);
				getns(pi).play();
				video.attachNetStream(getns(pi).ns);
			}
		}
		
		/** 收到元数据 **/
		protected function metadataHandler(evt:NSEvent):void
		{
			if (bi == 0)
			{
				videorate = Number(evt.info['videodatarate']);
				if (evt.info['width'])
				{
					_width = evt.info['width']
					_height = evt.info['height']
				}
				
				if (evt.info['duration'] && total == 0)
				{
					_item['duration'] = parseFloat(evt.info.duration);
					total = _item['duration'] * 1000;
					ifs[0].length = total;
				}
				resize(_width, _height);
				sendMediaEvent(MediaEvent.MEDIA_META, {metadata: evt.info});
				
				if (isLetvVideo)
				{
					restart = true;
					loadtime = new Date().getTime() - loadtime;
					
						//LetvStatisticsService.sendOnInit(isNaN(videorate) ? 0 : videorate);
					
						//heartTimer = new Timer(LetvStatisticsService.PlayerStateSampleInterval);
						//heartTimer.addEventListener(TimerEvent.TIMER, collectPlayStateHandler);
					
						//heartSendTimer = new Timer(LetvStatisticsService.HeartInterval);
						//heartSendTimer.addEventListener(TimerEvent.TIMER, collectPlayStateCompleteHandler);
				}
			}
			/** 如果正在等待keyframes信息 **/
			if (fastSeekEnabled && waitingForMetaData != null && getns(bi).hasKeyframes)
			{
				var pos:uint = waitingForMetaData.offsetPos;
				waitingForMetaData = null;
				var ns:SimpleNetStream = getns(bi);
				var offsetInfo:Object = ns.getOffset(pos / 1000);
				
				/** 延迟0.1秒,以便播放器读取文件的视频,音频解码器信息,供分段视频使用 **/
				ns.play();
				setTimeout(function():void
					{
						ns.close();
						ns.isPartial = true;
						ns.partialBytesOffset = offsetInfo.offset;
						ns.partialOffset = offsetInfo.time * 1000;
						ns.buffer();
						ns.play();
						trace('waitingForMetaData  delay 100ms');
					}, 100);
			}
			getns(bi).removeEventListener(NSEvent.META_DATA, metadataHandler);
		}
		
		/** 缓冲状态 **/
		protected function bufferingHandler(evt:NSEvent):void
		{
			var pre:Number;
			var cur:Number;
			pre = nss[bi].timeOffset / total;
			cur = pre + Number(evt.info) * ifs[bi].length / total;
			//sendBufferEvent(cur * 100, 0, {loaded: cur, total: 1});
			sendBufferEvent(cur * 100);
		}
		
		/** 段播放结束 **/
		protected function stopHandler(evt:NSEvent):void
		{
			uninstallPlayingHandlers(nss[pi]);
			if (pi != ifs.length - 1)
			{
				changeNS();
				return;
			}
			
			//stop();
			for (var i:int = 0; i < nss.length; i++)
			{
				getns(i).stopV();
			}
			video.clear();
			
			pi = -1;
			changeNS();
			getns(pi).pause();
			sendMediaEvent(MediaEvent.MEDIA_TIME, {position: 0, duration: total / 1000});
			pause();
			if (isLetvVideo)
			{
				/** 新一轮播放 **/
				//heartTimer.stop();
				//heartSendTimer.stop();
				//LetvStatisticsService.sendOnEnd();
				restart = true;
			}
			//没有完成事件发送到外部, 所以自行确定是否循环播放
			if (repeat /*== 'single'*/)
			{
				play();
			}
			else
			{
				/** 播放完成:只发送事件 **/
				sendMediaEvent(MediaEvent.MEDIA_COMPLETE);
			}
		
//            事实上,stop的处理一直是个关键,按照jwplayer的一贯做法是摧毁视频,
//            如果要再次播放则重新缓冲,这在桌面播放器上是必须的
//            但是播放单一文件的网络播放器又不能如此,应该把视频存储在flash缓存中,而不是浏览器的缓存中
//L:说得好,但这毫无意义.但是似乎会出现卡爆炸的情况
		}
		
		/** 缓冲完成后缓冲下一段 **/
		protected function checkfullHandler(evt:NSEvent):void
		{
			/** 是新浪视频并且不是部分缓冲 **/
			if (isSinaVideo && !nss[bi].isPartial)
			{
				//Services.sendSinaVideoStat(nss[bi].ns.bytesTotal, ifs[bi].length, nss[bi].bufferTime, ifs[bi].url);
			}
			/** auto stop buffering **/
			uninstallBufferingHandlers(nss[bi]);
			createBuffer();
		}
		
		/** 播放状态 **/
		protected function playingHandler(evt:NSEvent):void
		{
			var pos:Number = getns(pi).ns.time; //单位秒
			var bfr:Number = getns(pi).ns.bufferLength / getns(pi).ns.bufferTime;
			//末尾10秒不出现buffer状态
//            if(bfr < 0.5 && pos < ifs[pi].length / 1000 - 10 && state != PlayerStateEvent.BUFFERING) {
//                setState(PlayerStateEvent.BUFFERING);
//            } else if (bfr > 1 && state != PlayerStateEvent.PLAYING) {
//                setState(PlayerStateEvent.PLAYING);
//            }
			if (nss[pi].bufferEmpty && state == PlayerStateEvent.PLAYING)
			{
				setState(PlayerStateEvent.BUFFERING);
			}
			else if (!nss[pi].bufferEmpty && state == PlayerStateEvent.BUFFERING)
			{
				setState(PlayerStateEvent.PLAYING);
			}
			if (state != PlayerStateEvent.PLAYING && state != PlayerStateEvent.BUFFERING)
			{
				return;
			}
			_position = (nss[pi].timeOffset + uint(evt.info)) / 1000;
			sendMediaEvent(MediaEvent.MEDIA_TIME, {position: _position, duration: total / 1000});
		}
		
		/**
		 * 视频的宽度和高度发生变化
		 * 遇到一UP主压制的视频:metadata中的宽度与高度与实际视频的宽度与高度不一致
		 * 导致从metadata事件中获取了错误的结果:
		 * 定时检测有时是这样的:
		 *  0x0
		 *  ->
		 *  720x480
		 *  720x480
		 *  ->
		 *  853x480
		 **/
		protected function videoResolutionChangeHandler(event:TimerEvent):void
		{
			if (oldVideoWidth === video.videoWidth && oldVideoHeight === video.videoHeight)
			{
				return;
			}
			else
			{
				//trace(oldVideoWidth + 'x' + oldVideoHeight);
				oldVideoWidth = video.videoWidth;
				oldVideoHeight = video.videoHeight;
				//trace('->');
				//trace(oldVideoWidth + 'x' + oldVideoHeight);
				
				//video.width = video.videoWidth;
				//video.height = video.videoHeight;
				resize(_width, _height);
			}
		}
		
		/** 按索引取得NS **/
		protected function getns(i:int):SimpleNetStream
		{
			return SimpleNetStream(nss[i]);
		}
		
		/** 按时间取得段索引 **/
		protected function getPIByTime(time:Number):uint
		{
			var i:uint = 0;
			while (i < nss.length)
			{
				if (time >= nss[i].timeOffset && time < nss[i].timeOffset + ifs[i].length)
				{
					return i;
				}
				i++;
			}
			return nss.length - 1;
		}
		
		/**
		 * 在段中seek
		 * @param time 总的时间/ms
		 * @param si 段的序号/0base
		 **/
		protected function seekInPart(time:Number, si:uint):void
		{
			var ptime:Number = time - nss[si].timeOffset;
			pause();
			getns(pi).seekV(ptime);
			play();
		}
		
		/** 查看所有的ns的状态 **/
		protected function checkNssStatus():void
		{
			trace("SinaMediaProvider.checkNssStatus")
			var i:uint;
			var len:uint = nss.length;
			for (i = 0; i < len; i++)
			{
				trace('@' + i + ' ' + nss[i].toString());
			}
			trace("*************end trace nss************");
		}
		
		/**
		 * 返回错误信息
		 * @param	message
		 */
		protected function error(message:String):void
		{
			stop()
			setState(PlayerStateEvent.IDLE);
			_position = 0;
			sendMediaEvent(MediaEvent.MEDIA_ERROR, {message: message});
		}
		
		/**
		 * 发送一个MediaEvent.
		 * @param type
		 * @param property
		 * @param value
		 */
		protected function sendMediaEvent(type:String, properties:Object = null):void
		{
			if (type == MediaEvent.MEDIA_BUFFER_FULL && state == PlayerStateEvent.PAUSED)
			{
				_queuedBufferFull = true;
			}
			else
			{
				var newEvent:MediaEvent = new MediaEvent(type);
				for (var property:String in properties)
				{
					if (newEvent.hasOwnProperty(property))
					{
						newEvent[property] = properties[property];
					}
				}
				dispatchEvent(newEvent);
			}
		}
		
		/**
		 * 返回当前buffer情况信息.
		 * 返回内容 新增  buffer 秒数
		 * @param	bufferPercent
		 * @param	offset
		 * @param	metadata
		 */
		//protected function sendBufferEvent(bufferPercent:Number, offset:Number = 0, metadata:Object = null):void
		protected function sendBufferEvent(bufferPercent:Number):void
		{
			if ((_bufferPercent != bufferPercent || bufferPercent == 0) && 0 <= bufferPercent < 100)
			{
				_bufferPercent = bufferPercent;
				//var obj:Object = {'buffer': _bufferPercent / 100 * _item.duration, 'bufferPercent': _bufferPercent, 'offset': offset, 'duration': _item.duration, 'position': Math.max(0, _position), 'metadata': metadata};
				var obj:Object = {'buffer': _bufferPercent * total / 100000, 'bufferPercent': _bufferPercent, 'offset': 0, 'duration': _item.duration, 'position': Math.max(0, _position), 'metadata': null};
				sendMediaEvent(MediaEvent.MEDIA_BUFFER, obj);
			}
		}
		
		/**
		 * 设置当前MediaProvider里面的视频状态. @see com.bilibili.player.events.PlayerStateEvent
		 * @param newState A state from ModelStates.
		 */
		protected function setState(newState:String):void
		{
			if (state != newState)
			{
				var evt:PlayerStateEvent = new PlayerStateEvent(PlayerStateEvent.PLAYER_STATE, newState, state);
				_state = newState;
				dispatchEvent(evt);
			}
		}
		
		/**
		 * 设置video渲染者
		 */
		public function set setVideoRender(e:*):void
		{
			try
			{
				video.attachNetStream(null)
			}
			catch (e:*)
			{
				trace("MediaProvider.setVideoRender:unable to remove attachNS")
			}
			video = e
			try
			{
				video.attachNetStream(getns(pi).ns)
			}
			catch (e:*)
			{
				trace("MediaProvider.setVideoRender:unable to avtive attachNS")
			}
		}
		
		/**
		 * Current position, in seconds
		 * 获取当前视频播放的位置
		 * @return Number 单位:秒
		 */
		public function get position():Number
		{
			return _position;
		}
		
		/** Currently playing PlaylistItem **/
		public function get item():PlaylistItem
		{
			return _item;
		}
		
		public function get isPlay():Boolean
		{
			return _state == 'play'
		}
		
		public function get isPause():Boolean
		{
			return !isPlay
		}
		
		/**
		 * 返回当前状态
		 * @see PlayerStateEvents
		 */
		public function get state():String
		{
			return _state;
		}
		
		/**
		 * 返回当前视频高度
		 */
		public function get videoHeight():Number
		{
			return _height
		}
		
		/**
		 * 返回当前视频宽度
		 */
		public function get videoWidth():Number
		{
			return _width
		}
	}
}