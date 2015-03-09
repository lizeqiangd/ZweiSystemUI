package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.ICommentScriptFactory;
	import com.bilibili.player.core.script.interfaces.IExternalScriptLibrary;
	import com.bilibili.player.core.script.interfaces.IGlobal;
	import com.bilibili.player.core.script.interfaces.IScriptConfig;
	import com.bilibili.player.core.script.interfaces.IScriptDisplay;
	import com.bilibili.player.core.script.interfaces.IScriptManager;
	import com.bilibili.player.core.script.interfaces.IScriptPlayer;
	import com.bilibili.player.core.script.interfaces.IScriptUtils;
	import com.bilibili.player.manager.AccessConsumerManager;
	import com.bilibili.player.system.namespaces.bilibili;
	import com.bilibili.player.manager.ValueObjectManager
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	import org.libspark.betweenas3.BetweenAS3;
	
	import scripting.Parser;
	import scripting.Scanner;
	import scripting.VirtualMachine;

//	import scripting.Parser;
//	import scripting.Scanner;
//	import scripting.VirtualMachine;
//	
//	import org.lala.event.EventBus;
//	import tv.bilibili.net.AccessConfig;
//	import tv.bilibili.net.AccessConsumerManager;
//	import tv.bilibili.net.IAccessConfigConsumer;
//	import tv.bilibili.script.interfaces.ICommentScriptFactory;
//	import tv.bilibili.script.interfaces.IExternalScriptLibrary;
//	import tv.bilibili.script.interfaces.IGlobal;
//	import tv.bilibili.script.interfaces.IScriptConfig;
//	import tv.bilibili.script.interfaces.IScriptDisplay;
//	import tv.bilibili.script.interfaces.IScriptManager;
//	import tv.bilibili.script.interfaces.IScriptPlayer;
//	import tv.bilibili.script.interfaces.IScriptUtils;

	public final class CommentScriptFactory implements ICommentScriptFactory/*, IAccessConfigConsumer*/
	{
		protected static var _instance:CommentScriptFactory;
		
		protected var _display:IScriptDisplay;
		protected var _player:IScriptPlayer;
		protected var _utils:IScriptUtils;
		protected var _global:IGlobal;
		protected var _scriptManager:IScriptManager;
		/** 共享的全局变量 **/
		protected var globals:Object;
		/** 脚本弹幕配置 **/
		protected var config:IScriptConfig;
		
		/** 已经加载的类 **/
		public var _$loaderData:Array = [];
		/** 已经加载的库名称 **/
		public var _$loaderList:Array = [];
		
		/** 视频播放器 **/
		/*public var _jwplayer:IPlayer;*/
		
		/** 视频cid **/
		bilibili var cid:String;
		/** 弹幕图层 **/
		bilibili var clip:DisplayObjectContainer;
		/**
		 * 已经内置的外部库
		 */
		private const innerLibs:Array = [];
		
		//public static function getInstance():CommentScriptFactory
		//{
			//if(_instance == null)
			//{
				//_instance = new CommentScriptFactory();
			//}
			//return _instance;
		//}
		
		public function CommentScriptFactory()
		{
			AccessConsumerManager.addAccessConfigChangeFunction(onAccessConfigUpdate)
			onAccessConfigUpdate()
		}
		/** 初始化脚本相关的服务器量 **/
		public function onAccessConfigUpdate(/*accessConfig:AccessConfig*/):void
		{
			bilibili::cid = AccessConsumerManager.getAccessConfig.cid;
		}

		/**
		 * 初始化脚本运行器
		 * @param player jwplayer播放器实例
		 * @param scriptCanvas 脚本内容所在的层
		 * @param scriptConfig 脚本弹幕的配置
		 **/
		public function initial(/*player:IPlayer,*/ scriptCanvas:DisplayObjectContainer, scriptConfig:IScriptConfig):void
		{
			bilibili::clip = scriptCanvas;
			config = scriptConfig;
			/*_jwplayer = player;*/
			
			_scriptManager = new ScriptManager(/*player*/);
			(_scriptManager as ScriptManager).bilibili::factory = this;
			_player = new ScriptPlayer(/*player,*/ scriptConfig);
			_display = new ScriptDisplay(/*player,*/ scriptCanvas, _scriptManager as ScriptManager);
			_utils = new ScriptUtils(_scriptManager as ScriptManager);
			_global = new GlobalVariables;
			
			globals = {
				trace: tracex
				,clear: clear
//				/** as3内部变量 **/
				,getTimer: flash.utils.getTimer
				//,clearInterval: flash.utils.clearInterval
				,clearTimeout: flash.utils.clearTimeout
				,parseInt: parseInt
				,parseFloat: parseFloat
				,Math: Math
				,String: String
//				/** 常用函数 **/
				,interval: _utils.interval
				,timer: _utils.delay
				,clone: _utils.clone
				,foreach: _utils.foreach
				,Utils: _utils
//				/** 弹幕api **/
				,Player: _player
				,Display: _display
				,'$': _display
				,Global: _global
				,'$G': _global
				,ScriptManager: _scriptManager
				,Tween: BetweenAS3
				,TweenEasing: BetweenAS3TweenEasing
			};
			
			//外部库换成内置
			var scriptBitmap:Object = new ScriptBitmap(globals, (_display as ScriptDisplay).root, _scriptManager);
			globals.Bitmap = scriptBitmap;
			innerLibs.push('libBitmap');
		}

		public function exec(script:String, debugInfo:Boolean=true):void
		{
			//trace("高级弹幕解析开始")
			if(!config.scriptEnabled)
				return;
				
			var vm:VirtualMachine = new VirtualMachine();
			installGlobals(vm);
			vm.getGlobalObject().load = function load(libName:String, callback:Function):void
			{
				//已经内置的外部库
				if(innerLibs.indexOf(libName) !== -1) {
					callback();
					return;
				}
				if (_$loaderList.indexOf(libName)!=-1){
					callback();
					return;
				}
				_$loaderList.push(libName);
				importExtendLibrary(vm, libName, callback);
			};
			/** 已经加载的外部库 **/
			for each(var getClass:Class in _$loaderData)
			{
				var childObj:IExternalScriptLibrary = new getClass() as IExternalScriptLibrary;
				tracex("importExtendLibrary : create object..." + childObj.initVM(vm.getGlobalObject(), (_display as ScriptDisplay).root, _scriptManager));
			}
			
			if(debugInfo)
			{
				var startTime:int = getTimer();
				tracex("=====================================");
			}
			
			/** tokens **/
			var s:Scanner = new Scanner(script);
			/** bytecode **/
			var p:Parser = new Parser(s);
			vm.rewind();
			vm.setByteCode(p.parse(vm));
			var ret:Boolean = vm.execute();
			
			if(debugInfo)
			{
				var costTime:int = getTimer() - startTime;
				tracex("Execute in " + costTime + "ms");
			}
		}
		/**
		 * 填充脚本运行时的全局变量
		 **/
		protected function installGlobals(vm:VirtualMachine):void
		{
			var g:Object = vm.getGlobalObject();
			for(var k:String in globals)
			{
				g[k] = globals[k];
			}
		}
		/** 脚本相关零散的运行时函数 **/
		/**
		 * 打印
		 **/
		protected function tracex(...args):void
		{
			ValueObjectManager.getEventBus.log(args.join(' '));
		}
		/**
		 * 清除消息窗口
		 **/
		protected function clear():void
		{
			ValueObjectManager.getEventBus.clear();
		}
		/** 加载外部swf库(因有参数传递到外部的类,除了globalObject,不能确定对第一个参数的依赖性) **/
		private function importExtendLibrary(vm:*,lib:String,callback:Function):void
		{
			tracex("importExtendLibrary : " + lib);
			var loader:Loader = new Loader();
			var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			var ldrContext:LoaderContext = new LoaderContext(false, domain);
			tracex("importExtendLibrary : " + lib + " Downloading...");
			
//			Security.allowInsecureDomain('static.hdslb.com');
			if(bilibili::clip.loaderInfo.loaderURL.indexOf('https://') === 0)
			{
				var url:URLRequest = new URLRequest("https://static-s.bilibili.com/playerLibrary/" + lib + "_2.swf");
			}
			else
			{
				url = new URLRequest("http://static.hdslb.com/playerLibrary/" + lib + "_2.swf");
			}
//			var url:URLRequest = new URLRequest("http://10.0.2.2:8088/playerLibrary/" + lib + "_2.swf");
//			var url:URLRequest = new URLRequest(lib + ".swf");
			var completeHandler:Function=function(event:Event=null):void {
				try
				{
					tracex("importExtendLibrary : " + lib + " Initalizing...");
					var getClass:Class = getDefinitionByName(lib) as Class;
					_$loaderData.push(getClass);
					var childObj:IExternalScriptLibrary = new getClass() as IExternalScriptLibrary;
					tracex("importExtendLibrary : " + lib + " create object..." + childObj.initVM(vm.getGlobalObject(), (_display as ScriptDisplay).root, _scriptManager));
					tracex("importExtendLibrary : " + lib + " done");
					callback();
				}
				catch(e:Error)
				{
					tracex('importExtendLibrary : err ' + e.toString());
				}
			};
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			loader.load(url, ldrContext);
		}
		/** 加载错误时打印错误信息 **/
		private function loadErrorHandler(event:Event):void
		{
			tracex("extendLibraryLoadingError:" + event.toString());
		}
		
		/** 以下是 **/
		/** 保持兼容性的接口 **/
		public function trace(...args):void
		{
			tracex.apply(this, args);
		}
		/*public function get player():IPlayer
		{
			return _jwplayer;
		}*/
		public function get splayer():IScriptPlayer
		{
			return _player;
		}
		public function get _$ScriptManager():IScriptManager
		{
			return _scriptManager;
		}
		public function get cm():Object
		{
			return null;
		}
		public function get onPlay():Function
		{
			return function():void{};
		}
		
	}
}