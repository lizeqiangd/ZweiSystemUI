package com.bilibili.player.applications.BangumiSponserListPanel
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	/**
	 * 包养计划排名项列表
	 */
	public class BangumiSponserListPanelItem2 extends Sprite implements IBangumiSponserListPanelItem
	{
		private var image:Loader;
		private var imageURL:String = null;
		private var nameLabel:TextField;
		private var orderLabel:TextField;
		private var spaceURL:String = null;
		private var info:Object = null;
		
		private var hover:Boolean = false;
		
		public function BangumiSponserListPanelItem2()
		{
			var f:TextFormat = new TextFormat("simsun", 11, 0xffffff);

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
			image.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errHandler);
			
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
			orderLabel.x = 22;
			orderLabel.y = 11;
			
			image.x = 52;
			image.y = 6;
			if(anonymous)
			{
				image.x -= 5;
				image.y -= 5;
			}
			
			nameLabel.x = 86;
			nameLabel.y = 11;
			
			graphics.clear();
			if(hover) {
//				graphics.lineStyle(0, 0, 1, true);
				graphics.beginFill(0x0000ff, 0.2);
				graphics.drawRoundRect(0, 0,  200, 38, 4);
				graphics.endFill();
			}
			else {
				graphics.beginFill(0x004499, this.info ? (this.info.mine ? 0.2 : 0.0) : 0.0);
				graphics.drawRoundRect(0, 0,  200, 38, 0);
				graphics.endFill();
			}
			
			//头像描边
			var margin:Number = 3;
			graphics.beginFill(0xffffff);
			//匿名没有头像描边
			if(spaceURL)
			{
				graphics.drawRoundRect(image.x - margin, image.y - margin, image.width + margin * 2, image.height + margin * 2, 4, 4);
			}
			
			margin = 2;
			//序号底色 白
			graphics.drawRoundRect(orderLabel.x - margin - 2.5, orderLabel.y - margin, orderLabel.width + margin * 2 + 4, orderLabel.height + margin * 2, orderLabel.height + margin * 2);
			graphics.endFill();
			
			//序号底色 灰
			var bgcolor:uint = 0xa1a1a1;
			if(info)
			{
				switch(info.rank)
				{
					case 1:
						bgcolor = 0xff6780;
						break;
					case 2:
						bgcolor = 0x4fd158;
						break;
					case 3:
						bgcolor = 0xfec018;
						break;
				}
			}
			graphics.beginFill(bgcolor);
			graphics.drawRoundRect(orderLabel.x - 2.5, orderLabel.y, orderLabel.width + 4, orderLabel.height, orderLabel.height);
			graphics.endFill();
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
			orderLabel.text = value;
		}
		/**
		 * 头像地址
		 */
		private function set url(value:String):void
		{
			if(anonymous)
				value = 'http://static.hdslb.com/images/hidden42x40.png';
			
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
		 * 是否是匿名用户
		 */
		private function get anonymous():Boolean
		{
			return info && (info.uid == 0);
		}
		/**
		 * 头像加载完成,设置大小
		 */
		private function completeHandler(event:Event):void
		{
			if(anonymous)
			{
				image.width = 36;
				image.height = 36;
			}
			else
			{
				image.width = 25;
				image.height = 25;
			}
			
			resize();
		}
		/**
		 * 头像加载错误
		 */
		private function errHandler(event:ErrorEvent):void
		{
			trace(event);
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