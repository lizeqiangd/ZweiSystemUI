package com.bilibili.player.net.api
{
	import com.bilibili.player.core.utils.AppRouter;
	import com.bilibili.player.manager.ValueObjectManager;
	
	/**
	 * 所有涉及主站api地址的存放处
	 * @author Lizeqiangd
	 * 20141117 添加弹幕屏蔽列表地址.
	 * 20141208将AccessConfig的获取地址放入本地
	 */
	public class BilibiliApi
	{
		/**
		 * 视频屏蔽地址
		 */
		public static function get getVideoFilterUrl():String 
		{ 
			return 'http://comment.bilibili.tv/cloud/filter/' + ValueObjectManager.getAccessConfig.aid + '.json'
			//return ""
		}
		/**
		 * 类别屏蔽地址  遗弃
		 */
		public static function get getCatalogFilterUrl():String 
		{
			return 'http://comment.bilibili.tv/cloud/filter/catalogy.json'
		}
		/**
		 * 全局屏蔽地址 遗弃
		 */
		public static function get getGlobalFilterUrl():String 
		{
			return 'http://comment.bilibili.tv/cloud/filter/global.json'
		}
		/**
		 * 弹幕时间
		 */
		public static function  get getDMDuration():String{
			return "http://interface.bilibili.com/dmduration"
		}
		/**
		 * 暂停提示
		 */
		public static function get getPausePosition():String{
			return 'http://interface.bilibili.com/rec'
		}
		/**
		 * 弹幕屏蔽
		 */
		public static function get getCommentBlockAUrl():String{
			return "http://interface.bilibili.com/dmblock"
		}
		/**
		 * 取消屏蔽弹幕
		 */
		public static function get getCommentUnBlockAUrl():String{
			return "http://interface.bilibili.com/dmunblock"
		}
		/**
		 * 弹幕读取错误
		 */
		public static function get getCommentErrorUrl():String{
			return "http://interface.bilibili.com/dmerror"
		}
		
		/**
		 * 视频配置地址, $开头的方法只会在外面的一个地方使用
		 * @param appRouter 经过封装的flash参数
		 * @return 视频访问配置地址
		 **/
		public static function getVideoConfig(appRouter:AppRouter):String
		{
			/**
			 * 通用
			 * http://interface.bilibili.com/player?cid=542527
			 * http://interface.bilibili.com/player?id=cid:542527
			 **/
			var aidSeg:String = appRouter.aid == "" ? "" : "&aid=" + appRouter.aid;
			var cid:String = null;
			switch(appRouter.type)
			{
				case 'bili2':
				case 'letv':
					cid = 'cid:' + appRouter.cid;
					break;
				default:
					cid = appRouter.cid;
					break;
			}
			return 'http://interface.bilibili.com/player?id=' + cid + aidSeg;
		}
	}

}