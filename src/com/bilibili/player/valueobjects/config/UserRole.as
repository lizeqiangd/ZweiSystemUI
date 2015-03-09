package com.bilibili.player.valueobjects.config 
{
	/**
	 * 用户角色
	 **/
	public class UserRole
	{
		private static var initial:uint = 0;
		/**
		 * 受限用户:未登录,适应期用户
		 **/
		public static const LIMITED:uint = initial ++;
		/**
		 * 注册用户
		 */
		public static const REGISTERED:uint = initial ++; 
		/**
		 * 正式用户
		 **/
		public static const NORMAL:uint = initial ++;
		/**
		 * vip,真*职人,权限小于字幕君
		 **/
		public static const VIP:uint = initial ++;
		/**
		 * 字幕君,管理员
		 **/
		public static const ADVANCED:uint = initial ++;
	}
}