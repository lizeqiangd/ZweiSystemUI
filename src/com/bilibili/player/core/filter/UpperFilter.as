package com.bilibili.player.core.filter {
	/**
	 * UP屏蔽列表
	 **/
	public class UpperFilter extends CommentCloudFilter
	{
		public function UpperFilter(provider:RemoteLoader = null, url:String=null):void
		{
			super(provider, url);
		}
		
		override protected function parseAssist(json:*):void
		{
			var data:Object = json['up'];	var item:CommentFilterItem
			if(data.hasOwnProperty('keyword'))
			{
				for each(var kw:String in data['keyword'])
				{
					item =
						new CommentFilterItem(CommentFilterMode.TEXT, kw, 0);
					_textArr.push(item);
				}
			}
			if(data.hasOwnProperty('user'))
			{
				for each(var user:String in data['user'])
				{
					item =
						new CommentFilterItem(CommentFilterMode.USER, user, 0);
					_userArr.push(item);
				}
			}
		}
		
		override public function setPercentage(per:Number):void
		{
			/** UP主屏蔽没有程序的区别 **/
		}
		
		/** 关键字作下则表达式处理 **/
		override public function validate(data:Object):Boolean
		{
			var i:uint = 0;
			var item:CommentFilterItem;
			
			for each(item in _userArr)
			{
				if(item.value == data.userId)
				{
					return false;
				}
			}
			
			for each(item in _textArr)
			{
				if((data.text as String).search(item.value) != -1)
				{
					return false;
				}
			}
			
			return true;
		}
	}
}