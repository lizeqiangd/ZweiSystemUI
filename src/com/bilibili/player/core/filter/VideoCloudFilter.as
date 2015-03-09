package com.bilibili.player.core.filter {
	/** 视频的云屏蔽 **/
	public class VideoCloudFilter extends CommentCloudFilter
	{
		public function VideoCloudFilter(provider:RemoteLoader=null, url:String=null)
		{
			super(provider, url);
		}
		
		override protected function parseAssist(json:*):void
		{
			super.parseAssist(json['cloud']);
		}
	}
}