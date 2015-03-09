package com.bilibili.player.valueobjects.config
{
	//import com.bilibili.player.abstract.unit.BaseUi;
	//import com.bilibili.player.core.script.CommentTriggerManager;
	//import com.bilibili.player.core.script.interfaces.ICommentTriggerManager;
	import com.bilibili.player.components.browser.JavaScriptInterfaces;
	import com.bilibili.player.core.script.CommentTriggerManager;
	import com.bilibili.player.core.script.interfaces.ICommentTriggerManager;
	import com.bilibili.player.core.script.interfaces.IScriptConfig;
	import com.bilibili.player.manager.AccessConsumerManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.config.BPTextFormat;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	
//	import tv.bilibili.net.AccessConsumerManager;
	
	/**
	 * 弹幕配置值对象
	 * @author Aristotle9
	 * @editor Lizeqiangd
	 * 本对象会交给ValueObject管理.
	 * 20141107 理解中
	 * 20141112 为什么会是弹幕设置?为什么不是播放器设置.不如改成播放器设置吧.
	 * 20141119 只要导入这个类整个程序就编译都编不过去.这实在是太蛋疼了
	 * 20141127 完全不是那么回事...应该怎么去操作呢..这个类到底是负责什么的呢??
	 * 20141127
	 */
	/** 配置,主要是外观的配置,存储在本地SharedObject中 **/
	public class PlayerConfig extends EventDispatcher implements IScriptConfig/*, IAccessConfigConsumer*/
	{
		/*private static var instance:CommentConfig;*/
		
		/** 是否显示弹幕,没有存储到本地 **/
		public var visible:Boolean=true;
		/** 是否应用到界面字体 **/
		private var _isChangeUIFont:Boolean = BPTextFormat.doesChangeUIFont();
		/** 系统默认的界面字体 **/
		/*CONFIG::flex {
			private var _defaultSystemUIFontFamily:String = getUIFontFamily(); 
		}*/
			/** 是否启用播放器控制API **/
			private var _isPlayerControlApiEnable:Boolean = true;
		/** 是否允许脚本字幕 **/
		private var _scriptEnabled:Boolean = true;
		/** 是否允许调试高级字幕 **/
		private var _debugEnabled:Boolean = false;
		/** 是否使用代码高亮 **/
		private var _codeHighlightEnabled:Boolean = true;
		/*CONFIG::flex {
			[Bindable]
		}*/
			/** 粗体 **/
			public var bold:Boolean = BPTextFormat.useBoldFont;
	/*	CONFIG::flex {
			[Bindable]
		}*/
			/** 透明度:0-1 **/
			public var alpha:Number=1;
		/*CONFIG::flex {
			[Bindable]
		}*/
			/** 滤镜:0-2 **/
			public var filterIndex:int = 0;
		public const filtersArr:Array = [
			{
				label:"重墨"//bilibili默认的样式
				,black:[new GlowFilter(0x000000,0.85,4,4,3,1,false,false)]
				,white:[new GlowFilter(0xffffff,0.90,3,3,4,1,false,false)]
			}
			,{
				label:"描边"//acfun样式
				,black:[new GlowFilter(0x000000,0.70,3,3,2,1,false,false)]
				,white:[new GlowFilter(0xffffff,0.70,3,3,2,1,false,false)]
			}
			,{
				label:"45°投影"//nico样式
				,black:[new DropShadowFilter(1,45,0x000000,.8,2,2,2)]
				,white:[new DropShadowFilter(1,45,0xffffff,.8,2,2,2)]
			}
		];
		private var _font:String=BPTextFormat.getDefaultFont();
		private var _speede:Number = 1.2;
		/*CONFIG::flex {
			[Bindable]
		}*/
			/** 字号缩放因子:0.1-2 **/
			public var sizee:Number = 1;
		/** 是否同步缩放 **/
		private var _syncResize:Boolean = false;
		/** 开启高清与否 **/
		private var _highQualityEnabled:Boolean = false;
		/** 自动更换分P: null默认false不自动播放true自动播放 **/
		private var _autoOpenNextPart:Object = null;
		/** 打开网页时自动缓冲 **/
		private var _autoBuffering:Boolean = true;
		/** 快速跳跃 **/
		private var _fastSeekEnabled:Boolean = true;
		/** 是否记忆宽屏状态 **/
		private var _rememberWideScreenState:Boolean = false;
		/** 是否启用海外加速 **/
		private var _videoAcceleration:Object = null;
		/** 同屏弹幕密度 **/
		private var _density:uint = 80;
		/**
		 * 同屏密度使用时间单位来控制:会比较均匀
		 */
		/*CONFIG::flex {
			[Bindable]
		}*/
			public var densityControl:Boolean = true;
		/** 系统通知相关 **/
		/** 允许系统通知 **/
		/*CONFIG::flex {
			[Bindable]
		}*/
			public var allowSysNotify:Boolean = true;
		/** 允许新番通知 **/
		/*CONFIG::flex {
			[Bindable]
		}*/
			public var allowBNotify:Boolean = true;
		/** 允许无通知知时显示其他消息 **/
		/*CONFIG::flex {
			[Bindable]
		}*/
			public var allowOtherNotify:Boolean = true;
		/** 允许底部留白 **/
		private var _bottomBlank:Boolean = false;
		/** 使用脚本弹幕定义刚刚发送的弹幕的呈现方式 **/
		private var _commentTriggerManager:CommentTriggerManager = new CommentTriggerManager();
		
		/** 标准视频宽度/高度 **/
		private var _width:int = 543;
		/** 标准视频宽度/高度 **/
		private var _height:int = 386;
		/** 全屏输入 **/
		private var _allowsFullScreenInteractive:Object = false;
		
		/** 宽度 **/
		public function get width():int
		{
			return _width;
		}
		/** 高度 **/
		public function get height():int
		{
			return _height;
		}
		
		public function PlayerConfig()
		{
			/*if(instance != null)
			{
				throw new Error("CommentConfig is a singleton");
			}*/
			//测试不靠谱,略去
			//            var han:RegExp = /[一-龥]/;
			reset();
			load();
		AccessConsumerManager.addAccessConfigChangeFunction(onAccessConfigUpdate)
//			AccessConsumerManager.regist(this);
		}
		
		/*public static function getInstance():CommentConfig
		{
			if(instance == null)
			{
				instance = new CommentConfig();
			}
			return instance;
		}*/
		/**
		 * 将配置设置为默认值,允许入一个包含默认配置的字典
		 * @param defaultConfig 默认的配置
		 **/
		public function reset(defaultConfig:Object=null):void
		{
			bold = BPTextFormat.useBoldFont;
			alpha = 1;
			filterIndex = 0;
			speede = 1.2;
			sizee = 1;
			isChangeUIFont = BPTextFormat.doesChangeUIFont();
			font = BPTextFormat.getDefaultFont();
			isPlayerControlApiEnable = true;
			syncResize = false;
			highQualityEnabled = false;
			autoOpenNextPart = null;
			autoBuffering = true;
			fastSeekEnabled = true;
			rememberWideScreenState = false;
			videoAcceleration = null;
			density = 80;
			scriptEnabled = true;
			debugEnabled = false;
			codeHighlightEnabled = true;
			allowsFullScreenInteractive = false;
			
			/** 将默认的配置重设 **/
			if(defaultConfig)
			{
				setValues(defaultConfig);
			}
		}
		/**
		 * 为配置设置一些值
		 * @param config 新的配置
		 */
		public function setValues(config:Object):void
		{
			for(var k:String in config)
			{
				if(this.hasOwnProperty(k))
					try{
						this[k] = config[k];
					}
				catch(e:*)
				{
					trace("ResetConfig Error.");
				}
			}
		}
		
		override public function toString():String
		{
			var a:Object = {
				bold: bold
				,alpha: alpha < 0.05 ? 0.8 : alpha
					,filterIndex: filterIndex
					,speede: speede
					,sizee: sizee
					,font: font
					,isChangeUIFont: isChangeUIFont
					,isPlayerControlApiEnable: isPlayerControlApiEnable
					,syncResize: syncResize
					,highQualityEnabled: highQualityEnabled
					,autoOpenNextPart: autoOpenNextPart
					,autoBuffering: autoBuffering
					,fastSeekEnabled: fastSeekEnabled
					,rememberWideScreenState: rememberWideScreenState
					,videoAcceleration: videoAcceleration
					,density: density
					,scriptEnabled: scriptEnabled
					,debugEnabled: debugEnabled
					,codeHighlightEnabled: codeHighlightEnabled
					,allowSysNotify: allowSysNotify
					,allowBNotify: allowBNotify
					,allowOtherNotify: allowOtherNotify
					,allowsFullScreenInteractive: allowsFullScreenInteractive				
			};
			return JSON.stringify(a);
		}
		
		public function fromString(source:String):void
		{
			try
			{
				var a:Object = JSON.parse(source);
				/** 旧的配置方案,大概在两周后删除 **/
				if(a.hasOwnProperty("0")) 
				{
					bold = a["0"];
				}
				
				if(a.hasOwnProperty("1")) 
				{
					alpha = a["1"];
					if(alpha < 0.05)
					{
						alpha = 0.8;
					}
				}
				
				if(a.hasOwnProperty("2")) 
				{
					filterIndex = a["2"];
				}
				
				if(a.hasOwnProperty("3")) 
				{
					speede = a["3"];
				}
				
				if(a.hasOwnProperty("4")) 
				{
					sizee = a["4"];
				}
				
				if(a.hasOwnProperty("5")) 
				{
					font = a["5"];
				}
				
				if(a.hasOwnProperty("6")) 
				{
					isChangeUIFont = a["6"];
				}
				
				if(a.hasOwnProperty("7")) 
				{
					isPlayerControlApiEnable = a["7"];
				}
				
				if(a.hasOwnProperty("8")) 
				{
					syncResize = a["8"];
				}
				
				if(a.hasOwnProperty("9")) 
				{
					highQualityEnabled = a["9"];
				}
				
				//				if(a.hasOwnProperty("10")) 
				//				{
				//					autoOpenNextPart = a["10"];
				//				}
				
				if(a.hasOwnProperty("11")) 
				{
					autoBuffering = a["11"];
				}
				
				if(a.hasOwnProperty("12")) 
				{
					fastSeekEnabled = a["12"];
				}
				
				if(a.hasOwnProperty("13")) 
				{
					rememberWideScreenState = a["13"];
				}
				
				if(a.hasOwnProperty("14")) 
				{
					videoAcceleration = a["14"];
				}
				
				if(a.hasOwnProperty("15")) 
				{
					density = a["15"];
				}
				
				if(a.hasOwnProperty("16")) 
				{
					scriptEnabled = a["16"];
				}
				
				if(a.hasOwnProperty("17")) 
				{
					debugEnabled = a["17"];
				}
				
				if(a.hasOwnProperty("18")) 
				{
					codeHighlightEnabled = a["18"];
				}
				
				if(a.hasOwnProperty("19")) 
				{
					allowSysNotify = a["19"];
				}
				
				if(a.hasOwnProperty("20")) 
				{
					allowBNotify = a["20"];
				}
				
				if(a.hasOwnProperty("21")) 
				{
					allowOtherNotify = a["21"];
				}
				
				if(a.hasOwnProperty("22")) 
				{
					allowsFullScreenInteractive = a["22"];
				}
				
				/** 新的配置方案 **/
				if(a.hasOwnProperty("bold")) 
				{
					bold = a["bold"];
				}
				
				if(a.hasOwnProperty("alpha")) 
				{
					alpha = a["alpha"];
					if(alpha < 0.05)
					{
						alpha = 0.8;
					}
				}
				
				if(a.hasOwnProperty("filterIndex")) 
				{
					filterIndex = a["filterIndex"];
				}
				
				if(a.hasOwnProperty("speede")) 
				{
					speede = a["speede"];
				}
				
				if(a.hasOwnProperty("sizee")) 
				{
					sizee = a["sizee"];
				}
				
				if(a.hasOwnProperty("font")) 
				{
					font = a["font"];
				}
				
				if(a.hasOwnProperty("isChangeUIFont")) 
				{
					isChangeUIFont = a["isChangeUIFont"];
				}
				
				if(a.hasOwnProperty("isPlayerControlApiEnable")) 
				{
					isPlayerControlApiEnable = a["isPlayerControlApiEnable"];
				}
				
				if(a.hasOwnProperty("syncResize")) 
				{
					syncResize = a["syncResize"];
				}
				
				if(a.hasOwnProperty("highQualityEnabled")) 
				{
					highQualityEnabled = a["highQualityEnabled"];
				}
				
				if(a.hasOwnProperty("autoOpenNextPart")) 
				{
					autoOpenNextPart = a["autoOpenNextPart"];
				}
				
				if(a.hasOwnProperty("autoBuffering")) 
				{
					autoBuffering = a["autoBuffering"];
				}
				
				if(a.hasOwnProperty("fastSeekEnabled")) 
				{
					fastSeekEnabled = a["fastSeekEnabled"];
				}
				
				if(a.hasOwnProperty("rememberWideScreenState")) 
				{
					rememberWideScreenState = a["rememberWideScreenState"];
				}
				
				if(a.hasOwnProperty("videoAcceleration")) 
				{
					videoAcceleration = a["videoAcceleration"];
				}
				
				if(a.hasOwnProperty("density")) 
				{
					density = a["density"];
				}
				
				if(a.hasOwnProperty("scriptEnabled")) 
				{
					scriptEnabled = a["scriptEnabled"];
				}
				
				if(a.hasOwnProperty("debugEnabled")) 
				{
					debugEnabled = a["debugEnabled"];
				}
				
				if(a.hasOwnProperty("codeHighlightEnabled")) 
				{
					codeHighlightEnabled = a["codeHighlightEnabled"];
				}
				
				if(a.hasOwnProperty("allowSysNotify")) 
				{
					allowSysNotify = a["allowSysNotify"];
				}
				
				if(a.hasOwnProperty("allowBNotify")) 
				{
					allowBNotify = a["allowBNotify"];
				}
				
				if(a.hasOwnProperty("allowOtherNotify")) 
				{
					allowOtherNotify = a["allowOtherNotify"];
				}
				
				if(a.hasOwnProperty("allowsFullScreenInteractive")) 
				{
					allowsFullScreenInteractive = a["allowsFullScreenInteractive"];
				}
			}
			catch(e:Error){}
			if(speede <= 0)
			{
				speede = 0.1;
			}
			if(sizee <= 0)
			{
				sizee = 0.1;
			}
		}
		
		public function load():void
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(BPSetting.SharedObjectName,'/');
				var str:String = so.data['CommentConfig'];
				if(str)
				{
					fromString(str);
				}
			}
			catch(e:Error)
			{
				loadByWebStorage();
			}
		}
		
		private function loadByWebStorage():void
		{
			try
			{
				var str:String = JavaScriptInterfaces.loadByWebStorage('flash-player.CommentConfig') as String;
				if(str)
				{
					fromString(str);
				}
			}
			catch(e:Error)
			{
			}
		}
		
		public function save():void
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(BPSetting.SharedObjectName,'/');
				so.data['CommentConfig'] = toString();
				so.flush();
			}
			catch(e:Error)
			{
				JavaScriptInterfaces.saveByWebStorage('flash-player.CommentConfig', toString());
			}
		}
		
		/** 当前配置的滤镜:可以直接应用于显示对象 **/
		public function get filter():Array
		{
			return filtersArr[filterIndex].black;
		}
		/** 获得合适的滤镜 **/
		public function getFilterByColor(color:uint):Array
		{
			return filtersArr[filterIndex][color != 0 ? 'black' : 'white'];
		}
		/*CONFIG::flex {
			[Bindable('isChangeUIFontChange')]
		}*/
			/** 是否让界面使用弹幕字体?,在非中文系统中可以解决
			 * Spark组件不能显示汉字的问题 **/
			public function get isChangeUIFont():Boolean
			{
				return _isChangeUIFont;
			}
			
			/**
			 * @private
			 */
			public function set isChangeUIFont(value:Boolean):void
			{
				if(_isChangeUIFont == value)
					return;
				
				_isChangeUIFont = value;
				dispatchEvent(new Event('isChangeUIFontChange'));
				
				CONFIG::flex {
					if(isChangeUIFont)
					{
						setUIFontFamily(font);
					}
					else
					{
						setUIFontFamily(_defaultSystemUIFontFamily);	
					}
				}
			}
			
			/*CONFIG::flex {
				[Bindable('fontChange')]
			}*/
			public function get font():String
			{
				return _font;
			}
			
			public function set font(value:String):void
			{
				_font = value;
				dispatchEvent(new Event('fontChange'));
				
				CONFIG::flex {
					if(isChangeUIFont)
					{
						setUIFontFamily(font);
					}
				}
			}
			
			/*CONFIG::flex {
				[Bindable("playerControlApiEnableChange")]
			}*/
			/** 是否启用播放器控制API **/
			public function get isPlayerControlApiEnable():Boolean
			{
				return _isPlayerControlApiEnable;
			}
			
			/**
			 * @private
			 */
			public function set isPlayerControlApiEnable(value:Boolean):void
			{
				_isPlayerControlApiEnable = value;
				dispatchEvent(new Event('playerControlApiEnableChange'));
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 字幕是否同视频缩放:
			 * true 是
			 * false 否
			 * 默认否
			 **/
			public function get syncResize():Boolean
			{
				return _syncResize;
			}
			
			/**
			 * @private
			 */
			public function set syncResize(value:Boolean):void
			{
				if(_syncResize != value)
				{
					_syncResize = value;
					//				save();//不在setter中设置保存,因为有些setter不能保存
					//实例化先后顺序对本次调用有影响,会出错,暂时无法解决,不过不调用对实际程序并无影响
					//				CommentView.getInstance().resize(0, 0);
				}
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 开启高清与否 **/
			public function get highQualityEnabled():Boolean
			{
				return _highQualityEnabled;
			}
			
			/**
			 * @private
			 */
			public function set highQualityEnabled(value:Boolean):void
			{
				_highQualityEnabled = value;
			}
			
		/*	CONFIG::flex {
				[Bindable]
			}*/
			/** 自动更换分P **/
			public function get autoOpenNextPart():Object
			{
				return _autoOpenNextPart;
			}
			
			/**
			 * @private
			 */
			public function set autoOpenNextPart(value:Object):void
			{
				_autoOpenNextPart = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 打开网页时自动缓冲 **/
			public function get autoBuffering():Boolean
			{
				return _autoBuffering;
			}
			
			/**
			 * @private
			 */
			public function set autoBuffering(value:Boolean):void
			{
				_autoBuffering = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 快速跳跃 **/
			public function get fastSeekEnabled():Boolean
			{
				return _fastSeekEnabled;
			}
			
			/**
			 * @private
			 */
			public function set fastSeekEnabled(value:Boolean):void
			{
				_fastSeekEnabled = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 是否记忆宽屏状态 **/
			public function get rememberWideScreenState():Boolean
			{
				return _rememberWideScreenState;	
			}
			
			public function set rememberWideScreenState(value:Boolean):void
			{
				_rememberWideScreenState = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 是否启用海外加速 **/
			public function get videoAcceleration():Object
			{
				return _videoAcceleration;
			}
			
			/**
			 * @private
			 */
			public function set videoAcceleration(value:Object):void
			{
				_videoAcceleration = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 同屏弹幕密度 **/
			public function get density():uint
			{
				return _density;
			}
			
			/**
			 * @private
			 */
			public function set density(value:uint):void
			{
				_density = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 是否允许脚本字幕 **/
			public function get scriptEnabled():Boolean
			{
				return _scriptEnabled;
			}
			
			/**
			 * @private
			 */
			public function set scriptEnabled(value:Boolean):void
			{
				_scriptEnabled = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 是否允许调试高级字幕 **/
			public function get debugEnabled():Boolean
			{
				return _debugEnabled;
			}
			
			/**
			 * @private
			 */
			public function set debugEnabled(value:Boolean):void
			{
				_debugEnabled = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 是否使用代码高亮 **/
			public function get codeHighlightEnabled():Boolean
			{
				return _codeHighlightEnabled;
			}
			
			/**
			 * @private
			 */
			public function set codeHighlightEnabled(value:Boolean):void
			{
				_codeHighlightEnabled = value;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 允许底部留白 **/
			public function get bottomBlank():Boolean
			{
				return _bottomBlank;
			}
			
			/**
			 * @private
			 */
			public function set bottomBlank(value:Boolean):void
			{
				if(_bottomBlank != value)
				{
					_bottomBlank = value;
					ValueObjectManager.getCommentPlayer.resize(0, 0);
				}
			}
			
			/** 使用脚本弹幕定义刚刚发送的弹幕的呈现方式 **/
			public function get commentTriggerManager():ICommentTriggerManager
			{
				return _commentTriggerManager;
			}
			
			/** 获取弹幕列表 **/
			public function get commentList():Array
			{
				return ValueObjectManager.getCommentPlayer.provider.commentResource;
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/**
			 * 全屏输入模式:null 系统不允许，false 不使用 true 使用
			 */
			public function get allowsFullScreenInteractive():Object
			{
				return _allowsFullScreenInteractive;
			}
			
			/**
			 * @private
			 */
			public function set allowsFullScreenInteractive(value:Object):void
			{
				var arr:Array = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/.exec(Capabilities.version);
				var m:Number = Number(arr[2]);
				var n:Number = Number(arr[3]);
				if( m > 11 || (m == 11 && n >= 3))//11.3以后的版本支持全屏交互模式
				{
					_allowsFullScreenInteractive = Boolean(value);
				}
				else
				{
					_allowsFullScreenInteractive = null;
				}
			}
			
			/*CONFIG::flex {
				[Bindable]
			}*/
			/** 速度因子:0.1-2 **/
			public function get speede():Number
			{
				return _speede;
			}
			
			/**
			 * @private
			 */
			public function set speede(value:Number):void
			{
				_speede = value;
			}
			
			public function onAccessConfigUpdate(/*accessConfig:AccessConfig*/):void
			{
				/** 通用权限配置文件强制设置不挡弹幕选项,该选项只有重新载入播放器后才能去除! **/
				if(AccessConsumerManager.getAccessConfig.bottomBlank)
					bottomBlank = true;
			}
			
//		CONFIG::flex {
//				/**
//				 * 辅助方法,设置系统界面字体
//				 **/
//				private static function setUIFontFamily(name:String):String
//				{
//					var oldFontName:String;
//					var manager2:IStyleManager2 = StyleManager['getStyleManager'](null);
//					var globalStyle:CSSStyleDeclaration = manager2.getStyleDeclaration('global');
//					oldFontName = globalStyle.getStyle('fontFamily');
//					globalStyle.setStyle('fontFamily', name);
//					manager2.setStyleDeclaration("global", globalStyle, true);
//					return oldFontName;
//				}
//				/** 得到系统界面字体名称 **/
//				private static function getUIFontFamily():String
//				{
//					return 'Hei';
//				}
//			}
	}

}