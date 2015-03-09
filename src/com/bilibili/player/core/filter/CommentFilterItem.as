package com.bilibili.player.core.filter {
	/** 云屏蔽的项目 **/
	public final class CommentFilterItem
	{
		protected var _type:uint;
		protected var _value:String;
		protected var _cnt:uint;
		/** 临时标志数据 **/
		private var _enabled:Boolean = false;
		
		public function CommentFilterItem(type:uint, value:String, cnt:uint)
		{
			_type = type;
			_value = value;
			_cnt = cnt;
		}

		/** 屏蔽类型:user/text,不支持正则表达式 **/
		public function get type():uint
		{
			return _type;
		}

		public function set type(value:uint):void
		{
			_type = value;
		}

		/** 屏蔽实体 **/
		public function get value():String
		{
			return _value;
		}

		public function set value(value:String):void
		{
			_value = value;
		}
		/** 屏蔽提交的人数 **/
		public function get cnt():uint
		{
			return _cnt;
		}

		public function set cnt(value:uint):void
		{
			_cnt = value;
		}

		/** 用于显示的可用性状态:在屏蔽程度更改时更改 **/
		public function get enabled():Boolean
		{
			return _enabled;
		}

		/**
		 * @private
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}

	}
}