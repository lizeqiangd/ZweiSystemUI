package com.bilibili.player.net.media
{	
	import com.bilibili.player.components.MukioTaskQueue;
	import com.bilibili.player.manager.AccessConsumerManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	
	/**
	 * 播放列表加载完成
	 */
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * 播放列表加载成功
	 */
	[Event(name="success", type="flash.events.Event")]
	/**
	 * 播放列表加载失败
	 */
	[Event(name="failed", type="flash.events.Event")]
	/**
	 * 当前cid更改
	 */
	[Event(name="cidChanged", type="flash.events.Event")]
	/**
	 * 用于多P连续播放的通讯数据类
	 */
	public class PlayList extends EventDispatcher
	{
		private static var init = 0;
		public static const UNLOAD:uint = init ++;
		public static const LOADING:uint = init ++;
		public static const LOADED:uint = init ++;
		/**
		 * 是否已经加载完成
		 */
		public var loadState:uint = UNLOAD;
		/**
		 * 是否正常加载(加载出错为false,加载成功为true,没有加载为false)
		 */
		private var _success:Boolean = false;
		/**
		 * 播放列表原始数据
		 */
		private var _playListData:Object = null;
		
		/**
		 * 当前播放项目序号,从0开始
		 */
		private var _currentIndex:uint = 0;
		
		/**
		 * 原始参数
		 */
		private var _aid:String;
		
		/**
		 * 原始参数
		 */
		private var _pid:uint;
		/**
		 * 第一次收到的accessConfig
		 */
		private var _accessConfig:AccessConfig;
		/**
		 * 是否锁定
		 * 在进行播放下一P成功或者失败前不允许再有播放下一P的指令
		 */
		private var _locked:Boolean = false;
		/**
		 * 视频aid的分P信息
		 * pid为当前的p号,从1开始
		 */
		/**
		 * 是否已经开始播放下一P:当为autoPlayNextPart默认情况,播放器载入视频后是否要暂停根据此作出判断
		 */
		public var nextPart:Boolean = false;
		public function PlayList()
		{ AccessConsumerManager.addAccessConfigChangeFunction(onAccessConfigUpdate)
			//AccessConsumerManager.regist(this);
		}
		
		private function lock():void
		{
			_locked = true;
		}
		
		public function unlock():void
		{
			_locked = false;
		}
		
		public function get locked():Boolean
		{
			return _locked;
		}
		
		public function onAccessConfigUpdate(/*accessConfig:AccessConfig*/):void
		{
			if(!_accessConfig)
			{
				_accessConfig =  ValueObjectManager.getAccessConfig;
			}
		}
		
		public function get success():Boolean
		{
			return _success;
		}
		
		/**
		 * 播放列表长度
		 */
		public function get length():uint
		{
			if(success && _playListData)
			{
				return _playListData.length;
			}
			else
			{
				return 1;
			}
		}
		/**
		 * 获取播放列表的cid
		 * @param index cid序号,从0开始
		 */
		public function getCid(index:uint):String
		{
			if(success && _playListData && index < length)
			{
				return _playListData[index].cid;
			}
			else
			{
				return null; 
			}
		}
		/**
		 * 获取播放列表信息
		 * @param index 序号,从0开始
		 */
		public function getInfo(index:uint):Object
		{
			if(success && _playListData && index < length)
			{
				return _playListData[index];
			}
			else
			{
				return null; 
			}
		}
		/**
		 * 开始加载分P信息
		 */
		public function load():void
		{
			if(loadState === UNLOAD)
			{
				loadState = LOADING;
				var taskQueue:MukioTaskQueue = new MukioTaskQueue();
				taskQueue.beginLoad(_accessConfig.pageListUrl, _loadComplete);
				taskQueue.work();
			}
		}
		
		private function _loadComplete(data:*):void
		{
			var event:Event;
			loadState = LOADED;
			_success = data ? true : false;
			
			if(data)
			{
				try
				{
					_playListData = MyJSON.decode(data);
					
					/**
					 * 完成接收数据
					 */
					_currentIndex = _accessConfig.partId - 1;
					event = new Event("success");
					dispatchEvent(event);
				}
				catch(e:Error)
				{
					_success = false;
				}
			}
			if(!_success)
			{
				event = new Event('failed');
				dispatchEvent(event);
			}
			event = new Event('complete');
			dispatchEvent(event);
		}
		/**
		 * 当前视频在视频列表中的序号:0开始
		 */		
		public function get currentIndex():uint
		{
			return _currentIndex;
		}
		/**
		 * 当前视频的cid
		 */
		public function get currentCid():String
		{
			return getCid(currentIndex);
		}
		/**
		 * 是否是最后一P(在成功加载前都返回 true)
		 */
		public function get isLastItem():Boolean
		{
			if(!success)
			{
				return true;
			}
			
			return currentIndex + 1 === length;
		}
		/**
		 * 使用js播放下一P(会刷新页面)
		 */
		private function js_play_next(inner:Boolean=false):void
		{
			if(ExternalInterface.available)
			{
				try
				{
					if(!inner)
					{
						ExternalInterface.call("callNextPart");
					}
					else
					{
						ExternalInterface.call("callNextPart", true);
					}
				}
				catch(e:Error)
				{
					
				}
			}
		}
		/**
		 * return 进行切换下返回true,否则返回false(显示评分面板与相关视频列表)
		 */
		public function playNext():Boolean
		{
			if(locked)
			{
				return false;
			}
			
			if(!success)
			{
				return false;
			}
			if(currentIndex === length - 1)
			{
				return false;
			}
			else
			{
				/** 需要外部解锁,防止加载两次 **/
				lock();
				nextPart = true;
				_currentIndex ++;
				dispatchEvent(new Event('cidChanged'));
				js_play_next(true);
				return true;
			}
		}
	}
}