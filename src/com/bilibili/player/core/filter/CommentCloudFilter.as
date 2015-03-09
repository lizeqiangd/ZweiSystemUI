package com.bilibili.player.core.filter {
	/** 云屏蔽的实体:每一个云屏蔽文件对应一个实体 **/
	public class CommentCloudFilter extends RemoteFilter
	{
		/** 屏蔽的用户 **/
		protected var _userArr:Vector.<CommentFilterItem> = new Vector.<CommentFilterItem>();
		/** 屏蔽的关键字 **/
		protected var _textArr:Vector.<CommentFilterItem> = new Vector.<CommentFilterItem>();
		/** 云屏蔽级别 **/
		protected var _userLen:uint = 0;
		/** 云屏蔽级别 **/
		protected var _textLen:uint = 0;
		/** 云屏蔽级别 **/
		protected var _per:Number = 0.2;
		
		/**
		 * 构造一个云屏蔽实体
		 * @param provider 数据提供者
		 * @param url 该云屏蔽实体对应的资源url
		 * @param isCatalog 是否是分类的屏蔽(解析方法有点不一样)
		 * @param typeId 分类的id 
		 **/
		public function CommentCloudFilter(provider:RemoteLoader=null, url:String=null)
		{
			super(provider, url);
		}
		/** 载入完成并且开始解析 **/
		override public function parseItems(data:*):void
		{
			try
			{
				parseAssist(data);
			}
			catch(error:*)
			{
				trace(error);
			}
			/** 发送完成事件 **/
			super.parseItems(data);
		}
		/** 解析的辅助函数 **/
		protected function parseAssist(json:*):void
		{var i:uint=0
			var len:uint=0
			var item:CommentFilterItem
			if(json != null)
			{
				if(json.hasOwnProperty('user') && json.user is Array)
				{
					len= json.user.length;
					for(i = 0; i < len; i ++)
					{
						item = 
							new CommentFilterItem(CommentFilterMode.USER
								, json.user[i].value
								, json.user[i].cnt); 
						
						_userArr.push(item);
					}
				}
				if(json.hasOwnProperty('keyword') && json.keyword is Array)
				{
					len = json.keyword.length;
					for(i = 0; i < len; i ++)
					{
						if(json.keyword[i].value.length > 0)
						{
							item= 
								new CommentFilterItem(CommentFilterMode.TEXT
									, json.keyword[i].value
									, json.keyword[i].cnt); 
							
							_textArr.push(item);
						}
					}
				}
				/** 长度刷新后应该重新计算 **/
				setPercentage(_per);
			}
		}
		/** 设置过滤器的级别 **/
		public function setPercentage(per:Number):void
		{
			_per = per;
			_userLen = Math.floor(_userArr.length * _per);
			_textLen = Math.floor(_textArr.length * _per);
		}
		/** 
		 * 进行校验 
		 * @param item 弹幕数据
		 * @return true 表示通过
		 ***/
		override public function validate(item:Object):Boolean
		{
			var i:uint = 0;
			
			for(i = 0; i < _userLen; i ++)
			{
				if(item.userId == _userArr[i].value)
				{
					return false;
				}
			}
			
			for(i = 0; i < _textLen; i ++)
			{
				if( (item.text as String).indexOf(_textArr[i].value) != -1 )
				{
					return false;
				}
			}
			
			return true;
		}
		/** 屏蔽的用户 **/
		public function get userArr():Vector.<CommentFilterItem>
		{
			return _userArr;
		}
		/** 屏蔽的关键字 **/
		public function get textArr():Vector.<CommentFilterItem>
		{
			return _textArr;
		}
	}
}