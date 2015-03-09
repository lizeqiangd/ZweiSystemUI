package com.bilibili.player.core.filter
{
    import com.bilibili.player.core.filter.interfaces.ICommentFilter;
    import com.bilibili.player.events.CommentFilterEvent;
    import com.bilibili.player.manager.AccessConsumerManager;
    import com.bilibili.player.manager.ValueObjectManager;
    import com.bilibili.player.net.api.BilibiliApi;
    import com.bilibili.player.net.api.Services;
    import com.bilibili.player.system.config.BPSetting;
    import com.bilibili.player.valueobjects.config.AccessConfig;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.SharedObject;
    
    
    
  /*  import org.lala.event.CommentFilterEvent;
    import org.lala.event.EventBus;
    import org.lala.filter.interfaces.ICommentFilter;
    import org.lala.utils.ApplicationConstants;
    
    import tv.bilibili.net.AccessConfig;
    import tv.bilibili.net.AccessConsumerManager;
    import tv.bilibili.net.IAccessConfigConsumer;
    import tv.bilibili.net.Services;*/

	/**
	 * 过滤列表更改:请使用 EventBus的commentFilterChange事件
	 */
	[Event(name="filterListChange", type="org.lala.event.CommentFilterEvent")]
	/**
	 * UP主过滤列表变化
	 */
	[Event(name="upperFilterChange", type="org.lala.event.CommentFilterEvent")]
	/**
	 * 云屏蔽列表变化
	 */
	[Event(name="cloudFilterChange", type="org.lala.event.CommentFilterEvent")]
    /**
     * 弹幕过滤器类:重制
     * @author aristotle9
     **/
    public class CommentFilter extends EventDispatcher implements ICommentFilter /*, IAccessConfigConsumer*/
		
		
    {
		/** 当前的弹幕过滤器存储的版本号 **/
		protected const VERSION:uint = 1;
		/** 云屏蔽池名称:视频 **/
		public static const VIDEO:String = 'video';
		/** 云屏蔽池名称:分类 **/
		public static const CATALOG:String = 'catalog';
		/** 云屏蔽池名称:全屏 **/
		public static const GLOBAL:String = 'global';
		
        /** 过滤器数据数组 **/
        private var fArr:Array = [];
		/** 模式过滤存储 **/
		private var modeObj:Object;
		/** 弹幕池过滤存储 **/
		private var poolObj:Object;
		/** cloud过滤存储(存储取消的屏蔽池) **/
		private var cloudObj:Object; 
		/** 云屏蔽级别:百分比 **/
		private var _cloudPercent:Number = 0.5;

		/** 自增的id **/
        private var ids:int = 0;
        /**
		 * 是否是在初始化状态:
		 * 初始化状态下不派发过滤器更改事件
		 **/
		private var initialized:Boolean = false;
		/*CONFIG::flex {
        	[Bindable(event="enableChange")]
		}*/
        public var bEnable:Boolean = true;
		/*CONFIG::flex {
        	[Bindable(event="regChange")]
		}*/
        public var bRegEnable:Boolean = false;
//        [Bindable(event="whiteListChange")]
//        public var bWhiteList:Boolean = false;
        /** 是否显示游客弹幕? **/
//		[Bindable(event="guestVisibleChange")]
		/*CONFIG::flex {
			[Bindable]
		}*/
		public var bGuestVisible:Boolean = true;
		private var _bTopVisible:Boolean = true;
		
		private var _bBottomVisible:Boolean = true;
		
		/** 是否使用UP主屏蔽列表:默认/使用/不使用 **/
		private var _bUpperEnable:Object = null;
		/** UP主屏蔽开启的默认值:原创视频下默认打开 **/
		private var _bUpperDefault:Boolean = false;
		/*CONFIG::flex {
			[Bindable]
		}*/
		/** 是否显示有色弹幕 **/
		public var bColored:Boolean = true;
		/*CONFIG::flex {
			[Bindable]
		}*/
		/** 允许的最大字号:0表示无限制 **/
		public var maxSize:int = 0;
		
		/** 云屏蔽实体 **/
		private var videoCloudFilter:CommentCloudFilter;
		private var catalogCloudFilter:CommentCloudFilter;
		private var globalCloudFilter:CommentCloudFilter;
	/*	CONFIG::flex {
			[Bindable]
		}*/
		/** 云屏蔽总列表 **/
		public var cloudFilterArr:Array = [];
		/*CONFIG::flex {
			[Bindable]
		}*/
		/** UP主屏蔽 **/
		public var upperFiler:UpperFilter;
		/*CONFIG::flex {
			[Bindable]
		}*/
		/** UP主屏蔽列表:用于展示 **/
		public var upperFilterArr:Array = [];
		
        private static var instance:CommentFilter;
		/**
		 * 记录上一次的aid,aid改变,则重新加载云屏蔽
		 */
		private var aid:String = "";
        
        public function CommentFilter() 
        {
            //if(instance != null)
            //{
                //throw new Error("class CommentFilter is a Singleton,please use getInstance()");
            //}
            //
            loadFromSharedObject();
			initialized = true;
			
			AccessConsumerManager.addAccessConfigChangeFunction(onAccessConfigUpdate)
			/*AccessConsumerManager.regist(this);*/
        }
		
		public function onAccessConfigUpdate(/*accessConfig:AccessConfig*/):void
		{
			if(aid != AccessConsumerManager.getAccessConfig.aid)
			{
				aid = AccessConsumerManager.getAccessConfig.aid;
				/** 过滤设置与aid相对应 **/
				initializeRemoteFilters(AccessConsumerManager.getAccessConfig);
			}
		}
		
        public function get filterSource():Array
        {
            return fArr;
        }
        /** 单件 **/
        //public static function getInstance():CommentFilter
        //{
            //if(instance == null)
            //{
                //instance = new CommentFilter();
            //}
            //return instance;
        //}
        public function setEnable(id:int, enable:Boolean):void
        {//because delete operate makes some fArr[id] to null,so has to search over
            for (var i:int = 0; i < fArr.length; i++)
            {
                if (fArr[i].id == id)
                {
                    fArr[i].enable = enable;
					if(initialized)
					{
						savetoSharedObject();
					}
                    return;
                }
            }
        }
        public function deleteItem(id:int):void
        {//because delete operate makes some fArr[id] to null, so has to search over
            for (var i:int = 0; i < fArr.length; i++)
            {
                if (fArr[i].id == id)
                {
                    var item:Object = fArr.splice(i, 1);
					if(initialized)
					{
						savetoSharedObject();
						Services.sendUnblockKeyword(item.mode, item.exp);
					}
                    return;
                }
            }
        }
		/**
		 * 锁定:不自动进行保存与刷新操作(提高效率)
		 * 在大量添加过滤条目时有非常重要作用
		 **/
		public function lock():void
		{
			if(initialized == false)
			{
				throw new Error('只支持单重加锁');
			}
			initialized = false;
		}
		/**
		 * 解锁,并保存过滤表
		 **/
		public function unlock():void
		{
			initialized = true;
			savetoSharedObject();
		}
        public function savetoSharedObject():void
        {
            trace("savetoSharedObject");
			/** 过滤器更改后会保存,所以在这里派发更改事件 **/
			
			ValueObjectManager.getEventBus.sendMukioEvent('commentFilterChange', this);
            try
            {
                var cookie:SharedObject = SharedObject.getLocal(BPSetting.SharedObjectName, '/');
				/** 使用的序列化函数与版本号要一致 **/
				var obj:* = toObject_v1();
                cookie.data['CommentFilter'] = obj;
                cookie.data['CommentFilter.VERSION'] = VERSION;
				
                cookie.flush();
            }
            catch (e:Error) { };
        }
        public function loadFromSharedObject():void
        {
            try
            {
                var cookie:SharedObject = SharedObject.getLocal(BPSetting.SharedObjectName, '/');
				
				var obj:* = cookie.data['CommentFilter'];
				/** 存储的版本号:无版本号均以处理,以后所有的存储必须添加版本号 **/
				var ver:uint = 0;
				if(cookie.data.hasOwnProperty('CommentFilter.VERSION'))
				{
					ver = uint(cookie.data['CommentFilter.VERSION']);
				}
				
				switch(ver)
				{
					case 0:
						fromObject_v0(obj);
						break;
					case 1:
						fromObject_v1(obj);
						break;
					default:
						break;
				}
            }catch (e:Error) {
				trace('fromSharedObject Error'); };
        }
		
//        [Deprecated]
        private function toObject_v0():Object
        {
			var raw:Array = [];
			for each(var item:Object in fArr)
			{
				raw.push([item.data, item.enable]);
			}
            var a:Array = [];
            a.push(raw,bEnable,bRegEnable,false,modeObj,poolObj, bGuestVisible, cloudObj, cloudPercent);
            return JSON.stringify(a);
        }
		
		private function toObject_v1():Object
		{
			var raw:Array = [];
			for each(var item:Object in fArr)
			{
				raw.push([item.data, item.enable]);
			}
            var a:Array = [];
            a.push(0,bEnable,bRegEnable,false,modeObj,poolObj, bGuestVisible, cloudObj, cloudPercent, bUpperEnable, bColored, maxSize);
            return {list:raw, attr:a};
		}
//        [Deprecated]
        private function fromObject_v0(source:String):void
        {
            fArr.splice(0, fArr.length);
			bEnable = true;
			bRegEnable = false;
//			bWhiteList = false;
			modeObj = {};
			poolObj = {};
			bGuestVisible = true;
			cloudObj = {};
			cloudPercent = 0.5;
			bUpperEnable = null;
			bColored = true;
			maxSize = 0;
            try
            {
                var a:Array = JSON.parse(source)as Array;
				if(a[0])
				{
					for each(var src:Array in a[0])
					{
						addItem(src[0], src[1]);
					}
				}
				if(a.length > 1)				
	                bEnable = a[1];
				
				if(a.length > 2)				
    	            bRegEnable = a[2];
				
//				if(a.length > 3)				
//        	        bWhiteList = a[3];
//				
//				if(a.length > 4)				
//					modeObj = a[4];
//				
//				if(a.length > 5)				
//					poolObj = a[5];
				
				if(a.length > 6)				
					bGuestVisible = a[6];
				
				if(a.length > 7)
					cloudObj = a[7];
				
				if(a.length > 8)
					cloudPercent = a[8];
				
            } catch(e:Error){}
        }
		
		private function fromObject_v1(obj:Object):void
		{
			fArr.splice(0, fArr.length);
			bEnable = true;
			bRegEnable = false;
			modeObj = {};
			poolObj = {};
			bGuestVisible = true;
			cloudObj = {};
			cloudPercent = 0.5;
			bUpperEnable = null;
			bColored = true;
			maxSize = 0;
			try
			{
				for each(var src:Array in obj.list)
				{
					addItem(src[0], src[1]);
				}
				
				var a:Array = obj.attr;
				
				if(a.length > 1)				
					bEnable = a[1];
				
				if(a.length > 2)				
					bRegEnable = a[2];
				
				if(a.length > 6)				
					bGuestVisible = a[6];
				
				if(a.length > 7)
					cloudObj = a[7];
				
				if(a.length > 8)
					cloudPercent = a[8];
				
				if(a.length > 9)
					bUpperEnable = a[9];
				
				if(a.length > 10)
					bColored = a[10];
				
				if(a.length > 11)
					maxSize = a[11];
				
			} catch(e:Error){}
		}
		/**
		 * 设置模式过滤
		 * @param mode 模式屏蔽的模式
		 * @param filtrate 是否屏蔽:true表示屏蔽
		 **/
		public function setModeFilter(mode:uint, filtrate:Boolean):void
		{
			if(modeObj[mode] != filtrate)
			{
				modeObj[mode] = filtrate;
				ValueObjectManager.getEventBus.sendMukioEvent('commentFilterChange', this);
			}
		}
		/**
		 * 设置字幕池过滤
		 * @param pool 字幕池的模式
		 * @param filtrate 是否屏蔽:true表示屏蔽
		 **/
		public function setPoolFilter(pool:uint, filtrate:Boolean):void
		{
			if(poolObj[pool] != filtrate)
			{
				poolObj[pool] = filtrate;
				savetoSharedObject();
			}
		}
		/**
		 * 设置云屏蔽的池是否禁用
		 * @param name 云屏蔽的池名称:video,catalog,global
		 * @param disabled 是否禁用:true表示禁用
		 **/
		public function setCloudPool(name:String, disabled:Boolean):void
		{
			if(cloudObj[name] != disabled)
			{
				cloudObj[name] = disabled;
				loadCloudFilters();
				savetoSharedObject();
			}
		}
		/** 
		 * 检测云屏蔽池是否禁用
		 * @param name 池名称:video,catalog,global
		 * @return true 表示启用
		 **/
		public function cloudEnabled(name:String):Boolean
		{
			return !cloudObj[name];
		}
		/** 初始化服务器端的屏蔽列表 **/
		private function initializeRemoteFilters(accessConfig:AccessConfig=null):void
		{
			/** providers **/
			var videoFilterProovider:RemoteLoader = 
				new RemoteLoader(BilibiliApi.getVideoFilterUrl);
			var catalogFilterProvider:RemoteLoader = 
				new RemoteLoader(BilibiliApi.getCatalogFilterUrl);
			var globalFilterProvider:RemoteLoader = 
				new RemoteLoader(BilibiliApi.getGlobalFilterUrl);
			
			videoCloudFilter = new VideoCloudFilter(videoFilterProovider);
			catalogCloudFilter = new CatalogCloudFilter(catalogFilterProvider, null, accessConfig.typeId);
						globalCloudFilter = new CommentCloudFilter(globalFilterProvider);
			
			/** 初始化UP主屏蔽列表 **/
			/** 与视频的云屏蔽使用相同的源 **/
			upperFiler = new UpperFilter(videoFilterProovider);
			
			initializeCloudFilter(videoCloudFilter);
			initializeCloudFilter(catalogCloudFilter);
			initializeCloudFilter(globalCloudFilter);
			
			upperFiler.addEventListener(Event.COMPLETE, upperFilerCompleteHandler);
			
			/**
			 * 缓存列表清空
			 */
			cloudFilterArr.splice(0, cloudFilterArr.length); 
			upperFilterArr.splice(0, upperFilterArr.length);
			
			loadCloudFilters();
			loadUpperFilter();
		}
		/** 初始化单个云屏蔽 **/
		private function initializeCloudFilter(cfilter:CommentCloudFilter):void
		{
			cfilter.setPercentage(_cloudPercent);
			cfilter.addEventListener(Event.COMPLETE, cFilterCompleteHandler);
		}
		/**
		 * 云屏蔽列表加载完毕:用于显示
		 **/
		private function cFilterCompleteHandler(event:Event):void
		{
			var cFilter:CommentCloudFilter = event.target as CommentCloudFilter;
			cFilter.removeEventListener(Event.COMPLETE, cFilterCompleteHandler);
			
			var item:CommentFilterItem = null;
			
			for each(item in cFilter.textArr)
			{
				cloudFilterArr.push(item);
			}
			for each(item in cFilter.userArr)
			{
				cloudFilterArr.push(item);
			}
			dispatchEvent(new CommentFilterEvent(CommentFilterEvent.CLOUDE_FILTER_CHANGE));
		}
		private function upperFilerCompleteHandler(event:Event):void
		{
			var cFilter:CommentCloudFilter = event.target as CommentCloudFilter;
			cFilter.removeEventListener(Event.COMPLETE, cFilterCompleteHandler);
			
			var item:CommentFilterItem = null;
			
			for each(item in cFilter.textArr)
			{
				upperFilterArr.push(item);
			}
			for each(item in cFilter.userArr)
			{
				upperFilterArr.push(item);
			}
			dispatchEvent(new CommentFilterEvent(CommentFilterEvent.UPPER_FILTER_CHANGE));
		}
		/** 尝试装载云屏蔽 **/
		protected function loadCloudFilters():void
		{
			if(cloudEnabled(VIDEO) && videoCloudFilter && videoCloudFilter.state === RemoteLoaderState.UNLOAD)
				videoCloudFilter.load();
			
			if(cloudEnabled(CATALOG) && catalogCloudFilter && catalogCloudFilter.state === RemoteLoaderState.UNLOAD)
				catalogCloudFilter.load();
			
			if(cloudEnabled(GLOBAL) && globalCloudFilter && globalCloudFilter.state === RemoteLoaderState.UNLOAD)
				globalCloudFilter.load();
		}
		
		/** 
		 * 尝试加载UP主 屏蔽列表 
		 **/		
		protected function loadUpperFilter():void
		{
			if((bUpperEnable || bUpperDefault) && upperFiler && upperFiler.state === RemoteLoaderState.UNLOAD)
				upperFiler.load();
		}
		/** 
		 * 模式过滤器
		 * @param mode 弹幕模式
		 * @return true表示放行
	 	 **/
		public function modeFilter(mode:uint):Boolean
		{
			return !modeObj[mode];
		}
		/** 
		 * 池过滤器
		 * @param pool 弹幕池
		 * @return true表示放行
		 **/
		public function poolFilter(pool:uint):Boolean
		{
			return !poolObj[pool];
		}
		/**
		 * 屏蔽用户
		 * @param userId 用户标识
		 **/
		public function blockUserById(userId:String):void
		{
			addItem('u=' + userId);
		}
		/**
		 * 检测某用户是否在屏蔽列表中,如果有,返回该屏蔽项,否则返回null
		 * @param userId 用于检测的用户id
		 * @return 如果有,返回该屏蔽项,如果没有返回null
		 **/
		public function getItemByUserId(userId:String):Object
		{
			var len:uint = fArr.length;
			for(var i:uint = 0; i < len; i++)
			{
				var item:* = fArr[i];
				if(item.mode === CommentFilterMode.USER && item.exp === userId)
				{
					return item;
				}
			}
			return null;
		}
		/**
		 * 检测某用户是否在屏蔽列表中,如果有,返回该True,否则返回False
		 * @param userId 用于检测的用户id
		 * @return 如果有,返回该True,否则返回False
		 **/
		public function isSomeoneBlocked(userId:String):Boolean
		{
			return getItemByUserId(userId) !== null;
		}
        /**
		 * 添加过滤项
		 * @param keyword 过滤器文本表达式(只支持t=,c=,u=)
		 * @param enable 启用状态
		 **/
        public function addItem(keyword:String,enable:Boolean=true):void
        {
            var mod:int;
            var exp:*;
				
            if (keyword.length < 3)
            {
                mod = CommentFilterMode.TEXT;
                exp = keyword;
            }
            else
            {
                var head:String = keyword.substr(0, 2);
                exp = keyword.substr(2);
                switch(head)
                {
                    case 'c=':
                        mod = CommentFilterMode.COLOR;
						exp = String(exp).replace(/[^\da-f]/ig, '');
						exp = parseInt(exp, 16);
                        break;
                    case 't=':
                        mod = CommentFilterMode.TEXT;
                        break;
                    case 'u=':
                        mod = CommentFilterMode.USER;
                        break;
                    default:
                        mod = CommentFilterMode.TEXT;
                        exp = keyword;
                        break;
                }
            }
			/** 检测是否已经存在相同的表达式:(对于颜色检测数值,所以是在解析后判断) **/
			for each(var obj:Object in fArr)
			{
				/** 该表达式已经存在 **/
				if(mod == obj.mode && exp == obj.exp)
				{
					/** 将启用状态设置为真,因为可能是用户未启用该表达式而重新添加 **/
					if(!obj.enable)
					{
						obj.enable = true;
						/** 初始化完成后,添加过滤项触发保存事件 **/
						if(initialized)
						{
							savetoSharedObject();
						}
					}
					return ;
				}
			}
            add(mod, exp, keyword,enable);
			/** 初始化完成后,添加过滤项触发保存事件 **/
			if(initialized)
			{
				savetoSharedObject();
				Services.sendKeyword(mod, exp);
			}
        }
		/**
		 * 添加过滤项
		 * @param mode 模式
		 * @param exp 内容
		 * @param data 原始数据
		 * @param 启用状态
		 **/
        private function add(mode:int, exp:*, data:String,enable:Boolean=true):void
        {
            fArr.push( { 'mode':mode,
                'data':data,
                'exp':exp,
                'normalExp':String(exp).replace(/(\^|\$|\\|\.|\*|\+|\?|\(|\)|\[|\]|\{|\}|\||\/)/g,'\\$1'),
                'id':ids++,
                'enable':enable} );
        }
        /**
         * 校验接口
         * @param item 弹幕数据
         * @return 通过校验允许播放时返回true
         **/
        public function validate(item:Object):Boolean
        {
			item.blockType = BlockType.CUSTOM_BLOCK;//当blocked == false时为没有屏蔽
			/** 模式与池屏蔽不受自定义表的开关控制 **/
			/** 如果其中一个不放行(false),就不放行 **/
			if(!poolFilter(item.pool) || !modeFilter(item.mode))
			{
				item.blockType = BlockType.MODE_POOL_BLOCK;
				return false;
			}
			
			/** 字幕池弹幕与脚本弹幕不被用户屏蔽过滤 **/
			if(item.pool == 1 || item.pool == 2)
			{
				return true;
			}
			
			/** 不显示游客弹幕 **/
			if(!bGuestVisible && (item.userId as String).charAt(0) == 'D')
			{
				item.blockType = BlockType.GUEST_BLOCK;
				return false;
			}
			
			/** 不显示有色弹幕 **/
			if(!bColored && (item.color !== 0xffffff))
			{
				item.blockType = BlockType.MODE_POOL_BLOCK;
				return false;
			}
			
			/** 不显示最大号限制以上的弹幕 **/
			if(maxSize > 0 && (item.size > maxSize))
			{
				item.blockType = BlockType.MODE_POOL_BLOCK;
				return false;
			}
			
			/** 云屏蔽判断 **/
			if(cloudEnabled(GLOBAL) && globalCloudFilter && globalCloudFilter.state === RemoteLoaderState.LOADED)
			{
				if(!globalCloudFilter.validate(item))
				{
					item.blockType = BlockType.CLOUD_BLOCK;
					return false;
				}
			}
			if(cloudEnabled(VIDEO) && videoCloudFilter && videoCloudFilter.state === RemoteLoaderState.LOADED)
			{
				if(!videoCloudFilter.validate(item))
				{
					item.blockType = BlockType.CLOUD_BLOCK;
					return false;
				}
			}
			
			/** UP主屏蔽 **/
			if((bUpperEnable || bUpperDefault) && upperFiler && upperFiler.state === RemoteLoaderState.LOADED)
			{
				if(!upperFiler.validate(item))
				{
					item.blockType = BlockType.UPPER_BLOCK;
					return false;
				}
			}
			
			/**
			 * 分类的云屏蔽使用特殊的规则：
			 * 不受开关控制;特有的tag
			 **/
			if(catalogCloudFilter && catalogCloudFilter.state === RemoteLoaderState.LOADED)
			{
				if(!catalogCloudFilter.validate(item))
				{
					item.blockType = BlockType.BLACKLIST_BLOCK;
					return false;
				}
			}
			
			/** 自定义屏蔽列表是否可用 **/
            if (!bEnable)
            {
                return true;
            }
			
			/** 原始值为true:一经更改,立即返回 **/
            var res:Boolean = !false;
            for (var i:int = 0; i < fArr.length; i++)
            {
                var tmp:Object = fArr[i];
                if (!tmp.enable)
                {
                    continue;
                }
                if (tmp.mode == CommentFilterMode.USER)
                {
                    if (tmp.exp == String(item.userId))
                    {
                        res = false;
						item.blockType = BlockType.USER_BLOCK;
                        break;
                    }
                }
                else if (tmp.mode == CommentFilterMode.COLOR)
                {
                    if (tmp.exp == item.color)
                    {
                        res = false;
						item.blockType = BlockType.COLOR_BLOCK;
                        break;
                    }
                }
                else if (tmp.mode == CommentFilterMode.TEXT)
                {
                    if (bRegEnable)
                    {
                        if (String(item.text).search(tmp.exp) != -1)
                        {
                            res = false;
							item.blockType = BlockType.KEYWORD_BLOCK;
                            break;
                        }
                    }
                    else
                    {
                        if (String(item.text).search(tmp.normalExp) != -1)
                        {
                            res = false;
							item.blockType = BlockType.KEYWORD_BLOCK;
                            break;
                        }
                    }
                }
            }
            return res;
        }

		/*CONFIG::flex {
			[Bindable]
		}*/
		/** 云屏蔽级别:百分比 **/
		public function get cloudPercent():Number
		{
			return _cloudPercent;
		}

		/**
		 * @private
		 */
		public function set cloudPercent(value:Number):void
		{
			if(_cloudPercent != value)
			{
				_cloudPercent = value;
				if(videoCloudFilter)
				{
					videoCloudFilter.setPercentage(_cloudPercent);
					catalogCloudFilter.setPercentage(_cloudPercent);
					globalCloudFilter.setPercentage(_cloudPercent);
				}
				savetoSharedObject();
			}
		}
		/**
		 * 得到导出xml
		 **/
		public function getXMLString():String
		{
			var total:int = 0;
			
			var xml:XML = <filters></filters>;
			for each(var i:Object in fArr)
			{
				xml.appendChild(renderItem(i));
				
				/** 最多只能导出1000条 **/
				total ++;
				if(total >= 1000)
					break;
			}
			return xml.toXMLString();
		}
		/**
		 * 渲染一个过滤项
		 **/
		protected function renderItem(item:Object):XML
		{
			var ret:XML = <item></item>;
			ret.@enabled = item.enable;
			
//			if(item.mode === CommentFilterMode.COLOR)
//				ret.@type = 'color';
//			else if(item.mode === CommentFilterMode.TEXT)
//				ret.@type = 'text';
//			else if(item.mode === CommentFilterMode.USER)
//				ret.@type = 'user';
//			else
//				return null;
			
			ret.appendChild(item.data);
			return ret;
		}
		/**
		 * 从XML文件导入
		 **/
		public function fromXMLString(xmlStr:String):void
		{
			try{
				var xml:XML = new XML(xmlStr);
			}
			catch(e:Error)
			{
				trace('不是有效的XML文件.');
				return;
			}
			
			lock();
			for each(var item:XML in xml.descendants('item'))
			{
				/** 超过1000条不能再导入 **/
				if(fArr.length > 1000)
					break;
				
				addItem(String(item), Boolean(item.@enabled));
			}
			unlock();
		}

		/*CONFIG::flex {
			[Bindable]
		}*/
		/** 是否使用UP主屏蔽列表:默认/使用/不使用 **/
		public function get bUpperEnable():Object
		{
			return _bUpperEnable;
		}

		/**
		 * @private
		 */
		public function set bUpperEnable(value:Object):void
		{
			if(_bUpperEnable != value)
			{
				_bUpperEnable = value;
				savetoSharedObject();
				
				/** 延迟加载(加载完毕后不保证会再次检测) **/
				if(_bUpperEnable)
				{
					loadUpperFilter();
				}
			}
		}

		/** UP主屏蔽开启的默认值:原创视频下默认打开 **/
		public function get bUpperDefault():Boolean
		{
			return _bUpperDefault;
		}

		/**
		 * @private
		 */
		public function set bUpperDefault(value:Boolean):void
		{
			if(_bUpperDefault != value)
			{
				_bUpperDefault = value;
				
				if(_bUpperDefault)
					loadUpperFilter();
			}
		}

		/*CONFIG::flex {
			[Bindable(event="modeVisibleChange5")]
		}*/
		/** 用于同步两个界面的数据 **/
		public function get bTopVisible():Boolean
		{
			return _bTopVisible;
		}

		/**
		 * @private
		 */
		public function set bTopVisible(value:Boolean):void
		{
			if( _bTopVisible !== value)
			{
				_bTopVisible = value;
				setModeFilter(5, !value);
				dispatchEvent(new Event("modeVisibleChange5"));
			}
		}

		/*CONFIG::flex {
			[Bindable(event="modeVisibleChange4")]
		}*/
		/** 用于同步两个界面的数据 **/
		public function get bBottomVisible():Boolean
		{
			return _bBottomVisible;
		}

		public function set bBottomVisible(value:Boolean):void
		{
			if( _bBottomVisible !== value)
			{
				_bBottomVisible = value;
				setModeFilter(4, !value);
				dispatchEvent(new Event("modeVisibleChange4"));
			}
		}


    }
}