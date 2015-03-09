package com.bilibili.player.core.filter
{
	/** 
	 * 分类的云屏蔽:
	 * 唯一有用户屏蔽列表输出的云屏蔽类
	 * 用户的屏蔽不会被用户控制,一直开启;并且,屏蔽的flag是特有的
	 **/
	public class CatalogCloudFilter extends CommentCloudFilter
	{
		/** 分类屏蔽需要的参数 **/
		protected var typeId:uint = 0;
		
		/** 黑名单用户：不使用_userArr存储，以不显示于屏蔽列表中 **/
		protected var _blackList:Vector.<CommentFilterItem> = new Vector.<CommentFilterItem>();
		
		public function CatalogCloudFilter(provider:RemoteLoader=null, url:String=null, typeId:uint=0)
		{
			this.typeId = typeId;
			super(provider, url);
		}
		
		override protected function parseAssist(json:*):void
		{
			/** 分类屏蔽的解析:只有用户数据 **/
			if(json.hasOwnProperty('t' + typeId))
			{
				var list:Object = json['t' + typeId];
				if(list.hasOwnProperty('black_alias'))
				{
					//是个引用
					list = json['t' + list['black_alias']];
				}
				
				if(!list.hasOwnProperty('black') || !(list['black'] is Array))
				{
					//只处理一阶引用
					return;
				}
				
				var arr:Array = list['black'];
				for(var i:uint = 0; i < arr.length; i ++)
				{
					_blackList.push(new CommentFilterItem(CommentFilterMode.USER, arr[i], 0));
				}
			}
		}
		
		override public function validate(item:Object):Boolean
		{
			var len:uint = _blackList.length;
			for(var i:uint = 0; i < len; i ++)
			{
				if(item.userId == _blackList[i].value)
				{
					return false;
				}
			}
			return true;
		}
	}
}