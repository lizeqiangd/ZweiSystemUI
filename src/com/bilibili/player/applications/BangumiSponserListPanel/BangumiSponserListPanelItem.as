package com.bilibili.player.applications.BangumiSponserListPanel
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	/**
	 * 包养计划排名项列表
	 */
	public class BangumiSponserListPanelItem extends Sprite implements IBangumiSponserListPanelItem
	{
		private var image:Loader;
		private var imageURL:String = null;
		private var nameLabel:TextField;
		private var orderLabel:TextField;
		private var spaceURL:String = null;
		private var info:Object = null;
		
		private var hover:Boolean = false;
		
		public function BangumiSponserListPanelItem()
		{
			var f:TextFormat = new TextFormat("微软雅黑,simsun", 14, 0xffffff);

			orderLabel = new TextField();
			orderLabel.selectable = false;
			orderLabel.autoSize = TextFieldAutoSize.LEFT;
			orderLabel.mouseEnabled = false;
			
			nameLabel = new TextField();
			nameLabel.selectable = false;
			nameLabel.multiline = false;
			nameLabel.autoSize = TextFieldAutoSize.LEFT;
			nameLabel.mouseEnabled = false;
			
			orderLabel.defaultTextFormat = f;
			nameLabel.defaultTextFormat = f;
			
			image = new Loader();
			image.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			
			addChild(orderLabel);
			addChild(image);
			addChild(nameLabel);
			
			buttonMode = true;
			useHandCursor = true;
			
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		public function setConfig(info:Object):void
		{
			this.info = info;
			
			username = info.uname;
			order = info.rank;
			url = info.face;
			
			if(info.uid)
				spaceURL = 'http://space.bilibili.com/' + info.uid;
			else
				spaceURL = null;
			
			resize();
		}
		
		public function get view():DisplayObject
		{
			return this;
		}
		
		private function resize():void
		{
			orderLabel.x = 20;
			orderLabel.y = 8;
			
			image.x = 50;
			image.y = 3;
			
			nameLabel.x = 100;
			nameLabel.y = 8;
			
			graphics.clear();
			if(hover) {
//				graphics.lineStyle(0, 0, 1, true);
				graphics.beginFill(0x0000ff, 0.2);
				graphics.drawRoundRect(0, 0,  200, 38, 0);
				graphics.endFill();
			}
			else {
				graphics.beginFill(0x004499, this.info ? (this.info.mine ? 0.2 : 0.0) : 0.0);
				graphics.drawRoundRect(0, 0,  200, 38, 0);
				graphics.endFill();
			}
		}
		/**
		 * 用户名称
		 */
		private function get username():String
		{
			return nameLabel.text;	
		}
		
		private function set username(value:String):void
		{
			if(!(value is String))
				return;
			
			nameLabel.text = foldText(value, nameLabel.defaultTextFormat, 100);
		}
		/**
		 * 排名序号
		 */
		private function get order():String
		{
			return orderLabel.text;
		}
		
		private function set order(value:String):void
		{
			if(value == '1' || value == '2' || value == '3')
			{
				orderLabel.text = ' ' + value + ' ';
				orderLabel.background = true;
				orderLabel.backgroundColor = 0xffb700;
			}
			else
			{
				orderLabel.text = ' ' + value + ' ';
				orderLabel.background = false;
			}
		}
		/**
		 * 头像地址
		 */
		private function set url(value:String):void
		{
			if(value !== imageURL)
			{
				imageURL = value;
				image.load(new URLRequest(imageURL));
			}
		}
		
		private function get url():String
		{
			return imageURL;
		}
		/**
		 * 头像加载完成,设置大小
		 */
		private function completeHandler(event:Event):void
		{
			image.width = 32;
			image.height = 32;
		}
		
		/**
		 * 鼠标经过效果
		 */
		private function overHandler(event:MouseEvent):void
		{
			hover = true;
			resize();
		}
		/**
		 * 鼠标移出效果
		 */
		private function outHandler(event:MouseEvent):void
		{
			hover = false;
			resize();
		}
		/**
		 * 点击跳转到用户空间
		 */
		private function clickHandler(event:MouseEvent):void
		{
			if(spaceURL)
			{
				navigateToURL(new URLRequest(spaceURL), '_blank');
				if(stage.displayState !== StageDisplayState.NORMAL)
				{
					stage.displayState = StageDisplayState.NORMAL;
				}
			}
		}
		
		private static function foldText(str:String, tf:TextFormat, widthPixel:uint):String
		{
			var t:TextField = new TextField();
			t.defaultTextFormat = tf;
			t.text = str;
			t.autoSize = TextFieldAutoSize.LEFT;
			
			while(t.width > widthPixel) {
				t.text = t.text.substr(0, t.text.length - 1);
			}
			return t.text + (t.text.length == str.length ? '' : '...');
		}
	}
}