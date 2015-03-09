package com.bilibili.player.valueobjects.config
{
	
	/**
	 * bilibili视频与用户的
	 * 权限配置
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141113 删除本应该不属于本类的资源.让其变得更有逻辑??
	 * 20141128 先将a9姥爷最新的代码合并进来再进行考虑其他因素.
	 * 20141208恩...从loader加载.放入manager最后再全局广播...这难道不只是一个配置文件么..为什么还有加载功能??url转移到了bilibiliapi里面
	 **/
	public class AccessConfig
	{
		/** 主站网站 **/
		public static const HOST:String = 'http://www.bilibili.com';
		protected var _login:Boolean = false;
		protected var _userName:String = '';
		protected var _userId:int = 0;
		protected var _scores:Number = 0;
		protected var _money:Number = 0;
		protected var _pwd:String = '';
		protected var _isAdmin:Boolean = false;
		protected var _permission:String = '';
		protected var _level:String = '';
		protected var _shot:Boolean = false;
		protected var _chatId:int = 0;
		protected var _aid:String = '';
		protected var _partId:uint = 1;
		protected var _click:uint = 0;
		protected var _fwClick:uint = 0;
		protected var _dammu:uint = 0;
		protected var _acceptGuest:Boolean = true;
		protected var _duration:String = '';
		protected var _country:String = '';
		protected var _acceptAccel:Boolean = false;
		protected var _cached:Boolean = false;
		protected var _server:String = '';
		protected var _isSystemAdmin:Boolean = false;
		protected var _typeId:uint = 0;
		
		protected var _favourites:uint = 0;
		protected var _coins:uint = 0;
		protected var _credits:uint = 0;
		
		protected var _lastplaytime:uint = 0;
		protected var _face:String = '';
		protected var _sinapi:Boolean = true;
		
		protected var _arcType:String = ArcType.UNKNOW;
		protected var _rank:String = '';
		protected var _bottomBlank:Boolean = false;
		
		/** 注册用户 **/
		private var _registered:Boolean = true;
		/**
		 * 用户角色
		 * 值为tv.bilibili.utils.UserRole
		 **/
		protected var _role:uint = 0;
		/**
		 * 实际的用户id,随机数
		 **/
		protected var _randId:uint;
		protected var _vtype:String = '';
		
		/**
		 * 排行信息:Number
		 */
		protected var _currentPtsRank:Number;
		protected var _highestPtsRank:Number;
		/**
		 * 禁言时间/s
		 */
		protected var _blockTime:Number;
		/**
		 * 广告信息
		 */
		private var _rggImg:String;
		private var _rggURL:String;
		private var _rggNum:uint;
		/**
		 * 视频来源地址
		 */
		private var _oriPageUrl:String = '';
		/**
		 * 是否是承包计划视频: crowdfunding
		 */
		private var _cf:Boolean = false;
		/**
		 * 是否允许投bp
		 */
		private var _allow_bp:Boolean;
		/**
		 * 新番开始时间/timestamp/s, 已经开始不输出
		 */
		private var _start_date:Number;
		/**
		 * 还有多少时间开始/s, 已经开始不输出
		 */
		private var _start_duration:Number;
		/**
		 * 是否有推荐弹幕
		 * @see org.lala.net.CommentProvider#dispatchCommentData
		 */
		private var _suggest_comment:Boolean = false;
		/**
		 * 弹幕上限
		 */
		private var _maxlimit:Number = 1500;
		
		/**
		 * @param rt 参数信息
		 **/
		public function AccessConfig()
		{
			_randId = int(Math.random() * int.MAX_VALUE);
		}
		
		/**
		 * 视频配置地址, $开头的方法只会在外面的一个地方使用
		 * @param appRouter 经过封装的flash参数
		 * @return 视频访问配置地址
		 **/
//		public function $getURL(appRouter:AppRouter):String
//		{
//			/**
//			 * 通用
//			 * http://interface.bilibili.com/player?cid=542527
//			 * http://interface.bilibili.com/player?id=cid:542527
//			 **/
//			var aidSeg:String = appRouter.aid == "" ? "" : "&aid=" + appRouter.aid;
//			var cid:String = null;
//			switch(appRouter.type)
//			{
//				case 'bili2':
//				case 'letv':
//					cid = 'cid:' + appRouter.cid;
//					break;
//				default:
//					cid = appRouter.cid;
//					break;
//			}
//			return 'http://interface.bilibili.com/player?id=' + cid + aidSeg;
//		}
		/**
		 * 初始化权限值, $开头的方法只会在外面的一个地方使用
		 * @param data 加载的权限配置文本,rpc格式
		 **/
		public function $init(data:*):void
		{
			trace("AccessConfig.$init:start parsing...")
			var xml:XML
			try
			{
				xml = new XML('<root>' + data + '</root>');
			}
			catch (error:Error)
			{
				var elem:XML
				//				trace('格式不规范或者无法获取用户配置,尝试修复...');
				if (data === null)
					xml =  <root></root>; //配置无法获取
				else
					data = String(data);
				
				if (data !== null)
				{
					var p:RegExp = /<([^>\/]+)>(.*?)<\/\s*\1\s*>/ig;
					var p2:RegExp = /<([^<]+?)\/>/ig;
					xml =  <root></root>;
					var ret:Object= p.exec(data);
					while(ret)
					{
						elem = new XML('<' + ret[1] + '/>');
						elem.appendChild(ret[2]);
						xml.appendChild(elem);
						trace(ret);
					}
					ret= p2.exec(data)
					while (ret )
					{
						try
						{
							elem = new XML(ret[0]);
							xml.appendChild(elem);
						}
						catch (e:*)
						{
						}
						trace(ret);
					}
				}
			}
			initByXML(xml);
		}
		
		/**
		 * 使用XML初始化
		 **/
		protected function initByXML(xml:XML):void
		{
			_login = String(xml.login) == 'true';
			_userName = String(xml.name);
			_userId = int(xml.user);
			_scores = Number(xml.scores);
			_money = Number(xml.money);
			_pwd = String(xml.pwd);
			_isAdmin = String(xml.isadmin) == 'true';
			setPermission(String(xml.permission));
			_level = String(xml.level);
			_shot = String(xml.shot) == 'true';
			_chatId = int(xml.chatid);
			_aid = String(xml.aid);
			_partId = uint(xml.pid);
			_click = uint(xml.click);
			_fwClick = uint(xml.fw_click);
			_dammu = uint(xml.danmu);
			_acceptGuest = String(xml.acceptguest) == 'true';
			_duration = String(xml.duration);
			_country = String(xml.country);
			_acceptAccel = String(xml.acceptaccel) == 'true';
			_cached = String(xml.cache) == 'true';
			_server = String(xml.server);
			
			_favourites = uint(xml.favourites);
			_coins = uint(xml.coins);
			_credits = uint(xml.credits);
			
			_typeId = uint(xml.typeid);
			
			_face = String(xml.face);
			
			_sinapi = String(xml.sinapi) == '1';
			
			_arcType = String(xml.arctype);
			_rank = String(xml.rank);
			_bottomBlank = String(xml.bottom) == 'true' || String(xml.bottom) == '1';
			
			var pers:Array = _permission.split(',');
			if (pers.indexOf('32000') != -1 || pers.indexOf('31300') != -1)
			{
				_isSystemAdmin = true;
			}
			else
			{
				_isSystemAdmin = false;
			}
			
			/** 注册会员rank 5000 **/
			if (pers.indexOf('5000') != -1)
			{
				_registered = true;
			}
			else
			{
				_registered = false;
			}
			
			_lastplaytime = uint(xml.lastplaytime);
			_vtype = String(xml.vtype);
			
			var tmp:XMLList = xml.honor.(@t == "click");
			_currentPtsRank = Number(tmp[tmp.length() - 1]);
			
			tmp = xml.honor.(@t == "credit");
			_highestPtsRank = Number(tmp[tmp.length() - 1]);
			
			_rggImg = String(xml.rgg.@img);
			_rggURL = String(xml.rgg.@url);
			_rggNum = uint(xml.rgg.@rggnum);
			
			_oriPageUrl = String(xml.oriurl);
			_blockTime = Number(xml.block_time);
			if (_blockTime <= 0 || isNaN(_blockTime))
			{
				_blockTime = 0;
			}
			else
			{
				_blockTime -= (new Date()).getTime() / 1000;
				_blockTime = _blockTime > 0 ? _blockTime : 0;
			}
			
			_allow_bp = String(xml.allow_bp) == 'true';
			_cf = _allow_bp;
			_start_date = Number(xml.start_date);
			_start_duration = Number(xml.start_duration);
			_suggest_comment = String(xml.suggest_comment) == 'true';
			_maxlimit = Number(xml.maxlimit);
		}
		
		/**
		 * 是否登录
		 **/
		public function get login():Boolean
		{
			return _login;
		}
		
		/**
		 * 是否是注册用户(非正式)
		 */
		public function get registered():Boolean
		{
			return _registered;
		}
		
		/**
		 * 用户名
		 **/
		public function get userName():String
		{
			return _userName;
		}
		
		/**
		 * 用户id
		 **/
		public function get userId():int
		{
			return _userId;
		}
		
		/**
		 * 分数
		 **/
		public function get scores():Number
		{
			return _scores;
		}
		
		/**
		 * 硬币
		 **/
		public function get money():Number
		{
			return _money;
		}
		
		/**
		 * pwd
		 **/
		public function get pwd():String
		{
			return _pwd;
		}
		
		/**
		 * 管理权限
		 **/
		public function get isAdmin():Boolean
		{
			return _isAdmin;
		}
		
		/**
		 * 权限值字符串
		 **/
		public function get permission():String
		{
			return _permission;
		}
		
		/**
		 * @private
		 **/
		private function setPermission(value:String):void
		{
			_permission = value;
			var arr:Array = value.split(',');
			if (value == '' || arr.indexOf('9999') != -1)
			{
				_role = UserRole.LIMITED;
				return;
			}
			if (arr.indexOf('5000') != -1)
			{
				_role = UserRole.REGISTERED;
				return;
			}
			if (arr.indexOf('20000') != -1 || arr.indexOf('32000') != -1 || arr.indexOf('31300') != -1)
			{
				_role = UserRole.ADVANCED;
				return;
			}
			if (arr.indexOf('30000') != -1 || arr.indexOf('25000') != -1)
			{
				_role = UserRole.VIP;
				return;
			}
			_role = UserRole.NORMAL;
		}
		
		/**
		 * 会员等级
		 **/
		public function get level():String
		{
			return _level;
		}
		
		/**
		 * shot
		 **/
		public function get shot():Boolean
		{
			return _shot;
		}
		
		/**
		 * 聊天频道
		 **/
		public function get chatId():int
		{
			return _chatId;
		}
		
		/**
		 * 视频cid
		 **/
		public function get cid():String
		{
			return _chatId.toString();
		}
		
		/**
		 * 文章id
		 **/
		public function get aid():String
		{
			return _aid;
		}
		
		/**
		 * 章节序号,1-n
		 **/
		public function get partId():uint
		{
			return _partId;
		}
		
		/**
		 * 播放次数
		 **/
		public function get click():uint
		{
			return _click;
		}
		
		/**
		 * 转发点击?
		 **/
		public function get fwClick():uint
		{
			return _fwClick;
		}
		
		/**
		 * 弹幕数
		 **/
		public function get dammu():uint
		{
			return _dammu;
		}
		
		/**
		 * 允许游客
		 **/
		public function get acceptGuest():Boolean
		{
			return _acceptGuest;
		}
		
		/**
		 * 视频长度
		 * 00:00
		 **/
		public function get duration():String
		{
			return _duration;
		}
		
		/**
		 * country
		 **/
		public function get country():String
		{
			return _country;
		}
		
		/**
		 * 允许加速
		 **/
		public function get acceptAccel():Boolean
		{
			return _acceptAccel;
		}
		
		/**
		 * server
		 * 服务器名
		 **/
		public function get server():String
		{
			return _server;
		}
		
		/**
		 * 随机id
		 **/
		public function get randId():uint
		{
			return _randId;
		}
		
		public function toString():String
		{
			return JSON.stringify(this);
		}
		
		/**
		 * 用户角色
		 **/
		public function get role():uint
		{
			return _role;
		}
		
		/** 是否是系统管理员 **/
		public function get isSystemAdmin():Boolean
		{
			return _isSystemAdmin;
		}
		
		/** 可能拥有特殊弹幕权限的角色 **/
		public function get advancedCommentEnabled():Boolean
		{
			return this.role != UserRole.LIMITED && this.role != UserRole.REGISTERED;
		}
		
		/** 可能拥有脚本弹幕权限的角色 **/
		public function get scriptCommentEnabled():Boolean
		{
			return this.isAdmin || this.role == UserRole.ADVANCED || this.role == UserRole.VIP || this.role == UserRole.NORMAL;
		}
		
		/**
		 * 是否已经做好国外加速的缓存
		 **/
		public function get cached():Boolean
		{
			return _cached;
		}
		
		/**
		 * 视频收藏数
		 **/
		public function get favourites():uint
		{
			return _favourites;
		}
		
		/**
		 * 视频硬币数
		 **/
		public function get coins():uint
		{
			return _coins;
		}
		
		/**
		 * 视频积分
		 **/
		public function get credits():uint
		{
			return _credits;
		}
		
		/** 视频分类的id **/
		public function get typeId():uint
		{
			return _typeId;
		}
		
		/** 上次暂停时记录的播放时间 **/
		public function get lastplaytime():uint
		{
			return _lastplaytime;
		}
		
		/**
		 * @private
		 */
		protected function set lastplaytime(value:uint):void
		{
			_lastplaytime = value;
		}
		
		/**
		 * 头像图片地址
		 **/
		public function get face():String
		{
			return _face;
		}
		
		/** 是否使用sina api **/
		public function get sinapi():Boolean
		{
			return _sinapi;
		}
		
		/** 原创与否:Copy,Unknow,Original:ArcType的成员 **/
		public function get arcType():String
		{
			return _arcType;
		}
		
		/** 用户阶,permisson除了其他控制代码 **/
		public function get rank():String
		{
			return _rank;
		}
		
		/** UP主控制的不挡字幕的设定 **/
		public function get bottomBlank():Boolean
		{
			return _bottomBlank;
		}
		
		/**
		 * @private
		 */
		public function set bottomBlank(value:Boolean):void
		{
			_bottomBlank = value;
		}
		
		/**
		 * 视频源类型
		 **/
		public function get vtype():String
		{
			return _vtype;
		}
		
		/**
		 * 视频的主站地址
		 */
		public function get url():String
		{
			var s:String = 'http://www.bilibili.com/video/av' + aid + '/';
			if (partId > 1)
			{
				s += 'index_' + partId + '.html'
			}
			return s;
		}
		
		/**
		 * share url
		 */
		public function get shareUrl():String
		{
			var s:String = 'http://acg.tv/av' + aid;
			if (partId > 1)
			{
				s += ',' + partId;
			}
			return s;
		}
		
		/**
		 * 视频信息api地址
		 */
		public function get apiUrl():String
		{
			return 'http://api.bilibili.com/view?type=json&appkey=8e9fc618fbd41e28&id=' + aid + '&page=' + partId;
		}
		
		/**
		 * 弹幕post地址
		 */
		public function get commentPostUrl():String
		{
			return 'http://interface.bilibili.com/dmpost';
		}
		
		/**
		 * 滚动消息地址
		 */
		public function get tipsUrl():String
		{
			return 'http://interface.bilibili.com/msg.xml';
		}
		
		/**
		 * 分P信息的地址
		 */
		public function get pageListUrl():String
		{
			return 'http://www.bilibili.com/widget/getPageList?aid=' + aid;
		}
		
		/**
		 * 当前pts排行
		 */
		public function get currentPtsRank():Number
		{
			return _currentPtsRank;
		}
		
		/**
		 * 历史最高pts排行
		 */
		public function get highestPtsRank():Number
		{
			return _highestPtsRank;
		}
		
		/** 广告图片 **/
		public function get rggImg():String
		{
			return _rggImg;
		}
		
		/** 广告链接目标 **/
		public function get rggURL():String
		{
			return _rggURL;
		}
		
		/** 广告数目 **/
		public function get rggNum():uint
		{
			return _rggNum;
		}
		
		/**
		 * 视频来源页面地址
		 */
		public function get oriPageUrl():String
		{
			return _oriPageUrl;
		}
		
		/**
		 * 禁言时间/s
		 */
		public function get blockTime():Number
		{
			return _blockTime;
		}
		
		/**
		 * 是否是承包计划视频
		 */
		public function get cf():Boolean
		{
			return _cf;
		}
		
		/**
		 * 是否允许投bp
		 */
		public function get allow_bp():Boolean
		{
			return _allow_bp;
		}
		
		/**
		 * 新番开始时间, timestamp, s, 开始后为0
		 */
		public function get start_date():Number
		{
			return _start_date;
		}
		
		/**
		 * 还有多少时间开始/s, 已经开始后为0
		 */
		public function get start_duration():Number
		{
			return _start_duration;
		}
		
		/**
		 * 是否有推荐弹幕
		 */
		public function get suggest_comment():Boolean
		{
			return _suggest_comment;
		}
		
		/**
		 * 弹幕上限
		 */
		public function get maxlimit():Number
		{
			return _maxlimit;
		}
	}
}