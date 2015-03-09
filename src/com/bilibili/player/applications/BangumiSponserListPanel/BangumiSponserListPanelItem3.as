package com.bilibili.player.applications.BangumiSponserListPanel
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	/**
	 * 包养计划排名项列表, 1/2/3名专用
	 */
	public class BangumiSponserListPanelItem3 extends Sprite implements IBangumiSponserListPanelItem
	{
		private var image:Loader;
		private var imageURL:String = null;
		private var nameLabel:TextField;
		private var orderLayer:Sprite;
		private var orderLabel:TextField;
		private var messageLabel:TextField;
		private var messageLayer:Sprite;
		private var spaceURL:String = null;
		private var info:Object = null;
		
		private var hover:Boolean = false;
		
		public function BangumiSponserListPanelItem3()
		{
			var f:TextFormat = new TextFormat("simsun", 11, 0xffffff);

			orderLabel = new TextField();
			orderLabel.selectable = false;
			orderLabel.autoSize = TextFieldAutoSize.LEFT;
			orderLabel.mouseEnabled = false;
			
			orderLayer = new Sprite();
			
			nameLabel = new TextField();
			nameLabel.selectable = false;
			nameLabel.multiline = false;
			nameLabel.autoSize = TextFieldAutoSize.LEFT;
			nameLabel.mouseEnabled = false;
			
			messageLabel = new TextField();
			messageLabel.selectable = false;
			messageLabel.multiline = true;
			messageLabel.wordWrap = true;
			messageLabel.mouseEnabled = false;
			
			messageLayer = new Sprite;
			messageLayer.filters = [new DropShadowFilter(4, 45, 0, 0.382, 4, 4, 1)];
			
			orderLabel.defaultTextFormat = f;
			nameLabel.defaultTextFormat = f;
			messageLabel.defaultTextFormat = new TextFormat('simsun', 11, 0xa1a1a1, null, null, null, null, null, null, 3, 3, null, 3);
			
			image = new Loader();
			image.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			image.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errHandler);
			
			addChild(image);
			addChild(nameLabel);
			addChild(orderLayer);
			addChild(orderLabel);
			addChild(messageLayer);
			addChild(messageLabel);
			
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
			
			message = info.message;
			
			resize();
		}
		
		public function get view():DisplayObject
		{
			return this;
		}
		
		private function resize():void
		{
			var g:Graphics;
			
			orderLabel.x = 11;
			orderLabel.y = 30;
			
			orderLayer.x = orderLabel.x - 4.5; 
			orderLayer.y = orderLabel.y - 2;
			
			image.x = 15;
			image.y = 5;
//			if(anonymous)
//			{
//				image.x -= 5;
//				image.y -= 5;
//			}
			
			nameLabel.x = 66;
			nameLabel.y = 2;
			
			messageLayer.x = image.x + 51;
			messageLayer.y = image.y + 14;
			
			messageLabel.x = messageLayer.x;
			messageLabel.y = messageLayer.y + 2;
			messageLabel.width = 111;
			messageLabel.height = 33;
				 
			g = this.graphics;
			g.clear();
			if(hover) {
//				graphics.lineStyle(0, 0, 1, true);
				g.beginFill(0x0000ff, 0.2);
				g.drawRoundRect(0, 0,  185, 60, 4);
				g.endFill();
			}
			else {
				g.beginFill(0x004499, this.info ? (this.info.mine ? 0.2 : 0.0) : 0.0);
				g.drawRoundRect(0, 0,  185, 60, 0);
				g.endFill();
			}
			
			//头像描边
			var margin:Number = 3;
			//匿名没有头像描边
			if(spaceURL)
			{
				g.beginFill(0xffffff);
				g.drawRoundRect(image.x - margin, image.y - margin, image.width + margin * 2, image.height + margin * 2, 4, 4);
				g.endFill();
			}
			
			g = orderLayer.graphics;
			g.clear();
			
			margin = 2;
			//序号底色 白
			g.beginFill(0xffffff);
			g.drawRoundRect(0, 0, orderLabel.width + margin * 2 + 4, orderLabel.height + margin * 2, orderLabel.height + margin * 2);
			g.endFill();
			
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
			g.beginFill(bgcolor);
			g.drawRoundRect(margin, margin, orderLabel.width + 4, orderLabel.height, orderLabel.height);
			g.endFill();
			
			//消息底框
			g = messageLayer.graphics;
			g.clear();
			g.beginFill(0xffffff);
			g.drawRoundRect(0, 0, 111, 33, 8);
			g.moveTo(-8, 11);
			g.lineTo(0, 7);
			g.lineTo(0, 15);
			g.lineTo(-8, 11);
			g.endFill();
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
		
		private function get message():String
		{
			return messageLabel.text;
		}
		
		private function set message(value:String):void
		{
			if(!value || value.length == 0)
			{
				value = "没有留言。";
			}
			
			if(messageLabel.text != value)
			{
				messageLabel.text = value;
			}
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
				image.width = 42;
				image.height = 42;
			}
			else
			{
				image.width = 36;
				image.height = 36;
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