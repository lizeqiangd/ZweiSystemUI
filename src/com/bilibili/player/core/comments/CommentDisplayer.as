package com.bilibili.player.core.comments
{
	//import com.longtailvideo.jwplayer.events.MediaEvent;
	//import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	//import com.longtailvideo.jwplayer.events.PlaylistEvent;
	//import com.longtailvideo.jwplayer.player.IPlayer;
	//import com.longtailvideo.jwplayer.player.Player;
	//import com.longtailvideo.jwplayer.plugins.IPlugin;
	//import com.longtailvideo.jwplayer.plugins.PluginConfig;
	//import com.longtailvideo.jwplayer.view.components.ControlbarComponentV4;
	//import com.longtailvideo.jwplayer.view.components.DisplayComponent;
	
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.bilibili.player.core.script.NoParentSprite;
	import com.bilibili.player.events.MediaEvent;
	import com.bilibili.player.events.MukioEvent;
	import com.bilibili.player.events.PlayerStateEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.net.comment.CommentProvider;
	import com.bilibili.player.valueobjects.config.PlayerConfig;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	//import org.lala.comments.BiliBiliScriptCommentManager;
	//import org.lala.comments.BottomCommentManager;
	//import org.lala.comments.CommentManager;
	//import org.lala.comments.FixedPosCommentManager;
	//import org.lala.comments.IComment;
	//import org.lala.comments.RScrollCommentManager;
	//import org.lala.comments.ScrollCommentManager;
	//import org.lala.components.NoParentSprite;
	//import org.lala.event.EventBus;
	//import org.lala.event.MukioEvent;
	//import com.bilibili.player.net.comment.CommentProvider;
	//import org.lala.utils.CommentConfig;
	//
	//import tv.bilibili.net.Services;
	//import tv.bilibili.script.CommentScriptFactory;
	
	/**
	 * 纯JWPlayer v5.x的弹幕播放插件:
	 * 只实现弹幕的加载与播放,无发送界面与功能,无过滤器设置界面与功能
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141107 开始着手删减功能.和理解功能
	 * 20141117 准备开始调试
	 * 20141125 调试完成后继续处理
	 * 20141126 现实载体移交到外部.这边这只负责接入.构造函数无用化.使其可以进入ValueObjectManager
	 * 20141127我觉得呢...CommentProvider就交给ValueObjectManger去吧....
	 * 20141210
	 **/
	
	/** 内全屏按下 **/
	//[Event(name='innerFullScreen',type='flash.events.Event')]
	/**
	 * 弹幕右键点击
	 * event.data:弹幕数据
	 **/
	//[Event(name="commentMenuClicked",type="org.lala.event.MukioEvent")]
	
	public class CommentDisplayer extends BaseUI // implements IPlugin
	{
		/** 插件配置,用于从外部传参数给本插件 **/
		//private var config:PluginConfig;
		/** 对JWP的引用 **/
		//private var player:IPlayer;
		
		/** 弹幕来源,只有唯一一个实例 **/
		//private var _provider:CommentProvider;
		/** 弹幕管理者 **/
		private var managers:Vector.<CommentManager>;
		/**
		   JWP(layer)是可以将列表作为播放对象的,如果只将一个cid参数传给播放器实为不妥
		   (相当于一个列表中的所有视频都使用该弹幕),因此最好从播放的item事件中提取cid.
		   本着对JWP最小修改的原则,不再将cid属性hack到播放的item中,
		   考虑到JWP使用file,type两个参数定义视频来源.因此用type=sina&file={vid}这种写法来取代
		   vid={vid},并且cid就是该vid.因此也不能在播放器外部直接配置cid(JWP没有cid参数,不打算更改)
		   ,只要有较短的file(vid)都能直接转化为cid.
		
		 **/
		
		/** 弹幕层,类本身是插件层,但是位置不符合弹幕的需求,所以另起一层 **/
		private var _clip:Sprite;
		/** 脚本弹幕层:为了让脚本弹幕能够捕获用户点击事件 **/
		private var _scriptClip:Sprite;
		
		/** 不使用遮罩可以提高效率 **/
//        private var clipMask:Sprite;
		/** singleton **/
		//private static var instance:CommentDisplayer;
		
		/** 时间点 **/
		private var _stime:Number = 0;
		/** 普通弹幕配置 **/
		private var cmtConfig:PlayerConfig = ValueObjectManager.getPlayerConfig
		/** 复制右键 **/
		//private var copyMenuItem:ContextMenuItem;
		/** 关于右键 **/
		//private var aboutMenuItem:ContextMenuItem;
		/** 截图分享 **/
		//private var shareImageItem:ContextMenuItem;
		/** 播放器右键 **/
		private var menuArr:Array = [];
		/** 是否开启右键功能 **/
		public var danmuContextMenuEnabled:Boolean = true;
		/** 插件的版本号,非JW播放器 **/
		private var _version:String;
		/** 简化的视频的播放器态,播放或静止 **/
		private var _isPlaying:Boolean = false;
		
		//public function CommentDisplayer()
		//{
		//if(instance != null)
		//{
		//throw new Error("class CommentView is a Singleton,please use getInstance()");
		//}
		/** 不接收点击事件 **/
		//this.mouseEnabled = this.mouseChildren = false;
		//_clip = new Sprite();
		//_clip.name = 'CommentLayer';
		//_clip.useHandCursor = true;
		//_clip.buttonMode = true;
		///** 本身不接收点击事件,但是子集可能会接收 **/
		//_clip.mouseEnabled = false;
		//
		//_scriptClip = new NoParentSprite;
		//_scriptClip.name = 'ScriptCommentLayer' // 'scriptCommentCanvas';
		//_scriptClip.mouseEnabled = false; //子级可以接收事件.
//            clipMask = new Sprite();
//            clipMask.name = 'commentviewmasklayer';
		//init();
		//}
		
		/**
		 * 自身的初始化
		 **/
		public function init(commentLayer:Sprite, scriptCommentLayer:NoParentSprite):void
		{ /** 不接收点击事件 **/
			trace("CommentDisplayer.init")
			this.mouseEnabled = this.mouseChildren = false;
			
			_clip = commentLayer
			_clip.name = 'CommentLayer';
			_clip.useHandCursor = true;
			_clip.buttonMode = true;
			
			_scriptClip = scriptCommentLayer
			_scriptClip.name = 'ScriptCommentLayer' // 'scriptCommentCanvas';
			_scriptClip.mouseEnabled = false; //子级可以接收事件.
			
			//this._provider = ValueObjectManager.getCommentProvider
			managers = new Vector.<CommentManager>();
			addManagers();
			
			initPlugin()
		}
		
		/** 单件 **/
		//public static function getInstance():CommentDisplayer
		//{
		//if (instance == null)
		//{
		//instance = new CommentDisplayer();
		//}
		//return instance;
		//}
		
		/** 接口方法:初始化插件,这时插件层已经添加到播放器的plugins层上,为最表层 **/
		public function initPlugin( /*ply:IPlayer, conf:PluginConfig*/):void
		{
			//player = ply;
			//config = conf;
			//new playlist
			//ValueObjectManager.getMediaProvider.addEventListener(PlaylistEvent.PLAYLIST_ITEM,itemHandler);
			ValueObjectManager.getMediaProvider.addEventListener(MediaEvent.MEDIA_TIME,timeHandler);
			ValueObjectManager.getMediaProvider.addEventListener(PlayerStateEvent.PLAYER_STATE,stateHandler);
			ValueObjectManager.getMediaProvider.addEventListener(MediaEvent.MEDIA_SEEK, seekHandler);
			/**
			 * 把层放置在紧随masked之后
			 * 从View.setupLayers函数可以看到JWP的层次结构,Plugin在最表层
			 **/
			//var _p:DisplayObjectContainer = this.parent;
			//var _root:DisplayObjectContainer = _p.parent;
//            var _masked:DisplayObject = _root.getChildByName('masked');
			//var _components:DisplayObject = _root.getChildByName('components');
			/** 插入弹幕层,注意位置 **/
//            _root.addChildAt(clipMask,_root.getChildIndex(_masked) + 1);
//            _root.addChildAt(_clip,_root.getChildIndex(_masked) + 1);
			/** View.setupComponents()中有_components层次结构 **/
			//(_components as DisplayObjectContainer).addChildAt(_clip, 1);
//            clip.mask = clipMask;
			
			setupUI();
			//setUpRightClick(MovieClip(_root));
			
			/** 设置播放状态的初值 **/
			_isPlaying = false
			//_isPlaying = player.config.autostart;
			
			/** 初始化脚本弹幕的外部衔接类 **/
			//CommentScriptFactory.getInstance().initial(player, _clip, cmtConfig);
			ValueObjectManager.getCommentScriptFactory.initial(_scriptClip, cmtConfig)
			/** 过滤器变动,更新已经实例化的Comment **/
			ValueObjectManager.getEventBus.addEventListener("commentFilterChange", commentFilterChangeHandler);
//			EventBus.getInstance().addEventListener("commentFilterChange", commentFilterChangeHandler);
		}
		
		/** 右键 **/
		private function setUpRightClick(_root:MovieClip):void
		{
			//已经确定播放器的右键在root上
			//copyMenuItem = new ContextMenuItem("--点击以上菜单使用相关功能菜单--", true, false);
			//aboutMenuItem = new ContextMenuItem("关于 MukioPlayer v" + _version + '...');
			//aboutMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, aboutHandler);
			/** 保存下root右键中已经存在的项,以便在重新设置时加上 **/
			//shareImageItem = new ContextMenuItem("将画面分享到微博...");
			//shareImageItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, shareImageHandler);
//			menuArr.push(shareImageItem);
//            menuArr.unshift(aboutMenuItem);
			for each (var mni:ContextMenuItem in _root.contextMenu.customItems)
			{
				mni.separatorBefore = false;
				menuArr.unshift(mni);
			}
			_root.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, createCopyCommentMenus);
		}
		
		/** 关于 **/
		protected function aboutHandler(evt:ContextMenuEvent):void
		{
			navigateToURL(new URLRequest('http://code.google.com/p/mukioplayer/'), '_blank');
		}
		
		/** 截图 **/
		protected function shareImageHandler(event:ContextMenuEvent):void
		{
			try
			{
				var img:BitmapData = new BitmapData(1, 1 /*player.controls.display.width, player.controls.display.height, true, 0x00000000*/);
				var m:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
				img.draw(this.clip, m);
//				img.draw(DisplayObject(player).parent.parent.parent, m);
//				img.draw(stage, m);
//				Services.sendDanmuImage(img, stime);
			}
			catch (e:Error)
			{
				ValueObjectManager.getEventBus.log(e.toString());
			}
		}
		
		/** 点击右键后,开始生成菜单 **/
		private function createCopyCommentMenus(event:ContextMenuEvent):void
		{
			/** 关闭右键功能 **/
			//if (!danmuContextMenuEnabled)
			//{
				//return;
			//}
			//var p:Point = new Point(_clip.stage.mouseX, _clip.stage.mouseY);
			//var menus:Array = [];
			//var i:int;
			//for (i = 0; i < _clip.numChildren; i++)
			//{
				//var c:DisplayObject = _clip.getChildAt(i);
				//if (c is IComment)
				//{
					//if (c.hitTestPoint(p.x, p.y))
					//{
						//menus.push(createMenu(IComment(c), p));
					//}
				//}
			//}
			//var mn:ContextMenu = event.target as ContextMenu;
			//mn.customItems = [];
			//if (menus.length != 0)
			//{
				//while (menus.length)
				//{
					//mn.customItems.push(menus.pop());
				//}
				///** 分隔菜单 **/
				//mn.customItems.push(copyMenuItem);
			//}
			///** 加上之前创建的右键的项 **/
			//for (i = 0; i < menuArr.length; i++)
			//{
				//mn.customItems.push(menuArr[i]);
			//}
		}
		
		/** 生成一个可以复制内容的菜单项
		 * @param c 弹幕展示
		 * @param point 触发点(点击右键菜单后不能正确获得位置)
		 *  **/
		private function createMenu(c:IComment, point:Point):ContextMenuItem
		{
			var mni:ContextMenuItem = new ContextMenuItem('>> ' + c.data.text.substr(0, 20) + (c.data.text.length > 20 ? '...' : ''));
			mni.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(event:ContextMenuEvent):void
				{
//                System.setClipboard(c.data.text);
					/** 预览弹幕没有内部id **/
					if (c.data.preview)
					{
						dispatchEvent(new MukioEvent('commentMenuClicked', {item: null, point: point}));
						return;
					}
					/** c.data 是一个弹幕数据副本,从主存储列表中查找出原始数据 **/
					for each (var item:Object in ValueObjectManager.getCommentProvider.commentResource)
					{
						if (item.id === c.data.id)
						{
							dispatchEvent(new MukioEvent('commentMenuClicked', {item: item, point: point}));
							return;
						}
					}
					dispatchEvent(new MukioEvent('commentMenuClicked', {item: null, point: point}));
				});
			return mni;
		}
		
		/** 添加按钮等等 **/
		private function setupUI():void
		{
		/** 直接使用flash版皮肤的自定义接口 **/
			//var cb:ControlbarComponentV4 = player.controls.controlbar as ControlbarComponentV4;
			//cb.addNativeButtonPairHandle('wide', innerFullScreenButtonHandler);
			////innerfullscreenbutton,在ZIP皮肤中文本替换会有误差,布局是由文本控制的这一点不太好,fullscreen一替换谅出问题,取另外名字
			//
			//cb.addNativeButtonPairHandle('loop', loopButtonHandler);
			///** 在单文件循环下点亮图标  **/
			//cb.setNativeButtonState('loop', player.config.repeat == 'single');
			////使用ZIP皮肤时必须在装好按钮后设置
			//
			//cb.addNativeButtonPairHandle('text', visibleButtonHandler);
			//cb.setNativeButtonState('text', cmtConfig.visible);
		}
		
		/**
		 * 内全屏事件监听
		 **/
		private function innerFullScreenButtonHandler(on:Boolean):void
		{
			dispatchEvent(new Event('innerFullScreen'));
		}
		
		/**
		 * 是否循环切换
		 **/
		private function loopButtonHandler(on:Boolean):void
		{
			trace("CommentDisplayer.loopButtonHandler", on);
		/*if (player.config.repeat != 'single')
		   {
		   player.config.repeat = 'single';
		   }
		   else
		   {
		   player.config.repeat = 'none';
		 }*/
		}
		
		/**
		 * 是否显示弹幕
		 **/
		private function visibleButtonHandler(on:Boolean):void
		{
			if (cmtConfig.visible != false)
			{
				cmtConfig.visible = false;
				_clip.visible = false;
				_scriptClip.visible = false;
				clearComments();
			}
			else
			{
				cmtConfig.visible = true;
				_clip.visible = true;
				_scriptClip.visible = true;
			}
		}
		
		/** 状态改变事件监听器,监听暂停或者播放 **/
		private function stateHandler(event:PlayerStateEvent):void
		{
			var i:int;
			var c:DisplayObject;
			if (event.newstate == 'PLAYING')
			{
				for (i = 0; i < _clip.numChildren; i++)
				{
					c = _clip.getChildAt(i);
					if (c is IComment)
					{
						IComment(c).resume();
					}
				}
				_isPlaying = true;
				ValueObjectManager.getCommentProvider.videoIsPlaying = true;
			}
			else if (event.oldstate == 'PLAYING' && event.newstate != 'PLAYING')
			{
				for (i = 0; i < _clip.numChildren; i++)
				{
					c = _clip.getChildAt(i);
					if (c is IComment)
					{
						IComment(c).pause();
					}
				}
				_isPlaying = false;
				ValueObjectManager.getCommentProvider.videoIsPlaying = false;
			}
		}
		
		/**
		 * 接口方法:播放器调整大小时被调用
		 * width与height参数不在函数中使用,所以可以传任意数值
		 **/
		public function resize(width:Number, height:Number):void
		{
			/** 还没有搞清楚传递进来的参数是否符合要求 **/ /** display的大小比较接近 **/ /** 视频是player.model.media.display,无API获取 **/
//			var w:int = (player.controls.display as DisplayComponent).getChildAt(0).width;
//			var h:int = (player.controls.display as DisplayComponent).getChildAt(0).height;
//			trace("Resize: w: " + w + ", h: " + h);
			var w:int = width;
			var h:int = height;
			//trace("Resize: w: " + w + ", h: " + h);
			
//			var videoDisplay:DisplayObject = (player as Player).model.media.display;
//			if (videoDisplay == null)
//			{
			//trace('Resize: videoDisplay is null');
//				videoDisplay = player.controls.display as DisplayObject;
			//时间太早
//				return;
//			}
			_clip.x = _clip.y = _scriptClip.x = _scriptClip.y = 0;
			/** 不挡字幕留白,弹幕布的高度减少一定大小 **/
			var r:Number = 0
			if (cmtConfig.bottomBlank)
			{
				//trace('Resize: bottomBlank.');
				/** 因为视频的高度在resize事件处理的靠前阶段已经计算出来 **/ /** 0.15是底部字幕占视频高度的比例 **/
				var clipHeight:Number = h * 0.5 + ValueObjectManager.getMediaProvider.videoHeight * (0.5 - 0.15);
				if (cmtConfig.syncResize)
				{
					r = h / cmtConfig.height;
					_clip.scaleX = _clip.scaleY = r;
					_scriptClip.scaleX = _scriptClip.scaleY = r;
					//经过缩放的字幕舞台是缩放前的大小
					w /= r;
					h = cmtConfig.height * clipHeight / h;
				}
				else
				{
					h = clipHeight;
					_clip.scaleX = _clip.scaleY = 1;
					_scriptClip.scaleX = _scriptClip.scaleY = 1;
				}
			}
			else
			{
				if (cmtConfig.syncResize)
				{
					r = h / cmtConfig.height;
					_clip.scaleX = _clip.scaleY = r;
					_scriptClip.scaleX = _scriptClip.scaleY = r;
					//经过缩放的字幕舞台是缩放前的大小
					w /= r;
					h = cmtConfig.height;
				}
				else
				{
					_clip.scaleX = _clip.scaleY = 1;
					_scriptClip.scaleX = _scriptClip.scaleY = 1;
				}
			}
			/** 3D透视中心 **/
			_clip.transform.perspectiveProjection = new PerspectiveProjection();
//			_clip.transform.perspectiveProjection.fieldOfView = 100;
			_clip.transform.perspectiveProjection.projectionCenter = new Point(w / 2, h / 2);
			
			_scriptClip.transform.perspectiveProjection = new PerspectiveProjection();
//			_scriptClip.transform.perspectiveProjection.fieldOfView = 100;
			_scriptClip.transform.perspectiveProjection.projectionCenter = new Point(w / 2, h / 2);
			
			//trace("Resize Last w: " + w + ", h: " + h);
			/** 通知到位 **/
			for each (var manager:CommentManager in managers)
			{
				manager.resize(w, h);
			}
		
//            clipMask.x = 0;
//            clipMask.y = 0;
//            
//            var g:Graphics = clipMask.graphics;
//            g.clear();
//            g.beginFill(0);
//            g.drawRect(0,0,w,h);
//            g.endFill();
//            if(clip.x > 0)
//            {
//                var m:Matrix = new Matrix();
//                m.createGradientBox(20,20,0,-20,0);
//                trace(m.toString());
//                g.beginGradientFill(GradientType.LINEAR,[0,0],[0,1],[0,0xff],m);
//                g.drawRect(-20,0,20,h);
//                g.endFill();
//
//                m.createGradientBox(20,20,0,cmtConfig.width * r,0);
//                g.beginGradientFill(GradientType.LINEAR,[0,0],[1,0],[0,0xff],m);
//                g.drawRect(cmtConfig.width * r,0,cmtConfig.width * r + 20,h);
//                g.endFill();
//            }
		}
		
		/** 接口方法,唯一的,小写字母标识 **/
		public function get id():String
		{
			return 'commentview';
		}
		
		/**
		 * 监听播放列表的item事件,加载弹幕从此开始
		 * 弹幕可能滞后,因为没有同步加载
		 **/
		//private function itemHandler(event):void
		//{
		//不再使用,加载弹幕由主程序控制
//            var item:PlaylistItem = player.playlist.currentItem;
//            if(config['url'])
//            {
//                try
//                {
//                    this.loadComment(config['url']);
//                }
//                catch(e:Error)
//                {
//                    
//                }
//            }
		//}
		/**
		 * 加载弹幕
		 * @param url 弹幕文件路径
		 **/
		//public function loadComment(url:String):void
		//{
			//this._provider.load(url);
		//}
		
		/**
		 * 播放时间事件
		 * 主要驱动事件.
		 **/
		private function timeHandler(event:MediaEvent):void
		{
			if (cmtConfig.visible == false || !isPlaying)
			{
				return;
			}
			_stime = event.position;
			for each (var manager:CommentManager in managers)
			{
				manager.time(event.position);
			}
			CommentManager.popComments(_clip, isPlaying);
		}
		
		/**
		 * 进度条拖动,清理屏幕
		 **/
		private function seekHandler(event:MediaEvent):void
		{
			clearComments();
		}
		
		private function commentFilterChangeHandler(event:MukioEvent):void
		{
			refreshBlockedComments();
		}
		
		/**
		 * 过滤器更新后,弹幕清除与显示
		 **/
		public function refreshBlockedComments():void
		{
			var len:uint = _clip.numChildren;
			var i:uint = 0;
			for (i = 0; i < len; i++)
			{
				var elem:DisplayObject = _clip.getChildAt(i);
				if (elem is IComment)
				{
					elem.visible = !(elem as IComment).data.blocked;
				}
			}
		}
		
		/**
		 * 弹幕清屏
		 **/
		public function clearComments():void
		{
			var len:uint = _clip.numChildren;
			var i:uint = 0;
			var arr:Vector.<IComment> = new Vector.<IComment>();
			for (i = 0; i < len; i++)
			{
				var elem:DisplayObject = _clip.getChildAt(i);
				if (elem is IComment)
				{
					arr.push(elem as IComment);
				}
			}
			/** stop会影响迭代 **/
			for each (var cmt:IComment in arr)
			{
				cmt.stop();
			}
		}
		
		/**
		 * 当前时间
		 **/
		public function get stime():Number
		{
			return _stime;
		}
		
		/**
		 * 添加弹幕管理者,每一种弹幕模式对应一个弹幕管理者
		 */
		private function addManagers():void
		{
			addManager(new CommentManager(_clip));
			addManager(new BottomCommentManager(_clip));
			addManager(new ScrollCommentManager(_clip));
			addManager(new RScrollCommentManager(_clip));
			addManager(new FixedPosCommentManager(_clip));
			addManager(new BiliBiliScriptCommentManager(_clip));
//            addManager(new ZoomeCommentManager(_clip));
            //addManager(new ScriptCommentManager(_clip));
		}
		
		/**
		 * 添加弹幕管理者
		 **/
		private function addManager(manager:CommentManager):void
		{
			manager.provider = ValueObjectManager.getCommentProvider
			this.managers.push(manager);
		}
		
		/**
		 * 返回弹幕提供者
		 **/
		//public function get provider():CommentProvider
		//{
			//return this._provider;
		//}
		
		/**
		 * 返回弹幕舞台
		 **/
		public function get clip():*
		{
			return _clip;
		}
		
		/** 插件版本号 **/
		public function get version():String
		{
			return _version;
		}
		
		/**
		 * 插件版本号
		 */
		public function set version(value:String):void
		{
			_version = value;
		}
		
		/** 简化的视频的播放器态,播放或静止 **/
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		/**
		 * 设置是否能使用截图功能
		 * @param on true表示允许,false表示不允许
		 **/
		public function enableImageCapture(on:Boolean):void
		{
			//var index:int = menuArr.indexOf(shareImageItem);
			//var menuEnabled:Boolean = index != -1;
			//if (on === menuEnabled)
			//{
				//return;
			//}
			//
			//if (on)
			//{
				//menuArr.push(shareImageItem);
			//}
			//else
			//{
				////删除
				//menuArr.splice(index, 1);
			//}
		}
	}
}