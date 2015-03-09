package com.bilibili.player.manager
{
	import com.bilibili.player.applications.Unitils.NetworkTester.NetworkTesterReporter;
	import com.bilibili.player.core.comments.CommentDisplayer;
	import com.bilibili.player.core.comments.CommentPlayer;
	import com.bilibili.player.core.filter.CommentFilter;
	import com.bilibili.player.core.script.CommentScriptFactory;
	import com.bilibili.player.core.utils.AppRouter;
	import com.bilibili.player.core.utils.EventBus;
	import com.bilibili.player.net.api.PlayerTool;
	import com.bilibili.player.net.comment.CommentProvider;
	import com.bilibili.player.net.comment.CommentServer;
	import com.bilibili.player.net.comment.InstantMessenger;
	import com.bilibili.player.net.media.MediaProvider;
	import com.bilibili.player.system.proxy.PlayerProxy;
	import com.bilibili.player.valueobjects.comment.CommentStyleConfig;
	import com.bilibili.player.valueobjects.comment.CommentStyleData;
	import com.bilibili.player.valueobjects.config.AccessConfig;
	import com.bilibili.player.valueobjects.config.PlayerConfig;
	import com.bilibili.player.valueobjects.log.TimeLogCollector;
	
	/**
	 * 全局实例保存地方
	 * 本类在程序最开始的时候就已经初始化完成.因此可以直接调用.
	 * 同时也请注意不要将需要依赖非官方库的类在这里实例化,
	 * 否则可能编译器错误.
	 * @author Lizeqiangd
	 * 20141113 增加approuter
	 * 20141126 更改成需要的似乎后才实例化
	 * 20141211 几乎所有东西都在这里管理了.
	 * 20140105 重拾项目
	 */
	public class ValueObjectManager
	{
		public static var debug:Boolean = false
		///全局当前发送的弹幕设置.
		private static var _commentStyleData:CommentStyleData
		
		public static function get getCommentStyleData():CommentStyleData
		{
			if (_commentStyleData)
			{
				return _commentStyleData
			}
			trace("ValueObjectManager.init:CommentStyleData")
			_commentStyleData = new CommentStyleData
			return _commentStyleData
		}
		
		///弹幕样式设定参数.
		private static var _commentStyleConfig:CommentStyleConfig
		
		public static function get getCommentStyleConfig():CommentStyleConfig
		{
			if (_commentStyleConfig)
			{
				return _commentStyleConfig
			}
			trace("ValueObjectManager.init:CommentStyleConfig")
			_commentStyleConfig = new CommentStyleConfig
			return _commentStyleConfig
		}
		
		///获取MediaProvider
		private static var _mediaProvider:MediaProvider
		
		public static function get getMediaProvider():MediaProvider
		{
			if (_mediaProvider)
			{
				return _mediaProvider
			}
			trace("ValueObjectManager.init:MediaProvider")
			_mediaProvider = new MediaProvider
			return _mediaProvider
		}
		
		/**
		 * 时间事件log
		 * type格式建议为"player_start"这种下划线全小写
		 */
		private static var _timeLogCollector:TimeLogCollector
		
		public static function get getTimeLogCollector():TimeLogCollector
		{
			if (_timeLogCollector)
			{
				return _timeLogCollector
			}
			trace("ValueObjectManager.init:TimeLogCollector")
			_timeLogCollector = new TimeLogCollector
			return _timeLogCollector
		}
		///系统功能路由
		private static var _appRouter:AppRouter
		
		public static function get getAppRouter():AppRouter
		{
			if (_appRouter)
			{
				return _appRouter
			}
			trace("ValueObjectManager.init:AppRouter")
			_appRouter = new AppRouter()
			return _appRouter
		}
		///播放器全局设定,包括弹幕.
		private static var _playerConfig:PlayerConfig
		
		public static function get getPlayerConfig():PlayerConfig
		{
			if (_playerConfig)
			{
				return _playerConfig
			}
			trace("ValueObjectManager.init:PlayerConfig")
			_playerConfig = new PlayerConfig
			return _playerConfig
		}
		private static var _accessConfig:AccessConfig
		
		public static function get getAccessConfig():AccessConfig
		{
			if (_accessConfig)
			{
				return _accessConfig
			}
			trace("ValueObjectManager.init:AccessConfig")
			_accessConfig = new AccessConfig
			return _accessConfig
		}
		///EventBus
		private static var _eventBus:EventBus
		
		public static function get getEventBus():EventBus
		{
			if (_eventBus)
			{
				return _eventBus
			}
			trace("ValueObjectManager.init:EventBus")
			_eventBus = new EventBus
			return _eventBus
		}
		
		//弹幕显示控制器
		private static var _commentDisplayer:CommentDisplayer
		
		public static function get getCommentDisplayer():CommentDisplayer
		{
			if (_commentDisplayer)
			{
				return _commentDisplayer
			}
			trace("ValueObjectManager.init:CommentDisplayer")
			_commentDisplayer = new CommentDisplayer
			return _commentDisplayer
		}
		
		//播放器代理,用于提供当前播放器状态..这似乎是个临时方案
		private static var _playerProxy:PlayerProxy
		
		public static function get getPlayerProxy():PlayerProxy
		{
			if (_playerProxy)
			{
				return _playerProxy
			}
			trace("ValueObjectManager.init:PlayerProxy")
			_playerProxy = new PlayerProxy;
			return _playerProxy;
		}
		
		/** 初始化脚本弹幕的外部衔接类 **/
		private static var _commentScriptFactory:CommentScriptFactory
		
		public static function get getCommentScriptFactory():CommentScriptFactory
		{
			if (_commentScriptFactory)
			{
				return _commentScriptFactory
			}
			trace("ValueObjectManager.init:CommentScriptFactory")
			_commentScriptFactory = new CommentScriptFactory;
			return _commentScriptFactory;
		}
		
		/** 弹幕提供者 **/
		private static var _commentProvider:CommentProvider
		
		public static function get getCommentProvider():CommentProvider
		{
			if (_commentProvider)
			{
				return _commentProvider
			}
			trace("ValueObjectManager.init:CommentProvider")
			_commentProvider = new CommentProvider;
			return _commentProvider;
		}
		
		/** 弹幕播放引擎 **/
		private static var _commentPlayer:CommentPlayer
		
		public static function get getCommentPlayer():CommentPlayer
		{
			if (_commentPlayer)
			{
				return _commentPlayer
			}
			trace("ValueObjectManager.init:CommentPlayer")
			_commentPlayer = new CommentPlayer;
			return _commentPlayer;
		}
		
		/** 弹幕屏蔽功能 **/
		private static var _commentFilter:CommentFilter
		
		public static function get getCommentFilter():CommentFilter
		{
			if (_commentFilter)
			{
				return _commentFilter
			}
			trace("ValueObjectManager.init:CommentFilter")
			_commentFilter = new CommentFilter;
			return _commentFilter;
		}
		///即时信息通信管理器.
		private static var _instantMessenger:InstantMessenger
		
		public static function get getInstantMessenger():InstantMessenger
		{
			if (_instantMessenger)
			{
				return _instantMessenger
			}
			trace("ValueObjectManager.init:InstantMessenger")
			_instantMessenger = new InstantMessenger
			return _instantMessenger
		}
		
		///弹幕报务器
		private static var _commentServer:CommentServer
		
		public static function get getCommentServer():CommentServer
		{
			if (_commentServer)
			{
				return _commentServer
			}
			trace("ValueObjectManager.init:CommentServer")
			_commentServer = new CommentServer
			return _commentServer
		}
		///播放器小工具
		private static var _playertool:PlayerTool
		
		public static function get getPlayerTool():PlayerTool
		{
			if (_playertool)
			{
				return _playertool
			}
			trace("ValueObjectManager.init:PlayerTool")
			_playertool = new PlayerTool
			return _playertool
		}
		
		//临时:测试网络连通率
		private static var _networkTesterReporter:NetworkTesterReporter
		
		public static function get getNetworkTesterReporter():NetworkTesterReporter
		{
			if (_networkTesterReporter)
			{
				return _networkTesterReporter
			}
			trace("ValueObjectManager.init:NetworkTesterReporter")
			_networkTesterReporter = new NetworkTesterReporter
			return _networkTesterReporter
		}
	}
}