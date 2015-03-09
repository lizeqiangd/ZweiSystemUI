package com.bilibili.player.core.comments
{
    import com.bilibili.player.events.CommentDataEvent;
    import com.bilibili.player.events.MukioEvent;
    import com.bilibili.player.manager.ValueObjectManager;
    import com.bilibili.player.net.comment.CommentProvider;
    import com.bilibili.player.valueobjects.config.PlayerConfig;
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.external.ExternalInterface;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Point;
    
    //import org.lala.event.CommentDataEvent;
    //import org.lala.event.EventBus;
    //import org.lala.event.MukioEvent;
    //import org.lala.net.CommentProvider;
    //import org.lala.utils.CommentConfig;
    
    /**
	 * 弹幕播放引擎
	 * @author Aristotle9
	 * @editor Lizeqiangd
	 * 20141204 交给ValueObjectManager管理
	 * CommentProvider在这里初始化,在本类load弹幕Url
	 * 之后初始化各个manger,并将provider交给各个manager,各自玩各自的...
	 * 这样逻辑上会比较乱......我一定会改掉的.........
     **/
    public class CommentPlayer implements ICommentPlayer
    {
		/**
		 * 只有一个实例
		 */
		//protected static const _instance:ICommentPlayer = new CommentPlayer();
		/**
		 * ICommentPlay弹幕播放引擎实例
		 */
		//public static function getInstance():ICommentPlayer
		//{
			//return _instance;
		//}
        /** 弹幕来源,只有唯一一个实例 **/
        protected var _provider:CommentProvider;
        /** 弹幕管理者 **/
        protected var managers:Vector.<CommentManager>;
        /** 弹幕层,类本身是插件层,但是位置不符合弹幕的需求,所以另起一层 **/
        protected var _clip:Sprite;
        /** 不使用遮罩可以提高效率 **/
        protected var _maskClip:Sprite;
		protected var _useMask:Boolean = false;
        /** 时间点 **/
        protected var _time:Number = 0;
        /** 普通弹幕配置 **/
        protected var config:PlayerConfig = ValueObjectManager.getPlayerConfig
        /** 简化的视频的播放器态,播放或静止 **/
        protected var _paused:Boolean = true;
		
		protected var oldWidth:Number = 200;
		protected var oldHeight:Number = 200;
		private var _isCommentsCovered:Boolean = true;
		
        public function CommentPlayer()
        {
			//if(_instance)
				//throw "please use CommentPlayer/getInstance() to get a instance";
			trace('this comment player should not be init')
            _clip = new Sprite();
            _clip.name = 'commentClip';
			_clip.useHandCursor = true;
			_clip.buttonMode = true;
			/** 本身不接收点击事件,但是子集可能会接收 **/
			_clip.mouseEnabled = false;
			
            _maskClip = new Sprite();
            _maskClip.name = 'commentClipMask';
			
			_provider = ValueObjectManager.getCommentProvider
			_provider.addEventListener(CommentDataEvent.CLEAR, clearCommentDataHandler);
			
            managers = new Vector.<CommentManager>();
			addManagers();

			/** 过滤器变动,更新已经实例化的Comment **/
			ValueObjectManager.getEventBus.addEventListener("commentFilterChange", commentFilterChangeHandler);
			
			/** 显示隐藏弹幕的js接口 **/
			try {
				if(ExternalInterface.available) {
					ExternalInterface.addCallback('showComments', function(...args):Boolean {
						if(args.length == 0)
						{
							return config.visible;
						}
						else if(args.length >= 1)
						{
							commentVisible = Boolean(args[0]);
						}
						return config.visible;
					});
				}
			}
			catch(e:Error) {
			}
        }

		public function get commentVisible():Boolean
		{
			return config.visible;
		}
		
        public function set commentVisible(value:Boolean):void
        {
			if(config.visible == value)
				return;
			
			config.visible = value;
			_clip.visible = value;

			if(!value)
				clear();
        }
		
		public function get paused():Boolean
		{
			return _paused;
		}
		
		public function play():void
		{
			if(!_paused)
				return;
			
			for(var i:uint = 0; i < _clip.numChildren; i++)
			{
				var c:DisplayObject = _clip.getChildAt(i);
				if(c is IComment)
				{
					IComment(c).resume();
				}
			}
			_paused = false;
			provider.videoIsPlaying = true;
		}
		
		public function pause():void
		{
			if(_paused)
				return;
			
			for(var i:uint = 0; i < _clip.numChildren; i++)
			{
				var c:DisplayObject = _clip.getChildAt(i);
				if(c is IComment)
				{
					IComment(c).pause();
				}
			}
			_paused = true;
			provider.videoIsPlaying = false;
		}
		
        public function resize(width:Number=0, height:Number=0, videoHeight:Number=0):void
        {
			if(width == 0)
				width = oldWidth;
			else
				oldWidth = width;
			
			if(height == 0)
				height = oldHeight;
			else
				oldHeight = height;

			if(videoHeight == 0)
				videoHeight = height;

			_clip.x = 0;
			_clip.y = 0;
			
			var syncResize:Boolean = config.syncResize;
			/** 不覆盖到视频上 **/
			if(!isCommentsCovered)
			{
				_clip.y = height * 4 / 5; 
				height /= 5;
				syncResize = true;
			}
			/** 不挡字幕留白,弹幕布的高度减少一定大小 **/
			var r:Number=0
			if(config.bottomBlank)
			{
				trace('Resize: bottomBlank.');
				/** 因为视频的高度在resize事件处理的靠前阶段已经计算出来 **/
				/** 0.15是底部字幕占视频高度的比例 **/
				var clipHeight:Number = height * 0.5 + videoHeight * (0.5 - 0.15);
				if(syncResize)
				{
					r= height / config.height;
					_clip.scaleX = _clip.scaleY = r;
					//经过缩放的字幕舞台是缩放前的大小
					width /= r;
					height = config.height * clipHeight / height;
				}
				else
				{
					height = clipHeight;
					_clip.scaleX = _clip.scaleY = 1;
				}
			}
			else
			{
				if(syncResize)
				{
					r= height / config.height;
					if(!isCommentsCovered)
					{
						r = 0.618;	
					}
					_clip.scaleX = _clip.scaleY = r;
					//经过缩放的字幕舞台是缩放前的大小
					width /= r;
					height = config.height;
				}
				else
				{
					_clip.scaleX = _clip.scaleY = 1;
				}
			}
			/** 3D透视中心 **/
			_clip.transform.perspectiveProjection = new PerspectiveProjection();
//			_clip.transform.perspectiveProjection.fieldOfView = 100;
			_clip.transform.perspectiveProjection.projectionCenter = new Point(width / 2, height / 2);
			
            /** 通知到位 **/
            for each(var manager:CommentManager in managers)
            {
                manager.resize(width,height);
            }

			if(useMask)
			{
	            _maskClip.x = 0;
	            _maskClip.y = 0;
	            
	            var g:Graphics = _maskClip.graphics;
	            g.clear();
	            g.beginFill(0);
	            g.drawRect(0,0,width,height);
	            g.endFill();
			}
			else
			{
				_maskClip.graphics.clear();
			}
        }
		
        public function load(url:String):void
        {
            _provider.load(url);
        }
		
		public function get time():Number
		{
			return _time;
		}
		
        public function set time(value:Number):void
        {
            if(config.visible == false || _paused)
            {
                return;
            }
            _time = value;
            for each(var manager:CommentManager in managers)
            {
                manager.time(_time);
            }
			CommentManager.popComments(_clip, !_paused);
        }
		
		protected function commentFilterChangeHandler(event:MukioEvent):void
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
			for(i = 0; i < len; i ++)
			{
				var elem:DisplayObject = _clip.getChildAt(i);
				if(elem is IComment)
				{
					elem.visible = !(elem as IComment).data.blocked; 
				}
			}
		}
		/**
		 * 重新加载弹幕时清空屏幕弹幕
		 */
		protected function clearCommentDataHandler(event:CommentDataEvent):void
		{
			clear();
		}
		
		public function clear():void
		{
			var len:uint = _clip.numChildren;
			var i:uint = 0;
			var arr:Vector.<IComment> = new Vector.<IComment>();
			for(i = 0; i < len; i ++)
			{
				var elem:DisplayObject = _clip.getChildAt(i);
				if(elem is IComment)
				{
					arr.push(elem as IComment);
				}
			}
			/** stop会影响迭代 **/
			for each(var cmt:IComment in arr)
			{
				cmt.stop();
			}
		}
        /**
        * 添加弹幕管理者,每一种弹幕模式对应一个弹幕管理者
        */
        protected function addManagers():void
        {
            addManager(new CommentManager(_clip));
            addManager(new BottomCommentManager(_clip));
            addManager(new ScrollCommentManager(_clip));
			CONFIG::flex {//合作播放器没有这些弹幕类型
	            addManager(new RScrollCommentManager(_clip));
	            addManager(new FixedPosCommentManager(_clip));
            	addManager(new BiliBiliScriptCommentManager(_clip));
			}
//            addManager(new ZoomeCommentManager(_clip));
//            addManager(new ScriptCommentManager(_clip));
        }
        /**
        * 添加弹幕管理者
        **/
        protected function addManager(manager:CommentManager):void
        {
            manager.provider = this._provider;
            this.managers.push(manager);
        }
        
        /**
        * 返回弹幕提供者
        **/
        public function get provider():CommentProvider
        {
            return _provider;
        }
        
        /**
        * 返回弹幕舞台
        **/
        public function get clip():Sprite
        {
            return _clip;
        }

		public function get liveMode():Boolean
		{
			return _provider.liveMode;
		}
		
		public function set liveMode(value:Boolean):void
		{
			_provider.liveMode = value;
		}
		public function get maskClip():DisplayObject
		{
			return _maskClip;
		}
		/**
		 * 是否使用弹幕层遮罩:使用弹幕层的遮罩会降低弹幕渲染效率,但是在侧栏背景透明的情况下必须使用
		 * 然后全屏的时候取消遮罩
		 */
		public function get useMask():Boolean
		{
			return _useMask;
		}
		/**
		 * @private
		 */
		public function set useMask(value:Boolean):void
		{
			if(value !== _useMask)
			{
				_useMask = value;
				if(!_useMask)
				{
					_maskClip.graphics.clear();
					_maskClip.visible = false;
					clip.mask = null;
				}
				else
				{
					clip.mask = _maskClip;
					_maskClip.visible = true;
					resize(0, 0);
				}
			}
		}
		/**
		 * 是否允许弹幕覆盖视频?
		 */
		public function get isCommentsCovered():Boolean
		{
			return _isCommentsCovered;
		}

		/**
		 * @private
		 */
		public function set isCommentsCovered(value:Boolean):void
		{
			_isCommentsCovered = value;
		}
	}
}