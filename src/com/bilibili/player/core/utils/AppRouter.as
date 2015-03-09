package com.bilibili.player.core.utils
{
	import com.bilibili.player.manager.ValueObjectManager;
	import flash.display.LoaderInfo;
	import flash.utils.ByteArray;
	
	//import mx.utils.ObjectUtil;
	
	/**
	 * 播放器参数层,将外部的参数形式转换成内部的参数形式
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141113 修改到新路径,改为ValueObjectManager管理.
	 * 20141114 改为非构造函数初始化.
	 * 20141209 增加LoaderInfo引用
	 **/
	public class AppRouter
	{
		/**
		 * 原始的flashvars
		 **/
		protected var _params:Object;
		/** 已经解析后的内部参数  **/
		protected var _args:Object;
		/** 提供主swf的loaderinfo引用 **/
		protected var _loaderinfo:LoaderInfo
		
		/**
		 * 构造函数
		 * @param params 播放器的loaderInfo.parameters(即flashvars)
		 **/
		public function init(params:Object):void
		{
			var ba:ByteArray = new ByteArray;
			ba.writeObject(params);
			ba.position = 0;
			_params = ba.readObject();
			_args = parseParameters(_params);
			//也许有aid这个参数,用于反馈请求权限文件
			_args.aid = _params.aid == null ? "" : _params.aid;
			_args.no_comments_covered = _params.no_covered == '1'; //弹幕不覆盖
		}
		
		/**
		 * 将loaderinfo绑定
		 */
		public function initByLoaderInfo(e:LoaderInfo):void
		{
			_loaderinfo = e
			if (!ValueObjectManager.debug) {
				init(e.parameters)
			}
		}
		
		/**
		 * 解析flashvars成内部形式
		 * @param p flashvars
		 * @return {type:(视频源类型),vid:(视频源参数),cid:(弹幕id)}
		 **/
		protected function parseParameters(p:Object):Object
		{
			var type:String = '';
			var vtype:String = '';
			var vid:String = '';
			var cid:String = '';
			
			/**
			 * cid:新的封装参数,用于播放视频,弹幕相关参数
			 * http://interface.bilibili.com/playurl?cid=<cid>,格式为sina格式
			 * http://interface.bilibili.com/player?id=cid:<cid>,配置文件
			 * vtype:用于显示来源
			 * vid:用于获取用户配置(直接用cid可能会有冲突)
			 * 加速缓存也可以用cid
			 **/
			if (p['cid'])
			{
				type = "bili2";
				vtype = p['vtype'];
				vid = p['cid']
				cid = p['cid'];
			}
			else if (p['lid'])
			{
				type = "letv";
				vid = p['lid']
				cid = vid;
			}
			else if (p['vid'])
			{
				type = 'sina';
				vid = p['vid'];
				cid = vid;
			}
			else if (p['file'])
			{
				type = 'video';
				vid = p['file'];
				cid = p['id'];
			}
			else if (p['avid'])
			{
				type = 'bili';
				vid = p['avid'];
				cid = vid;
			}
			else if (p['qid'])
			{
				type = 'qq';
				vid = p['qid'];
				cid = vid;
			}
			else if (p['ykid'])
			{
				type = 'youku';
				vid = p['ykid'];
				cid = vid;
			}
			else if (p['uid'])
			{
				type = 'tudou';
				vid = p['uid'];
				cid = vid;
			}
			else if (p['rid'])
			{
				type = 'redirect';
				vid = p['rid'];
				cid = vid;
			}
			else if (p['bid'])
			{
				type = 'stream';
				vid = p['bid'];
				cid = vid;
			}
			//文章页面,page存储在cid中,需要二次路由
			else if (p['aid'])
			{
				type = 'page';
				vid = p['aid'];
				cid = p['page'];
			}
			else
			{
				type = 'error';
				vid = '无效的参数.';
				cid = '';
			}
			return {'type': type, 'vtype': vtype, 'vid': vid, 'cid': cid};
		}
		
		/** 内部的视频源类型  **/
		public function get type():String
		{
			return _args.type;
		}
		
		/** 内部的视频源参数  **/
		public function get vid():String
		{
			return _args.vid;
		}
		
		/** 弹幕id,用于加载弹幕  **/
		public function get cid():String
		{
			return _args.cid;
		}
		
		/** cid下的视频video type **/
		public function get vtype():String
		{
			return _args.vtype;
		}
		
		/** 视频aid,用于请求权限文件 **/
		public function get aid():String
		{
			return _args.aid;
		}
		
		/**
		 * 是否覆盖弹幕到视频上
		 */
		public function get no_comments_covered():Boolean
		{
			return _args.no_comments_covered;
		}
		
		/** 返回loaderInfo **/
		public function get loaderInfo():LoaderInfo
		{
			return _loaderinfo
		}
		
		public function toString():String
		{
			return 'AppRouter:{type:' + type + '\nvtype:' + vtype + '\nvid:' + vid + '\ncid:' + cid + '\n}';
		}
	}
}