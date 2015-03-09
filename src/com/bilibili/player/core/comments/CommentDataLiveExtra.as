package com.bilibili.player.core.comments
{
	/**
	 * 直播广播弹幕的额外的信息
	 */
	public class CommentDataLiveExtra
	{
		public function CommentDataLiveExtra(options:Object=null)
		{
			if(options == null)
			{
				return;
			}
			
			for(var k:* in this) 
			{
				if(options.hasOwnProperty(k))
				{
					this[k] = options[k];
				}
			}
		}
		/**
		 * 会员昵称
		 */
		public var nickname:String;
		/**
		 * 会员id
		 */
		public var uid:String;
		/**
		 * 会员类型
		 */
		public var member_type:uint = CommentDataLiveExtraMemberType.MEMBER; 
	}
}