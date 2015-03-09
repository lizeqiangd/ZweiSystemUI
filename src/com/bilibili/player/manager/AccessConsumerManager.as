package com.bilibili.player.manager
{
	import com.bilibili.player.components.MukioTaskQueue;
	import com.bilibili.player.valueobjects.config.AccessConfig;
	import com.bilibili.player.net.api.BilibiliApi
	
	import flash.utils.Dictionary;
	
	/**
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 * 20140730
	 * 20141114 开始操作 新的权限管理器.
	 * 20141208 将taskqueue和AccessConsumerLoader整合进来
	 * 加载完成后会调用一次全局更新.主进程记得关注这个.
	 * 20141209 在加入后立刻调用一次,防止出现后声明对象无法接受到事件.
	 */
	public class AccessConsumerManager
	{
		
		private static var _accessConsumerFunctions:Dictionary = new Dictionary();
		private static var _accessConsumerFunctionTotal:uint
		
		/**
		 * 将方法添加进入权限管理其中.
		 * @param	_arg1
		 */
		public static function addAccessConfigChangeFunction(_arg1:Function):void
		{
			if (!(_accessConsumerFunctions[_arg1] is Function))
			{
				_accessConsumerFunctions[_arg1] = _arg1;
			}
			//active_now ? _arg1() : null
		}
		
		/**
		 * 将方法从权限管理器中移除.
		 */
		public static function removeAccessConfigChangeFunction(_arg1:Function):void
		{
			if ((_accessConsumerFunctions[_arg1] is Function))
			{
				_accessConsumerFunctions[_arg1] = null;
				delete _accessConsumerFunctions[_arg1];
			}
		}
		
		/**
		 * 权限更新的时候,可以调用这个方法会触发所有注册的方法.
		 */
		public static function updateAccessConfigRegister():void
		{
			var _local2:Function;
			for each (_local2 in _accessConsumerFunctions)
			{
				if ((_local2 is Function))
				{
					_local2();
				}
			}
		}
		
		/**
		 * 读取文件配置..
		 */
		public static function loadAccessConfig():void
		{
			trace("AccessConsumerManager.loadAccessConfig:start loading["+BilibiliApi.getVideoConfig(ValueObjectManager.getAppRouter)+"]")
			var tq:MukioTaskQueue = new MukioTaskQueue
			tq.beginLoad(BilibiliApi.getVideoConfig(ValueObjectManager.getAppRouter), function(data:Object):void
				{
					ValueObjectManager.getAccessConfig.$init(data)
					AccessConsumerManager.updateAccessConfigRegister()
					tq = null;
				})
			tq.work()
		}
		
		/**
		 * 获取AccessConfig
		 */
		public static function get getAccessConfig():AccessConfig
		{
			return ValueObjectManager.getAccessConfig
		}
	}
}
