package com.bilibili.player.net.media
{
	import com.bilibili.player.events.NSEvent;
	import com.bilibili.player.valueobjects.net.NetClient;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	//import org.lala.utils.QQTool;
	
	/**
	 *info:data
	 **/
	//[Event(name="metaData", type="org.lala.media.NSEvent")]
	/**
	 * 经过简化的NetStream类
	 * 使用事件监听而不是client来处理状态
	 * 收到元数据
	 * info:data
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141028 尝试更新到新播放器
	 **/
	
	final public class SimpleNetStream extends EventDispatcher
	{
		/** 重试间隔/ms  **/
		protected static const RETRY_INTERVAL:uint = 2000;
		/** 默认缓存时长  **/
		protected static const DEFAULT_BUFF_TIME:uint = 5
		/** 基本构造  **/
		protected var _nc:NetConnection;
		/** 基本构造  **/
		protected var _ns:NetStream;
		/** 视频地址 **/
		protected var _url:String;
		/** 缓冲表 **/
		protected var _btimer:Timer;
		/** 播放表 **/
		protected var _ptimer:Timer;
		/** 是否处于正在播放状态:在重试时,如果处于正在播放的状态,则不暂停 **/
		protected var _isPlay:Boolean = false;
		/** 确定是否发出了结束信号,但是还在播放中(buffer中还有数据) **/
		protected var _stopped:Boolean = false;
		protected var _stopFlag:Boolean = false;
		/** keyframes信息 **/
		protected var _keyframes:Object;
		/** 是否已经缓冲完成 **/
		protected var _bufferComplete:Boolean = false;
		/** 是否在缓冲 **/
		protected var _isBuffering:Boolean = false;
		/** 是否是部分缓冲 **/
		protected var _isPartial:Boolean = false;
		/** 部分模式下的偏移/时间/ms:应该是某个关键帧的位置 **/
		protected var _partialOffset:uint = 0;
		/** 部分模式下的偏移/长度/bytes **/
		protected var _partialBytesOffset:uint = 0;
		/** 时间偏移数据/ms **/
		protected var _timeOffset:uint = 0;
		/** 在一个序列中的编号 **/
		protected var _id:uint;
		/** 快速拖动的参数相关变量 **/
		protected var _fastSeekByTime:Boolean = false;
		/** 快速拖动的参数相关变量 **/
		protected var _fastSeekParameterName:String = 'start';
		/** 是否是mp4:在分段后的时间计算上与flv格式有区别 **/
		protected var _mp4:Boolean = false;
		/** 开始缓冲时间 **/
		protected var _bufferStartTime:uint;
		/** 完成缓冲时间 **/
		protected var _bufferCompleteTime:uint;
		/** 视频是否正在播放:缓冲/播放(暂停不影响该效果) **/
		protected var _bufferEmpty:Boolean = true;
		
		/**
		 * 备用的视频地址:只有一个表示没有备用地址
		 */
		private var backupUrls:Vector.<String> = new Vector.<String>();
		/**
		 * 备用视频地址的index
		 */
		private var backupIndex:uint = 0;
		
		/**
		 * 初始化一个简单流
		 * @param url 视频文件地址
		 **/
		public function SimpleNetStream(url:String = null, timeOffset:uint = 0, id:uint = 0, backup_urls:Array = null)
		{
			_url = url;
			_timeOffset = timeOffset;
			_id = id;
			
			backupUrls.push(url);
			if (backup_urls != null)
			{
				for each (var u:String in backup_urls)
				{
					backupUrls.push(u);
				}
			}
			
			_btimer = new Timer(150);
			_btimer.addEventListener(TimerEvent.TIMER, emitBufferStatus);
			
			_ptimer = new Timer(100);
			_ptimer.addEventListener(TimerEvent.TIMER, emitPlayStatus);
			
			_nc = new NetConnection();
			_nc.connect(null);
			
			_ns = new NetStream(_nc);
			_ns.bufferTime = DEFAULT_BUFF_TIME;
			
			_ns.client = new NetClient(this);
			_ns.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			_ns.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
		}
		
		/**
		 * 开始缓冲
		 **/
		public function buffer():void
		{
			_stopFlag = false;
			_stopped = false;
			_bufferComplete = false;
			_isBuffering = true;
			_bufferStartTime = getTimer();
			
			_ns.play(url);
			_ns.pause();
			_ns.seek(0);
			_btimer.start();
		}
		
		/** 重新缓冲 **/
		public function reBuffer():void
		{
			/**
			 * 具有备用的地址:切换比QQ源的切换优先
			 */
			if (backupUrls.length > 1)
			{
				backupIndex++;
				backupIndex %= backupUrls.length;
				_url = backupUrls[backupIndex];
			}
			///**
			//* quick hack:切换QQ源
			//**/
			//else if(QQTool.isQQSrc(url))
			//{
			//_url = QQTool.alterSrc(url);
			//}
			_ns.close();
			_btimer.stop();
			setTimeout(function():void
				{
					_stopFlag = false;
					_stopped = false;
					_bufferComplete = false;
					_isBuffering = true;
					_bufferStartTime = getTimer();
					
					_ns.play(url);
					_ns.pause();
					_ns.seek(0);
					_btimer.start();
					if (_isPlay)
					{
						_ns.resume();
					}
				}, RETRY_INTERVAL + 1000 * Math.random());
		}
		
		/**
		 * 播放
		 **/
		public function play():void
		{
			_stopped = false;
			_isPlay = true;
			_ns.resume();
			_ptimer.start();
		}
		
		//public function playV():void
		//{
			//play();
		//}
		
		/**
		 * 暂停
		 **/
		public function pause():void
		{
			_isPlay = false;
			_ns.pause();
			_ptimer.stop();
		}
		
		//public function pauseV():void
		//{
			//pause();
		//}
		
		/**
		 * 停止
		 **/
		public function stop():void
		{
			_isPlay = false;
			_ptimer.stop();
			_ns.pause();
			_ns.seek(0);
		}
		
		public function stopV():void
		{
			stop();
		}
		
		/**
		 * 关闭
		 **/
		public function close():void
		{
			_isPlay = false;
			_isBuffering = false;
			_isPartial = false;
			_bufferComplete = false;
			_partialBytesOffset = 0;
			_partialOffset = 0;
			
			_ns.close();
			_ptimer.stop();
			_btimer.stop();
		}
		
		/**
		 * 拖动
		 * @param t 时间/s
		 **/
		public function seek(t:Number):void
		{
			_ns.seek(t);
		}
		
		public function seekV(t:Number):void
		{
			_ns.seek(t / 1000);
		}
		
		/**
		 * 客户端回调
		 **/
		public function onClientData(data:*):void
		{
			if (data.type == 'metadata')
			{
				//debug metadata信息
				if (false)
				{
					for (var i:Object in data)
					{
						trace(i + ":" + data[i]);
						for (var k:Object in data[i])
						{
							trace(i + "." + k + ":" + data[i][k]);
						}
					}
				}
				
				if (_keyframes == null && data.keyframes != null)
				{
					_keyframes = data.keyframes;
				}
				else if (_keyframes == null && data.seekpoints != null)
				{
					_keyframes = keyframesFromSeekPoints(data.seekpoints);
					_mp4 = true;
				}
				
				dispatchNSEvent(NSEvent.META_DATA, data);
			}
		}
		
		/**
		 * 根据时间得到文件的关键帧位置偏移:bytes
		 * @param pos 时间/s
		 * @return {offset:文件偏移/bytes, time:对应的时间偏移/s}
		 **/
		public function getOffset(pos:Number):Object
		{
			if (!_keyframes)
			{
				return {offset: 0, time: 0};
			}
			for (var i:Number = 0; i < _keyframes.times.length - 1; i++)
			{
				if (_keyframes.times[i] <= pos && _keyframes.times[i + 1] >= pos)
				{
					break;
				}
			}
			return {offset: _keyframes.filepositions[i], time: _keyframes.times[i]};
		}
		
		protected function statusHandler(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case 'NetStream.Unpause.Notify':
					
					break;
				case 'NetStream.Play.Start': 
					_bufferEmpty = true;
					break;
				case 'NetStream.Play.Stop': 
					if (!_stopped)
					{
						_stopped = true;
						dispatchNSEvent(NSEvent.STOP);
					}
					_bufferEmpty = true;
					break;
				case 'NetStream.Buffer.Empty': 
					if (_stopFlag)
					{
						if (!_stopped)
						{
							_stopped = true;
							dispatchNSEvent(NSEvent.STOP);
						}
					}
					_bufferEmpty = true;
					break;
				case 'NetStream.Buffer.Full': 
					_bufferEmpty = false;
					break;
				case 'NetStream.Buffer.Flush': 
					if (!_stopFlag)
					{
						_stopFlag = true;
					}
					break;
				case 'NetStream.Seek.Notify': 
					_stopFlag = false;
					break;
				case 'NetStream.Play.StreamNotFound': 
					/** 重试 **/
					reBuffer();
					trace(_ns.time.toString() + ' : ' + event.info.code + "  视频地址:" + this.url + "没有找到");
					break;
				default: 
				//trace(_ns.time.toString() + ' : ' + event.info.code);
			}
		}
		
		protected function errorHandler(event:ErrorEvent):void
		{
			trace("SimpleNetStreamError:", event.toString());
		}
		
		/**
		 * 发送buffer百分比
		 **/
		protected function emitBufferStatus(event:TimerEvent):void
		{
			var p:Number = (_partialBytesOffset + _ns.bytesLoaded) / (_partialBytesOffset + _ns.bytesTotal);
			dispatchNSEvent(NSEvent.BUFFERING, p);
			/** 缓冲满 **/
			if (_ns.bytesTotal > 0 && _ns.bytesLoaded == _ns.bytesTotal)
			{
				_bufferComplete = true;
				_isBuffering = false;
				_bufferCompleteTime = getTimer();
				
				_btimer.stop();
				dispatchNSEvent(NSEvent.CHECK_FULL);
			}
		}
		
		/**
		 * 发送时间位置
		 **/
		protected function emitPlayStatus(event:TimerEvent):void
		{
			dispatchNSEvent(NSEvent.PLAYING, time);
		}
		
		/**
		 * 派发NSEvent事件
		 **/
		protected function dispatchNSEvent(type:String, info:Object = null):void
		{
			dispatchEvent(new NSEvent(type, info));
		} /** 得到当前标准时间的毫秒数/ms **/
		
		private function getTimer():uint
		{
			var dt:Date = new Date();
			return dt.getTime();
		}
		
		/** 属性 **/
		public function get ns():NetStream
		{
			return _ns;
		}
		
		public function get time():Number
		{
			return _ns.time * 1000 + ((!_isPartial || !_mp4) ? 0 : _partialOffset)
			//if (!_isPartial || !_mp4)
			//return _ns.time * 1000;
			//else
			//return _ns.time * 1000 + _partialOffset;
		}
		
		public function get loaded():Number
		{
			return _ns.bytesLoaded;
		}
		
		public function get loadPercent():Number
		{
			return _ns.bytesLoaded / _ns.bytesTotal;
		}
		
		public function set volume(value:Number):void
		{
			if (_ns)
			{
				var st:SoundTransform = new SoundTransform(value);
				_ns.soundTransform = st;
			}
		}
		
		/** 得到加载的地址 **/
		public function get url():String
		{
			if (!_isPartial)
			{
				return _url;
			}
			else
			{
				var param:int;
				if (_fastSeekByTime)
					param = Math.floor(_partialOffset / 1000);
				else
					param = _partialBytesOffset;
				
				if (_url.lastIndexOf('?') != -1)
					return _url + '&' + _fastSeekParameterName + '=' + param;
				else
					return _url + '?' + _fastSeekParameterName + '=' + param;
			}
		}
		
		/** 在一个序列中的编号 **/
		public function set id(value:uint):void
		{
			_id = value;
		}
		
		public function get id():uint
		{
			return _id;
		}
		
		/** 是否是部分下载 **/
		public function get isPartial():Boolean
		{
			return _isPartial;
		}
		
		public function set isPartial(value:Boolean):void
		{
			_isPartial = value;
		}
		
		/** 初始偏移/ms **/
		public function set partialOffset(value:uint):void
		{
			_partialOffset = value;
		}
		
		public function get partialOffset():uint
		{
			return _partialOffset;
		}
		
		/** 初始偏移/bytes **/
		public function get partialBytesOffset():uint
		{
			return _partialBytesOffset;
		}
		
		public function set partialBytesOffset(value:uint):void
		{
			_partialBytesOffset = value;
		}
		
		/**　是否缓冲完毕 **/
		public function get bufferComplete():Boolean
		{
			return _bufferComplete;
		}
		
		/** 是否具有关键帧信息 **/
		public function get hasKeyframes():Boolean
		{
			return _keyframes != null;
		}
		
		/** 是否在缓冲 **/
		public function get isBuffering():Boolean
		{
			return _isBuffering;
		}
		
		/** 时间偏移数据/该ns之前所有段的总时间长度/ms **/
		public function get timeOffset():uint
		{
			return _timeOffset;
		}
		
		/** 分段视频的切断参数是否是时间 **/
		public function set fastSeekByTime(value:Boolean):void
		{
			if (_fastSeekByTime != value)
			{
				_fastSeekByTime = value;
			}
		}
		
		/** 分段视频的切断参数名称  **/
		public function set fastSeekParameterName(value:String):void
		{
			if (_fastSeekParameterName != value)
			{
				_fastSeekParameterName = value;
			}
		}
		
		/** 缓冲花的时间 **/
		public function get bufferTime():uint
		{
			return _bufferCompleteTime - _bufferStartTime;
		}
		
		/** 视频是否正在播放:缓冲/播放(暂停不影响该效果) **/
		public function get bufferEmpty():Boolean
		{
			return _bufferEmpty;
		}
		
		/**
		 * 转换mp4的seekpoints到flv的keyframes
		 **/
		protected static function keyframesFromSeekPoints(dat:Object):Object
		{
			var kfr:Object = new Object();
			kfr.times = new Array();
			kfr.filepositions = new Array();
			for (var j:String in dat)
			{
				kfr.times[j] = Number(dat[j]['time']);
				kfr.filepositions[j] = Number(dat[j]['offset']);
			}
			return kfr;
		}
		
		/** 查看状态 **/
		override public function toString():String
		{
			var ret:Array = [];
			ret.push('isBuffering:', isBuffering);
			ret.push('bufferComplete:', bufferComplete);
			ret.push('isPartial:', isPartial);
			ret.push('bytesTotal:', _ns.bytesTotal);
			ret.push('bytesLoaded:', _ns.bytesLoaded);
			return '<ns:' + ret.join(' | ') + '>';
		}
	}
}