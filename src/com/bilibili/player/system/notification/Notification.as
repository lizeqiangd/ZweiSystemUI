package com.bilibili.player.system.notification
{
	/** 滚动公告消息 **/
	public final class Notification
	{
		private var _text:String;
		private var _highlight:Boolean;
		private var _color:Object;
		private var _flash:Boolean;
		private var _tooltip:String = null;
		private var _catalog:String = NotificationType.NEWS;
		
		private var _visible:Boolean = true;
		
		public function Notification(text:String, highlight:Boolean=false, color:Object = null, flash:Boolean = false, tooltip:String=null, catalog:String=null)
		{
			/** 过滤掉开头的空白字符,以免产生空行 **/
			_text = text.replace(/^[\n\r\t ]+/, '');
			_highlight = highlight;
			_color = color;
			_flash = flash;
			_tooltip = tooltip;
			if(catalog != null)
			{
				_catalog = catalog;
			}
		}
		
		/** 用xml创建一个实例 **/
		public static function createFromXML(item:XML):Notification
		{
			var n:Notification = new Notification(String(item));
			n.highlight = String(item.@highlight) == 'true';
			if(item.@bgcolor.length())
			{
				var str:String = String(item.@bgcolor);
				str = str.replace('#', '0x');
				var num:Number = Number(str);
				if(!isNaN(num))
					n.bgColor = num; 
			}
			if(item.@tooltip.length())
			{
				n.tooltip = String(item.@tooltip);
			}
			if(item.@catalog.length())
			{
				n.catalog = String(item.@catalog);
			}
			n.flash = String(item.@flash) == 'true'
			return n;
		}

		/** html文本 **/
		public function get text():String
		{
			return _text;
		}

		/**
		 * @private
		 */
		public function set text(value:String):void
		{
			_text = value;
		}

		/** 是否高亮 **/
		public function get highlight():Boolean
		{
			return _highlight;
		}

		/**
		 * @private
		 */
		public function set highlight(value:Boolean):void
		{
			_highlight = value;
		}

		/** 自定义背景颜色 **/
		public function get bgColor():Object
		{
			return _color;
		}

		/**
		 * @private
		 */
		public function set bgColor(value:Object):void
		{
			_color = value;
		}

		/** 显示时是否闪烁 **/
		public function get flash():Boolean
		{
			return _flash;
		}

		/**
		 * @private
		 */
		public function set flash(value:Boolean):void
		{
			_flash = value;
		}

		/**
		 * 工具提示
		 **/
		public function get tooltip():String
		{
			return _tooltip;
		}

		public function set tooltip(value:String):void
		{
			_tooltip = value;
		}
		
		/**
		 * 消息分类(NotificationType成员):实时的消息有类别,可以决定是否接收
		 * system(系统通知)|bangumi(新番通知)|news(新闻的类别)
		 **/
		public function get catalog():String
		{
			return _catalog;
		}

		public function set catalog(value:String):void
		{
			_catalog = value;
		}

		/** 设置过滤标志,存储过滤结果 **/
		public function get visible():Boolean
		{
			return _visible;
		}

		/**
		 * @private
		 */
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}


	}
}