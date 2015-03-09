package com.bilibili.player.applications.BangumiSponserListPanel
{	
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.bilibili.player.components.MukioTaskQueue;
	import com.bilibili.player.manager.AccessConsumerManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	//import org.lala.event.EventBus;
	//import org.lala.utils.MukioTaskQueue;
	
	//import tv.bilibili.components.interfaces.IBangumiSponserListPanelItem;
	//import tv.bilibili.net.AccessConfig;
	//import tv.bilibili.net.AccessConsumerManager;
	//import tv.bilibili.net.IAccessConfigConsumer;
	
	public class BangumiSponserListPanel extends BaseUI /*implements IAccessConfigConsumer*/
	{
		/**
		 * 黑屏视频地址
		 */
		public static const BLANK_VIDEO_URL:String = 'http://static.hdslb.com/30b.flv';
		/**
		 * 黑屏视频长度,秒
		 */
		public static const BLANK_VIDEO_LENGTH:uint = 30;
		
		//private var _accessConfig:AccessConfig = null;
		private var slLabel:SponsersLabel;
		
		private var loader22:Loader;
		private var loader33:Loader;
		
		/**
		 * 暂停时广告画面
		 */
		private var loaderImg:Loader;
		
		private var container:Sprite;
		/**
		 * for lazy render
		 */
		private var renderStart:Boolean = false;
		
		private var duration:Number = 0;
		private var videoDuration:Number = 0;
		
		/**
		 * 是否处于显示状态
		 */
		private var showed:Boolean = false;
		/**
		 * 容器
		 */
		private var theParent:DisplayObjectContainer = null;
		/**
		 * 容器层次
		 */
		private var childIndex:Number = 0;
		/**
		 * 用于显示的数据
		 */
		private var data:Object = null;
		/**
		 * 倒计时
		 */
		private var counterLabel:TextField;
		/**
		 * 经过本地时间校正后的目标时间戳/ms
		 */
		private var adjustedTarget:Number;
		/**
		 * 倒计时
		 */
		private var counterTimer:uint = 0;
		
		
		public function BangumiSponserListPanel(parent:DisplayObjectContainer, childIndex:Number)
		{
			theParent = parent;
			this.childIndex = childIndex;
			init();
			//AccessConsumerManager.regist(this);
			AccessConsumerManager.addAccessConfigChangeFunction(onAccessConfigUpdate)
		}
		
		public function onAccessConfigUpdate(/*accessConfig:AccessConfig*/):void
		{
			if(ValueObjectManager.getAccessConfig.cf)
			{
				loadList(ValueObjectManager.getAccessConfig.aid);
			}
			
			if(ValueObjectManager.getAccessConfig.start_date > 0 && ValueObjectManager.getAccessConfig.start_duration > 0)
			{
				adjustedTarget = (new Date()).getTime() + ValueObjectManager.getAccessConfig.start_duration * 1000;
				if(counterLabel == null)
				{
					counterLabel = (new CounterLabelFactory()).label1;
					counterLabel.mouseEnabled = false;
					//var tf:TextFormat = new TextFormat("微软雅黑", 16, 0xeeeeee, true);
					//counterLabel.defaultTextFormat = tf;
					counterLabel.autoSize = TextFieldAutoSize.LEFT;
					counterLabel.alpha = 0.8;
					counterLabel.filters = [new DropShadowFilter(0, 0, 0x000000, 0.5, 4, 4, 1)]
					theParent.addChildAt(counterLabel, 4);
				}
				clearInterval(counterTimer);
				counterTimer = setInterval(timerHandler, 1000);
			}
		}
		
		public function resize(parentWidth:Number, parentHeight:Number):void
		{
			var g:Graphics = graphics;
			var m:Matrix = new Matrix();
			m.createGradientBox(parentWidth, parentHeight, Math.PI / 2);
			
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, [0x03cfe4, 0x04a4d8, 0x0674b1], [1, 1, 1], [0, 128, 255], m);
			g.drawRect(0, 0, parentWidth, parentHeight);
			g.endFill();
			
			//600x400
			var ratio:Number = 1;
			if(parentHeight * 600 > parentWidth * 400)
			{
				ratio = parentWidth / 600;								
			}
			else
			{
				ratio = parentHeight / 400;
			}
			
			container.scaleX = container.scaleY = ratio;
			
			container.x = (parentWidth - container.width) / 2;
			container.y = (parentHeight - container.height) / 2;
			
			loaderImg.x = (parentWidth - loaderImg.width) / 2;
			loaderImg.y = (parentHeight - loaderImg.height) / 2;
		}
		/**
		 * 设置视频长度与末尾显示长度,单位:秒
		 */
		public function setup(videoDuration:Number, duration:Number=15):void
		{
			this.videoDuration = videoDuration;
			this.duration = duration;
		}
		/**
		 * 时间驱动显示
		 * @param time 时间, 单位:秒
		 */
		public function updateTime(time:Number):void
		{
			if(time + duration > videoDuration)
			{
				if(!showed)
				{
					showed = true;
					theParent.addChildAt(this, childIndex);
					
					if(counterLabel)
						counterLabel.visible = false;
					
					if(!renderStart)
					{
						renderStart = true;
						if(this.data)
						{
							render(this.data);
						}
					}
				}
			}
			else {
				if(showed && time != 0)
				{
					showed = false;
					theParent.removeChild(this);
					
					if(counterLabel)
						counterLabel.visible = true;
				}
			}
		}
		
		public function onPause(paused:Boolean):void
		{
			if(this.data && this.data.mine)
				return;
			
			if(paused)
			{
				if(!showed && !loaderImg.parent)
				{
					theParent.addChildAt(loaderImg, 2);
				}
			}
			else
			{
				if(loaderImg.parent)
				{
					theParent.removeChild(loaderImg);
				}
			}
		}
		
		private function loadList(aid:String):void
		{
			var task:MukioTaskQueue = new MukioTaskQueue();
			task.beginLoad("http://www.bilibili.com/widget/ajaxGetBP?aid=" + aid, completeHandler);
			task.work();
		}
		
		private function completeHandler(data:Object):void
		{
			try {
				data = JSON.parse(String(data));
			}
			catch (e:Error) {
				trace(e);
				return;
			}
			if(!data)
				return;

			try
			{
				if(ExternalInterface.available)
				{
					ExternalInterface.call('OnBpRankList', data);
				}
			}
			catch(e:Error) {}
			this.data = data;
			
			if(renderStart)
			{
				render(data);
			}
		}
		
		private function render(data:Object):void
		{
			var meOnList:Boolean = false;
			var list:Array = data.list.list as Array;
			//list.sortOn('rank', Array.NUMERIC);

			slLabel.label1.multiline = false;
			slLabel.label1.autoSize = TextFieldAutoSize.LEFT;
			slLabel.label1.text = "本集新番由以下 " + data.users + " 位承包商"
			slLabel.label1.x = -slLabel.label1.width / 2;
//			trace(slLabel.label1.x, slLabel.width, slLabel.label1.width);
			for(var i:uint = 0; i < list.length && i < 10; i ++)
			{
				if(data.mine && data.mine.uid == list[i].uid)
				{
					list[i].mine = true;
					meOnList = true;
				}
				
				list[i].rank = i + 1;
				var item:IBangumiSponserListPanelItem
				if(list[i].rank > 3)
				{
					item = new BangumiSponserListPanelItem2();
				}
				else
				{
					item = new BangumiSponserListPanelItem3();
				}
				item.setConfig(list[i]);
				setItemPosition(item.view, i, list.length);
				container.addChild(item.view);
			}
			
			//没有显示完全,添加省略号
			if(list.length < data.users)
			{
				var text:EllipsisLabel = new EllipsisLabel();
				text.label1.mouseEnabled = false;
				setItemPosition(text, i, list.length);
				text.y -= 5;
				text.x += 23;
				container.addChild(text);
			}
			
			if(data.mine && !meOnList) {
				var obj:Object = data.mine;
				obj.face = ValueObjectManager.getAccessConfig.face;
				obj.uname = ValueObjectManager.getAccessConfig.userName;
				obj.mine = true;
				item = new BangumiSponserListPanelItem2();
				item.setConfig(obj);
				setItemPosition(item.view, 11, list.length);
				container.addChild(item.view);
			}
			
			loader22.load(new URLRequest('http://static.hdslb.com/images/player/22.png'));
			loader33.load(new URLRequest('http://static.hdslb.com/images/player/33.png'));
		}
		
		private function init():void
		{
			container = new Sprite();
			container.mouseEnabled = false;
			addChild(container);
			
			var g:Graphics = container.graphics;
			g.beginFill(0x000000, 0.1);
			g.drawRect(0, 0, 600, 400);
			g.endFill();
			
			mouseEnabled = false;
			
			slLabel = new SponsersLabel();
			slLabel.mouseEnabled = slLabel.mouseChildren = false;
			slLabel.x = container.width / 2;
			slLabel.filters = [new flash.filters.DropShadowFilter(0, 0, 0xffffff, 1, 2, 2, 1)];
			container.addChild(slLabel);
			
			//2233娘
			loader22 = new Loader();
			loader22.contentLoaderInfo.addEventListener(Event.COMPLETE, loader22CompleteHandler);
			loader22.y = 200;
			loader22.x = 0;
			loader22.mouseEnabled = loader22.mouseChildren = false;
			container.addChild(loader22);
			
			loader33 = new Loader();
			loader33.contentLoaderInfo.addEventListener(Event.COMPLETE, loader33CompleteHandler);
			loader33.y = 200;
			loader33.x = 400;
			loader33.mouseEnabled = loader33.mouseChildren = false;
			container.addChild(loader33);
			
			loaderImg = new Loader();
			loaderImg.load(new URLRequest('http://static.hdslb.com/images/player/pool.jpg'));
			loaderImg.addEventListener(MouseEvent.CLICK, imageClickHandler);
		}
		
		private function setItemPosition(item:DisplayObject, index:uint, length:uint):void
		{
			if(index > 2)
			{
				item.x = slLabel.x + (Math.floor((index - 3) / 5) - 1) * 200;
				item.y = slLabel.y + slLabel.height + ((index - 3) % 5) * 40 + 80;
			}
			else
			{
				item.x = slLabel.x + index * 190 - 290 ;
				item.y = slLabel.y + slLabel.height + 5;
			}
		}
		
		private function loader22CompleteHandler(event:Event):void
		{
			loader22.width *= 0.6;
			loader22.height *= 0.6;
			
			loader22.x = 0;
			loader22.y = 400 - loader22.height;
		}
		
		private function loader33CompleteHandler(event:Event):void
		{
			loader33.width *= 0.6;
			loader33.height *= 0.6;
			
			loader33.x = 600 - loader33.width;
			loader33.y = 400 - loader33.height;
		}
		
		private function imageClickHandler(event:MouseEvent):void
		{
			var mx:Number = event.localX;
			var my:Number = event.localY;
			
			if(my <= 36 && mx + 36 >= loaderImg.width)
			{
				onPause(false);
			}
			else
			{
				try
				{
					if(ExternalInterface.available)
					{
						ExternalInterface.call('objBPPlugin.open');
					}
				}
				catch(e:Error)
				{
					
				}
				
				ValueObjectManager.getEventBus.sendMukioEvent('playerExitFullWin', true);
//				onPause(false);
			}
		}
		
		private function timerHandler():void
		{
			var timestamp:Number = (new Date()).getTime();
			var diff:Number = adjustedTarget - timestamp;
			if(diff <= 0)
			{
				clearInterval(counterTimer);
				counterTimer = 0;
				counterLabel.embedFonts = false;
				counterLabel.text = "新番已更新,请刷新页面";
				try
				{
					if(ExternalInterface.available)
					{
						ExternalInterface.call('objBPPlugin.reloadPage');
					}
				}
				catch(e:Error)
				{
					
				}
			}
			else
			{
				counterLabel.text = '离开播还剩 ' + formatDuration((adjustedTarget - timestamp) / 1000);
			}
		}
		
		private static function formatDuration(seconds:Number):String
		{
			seconds = Math.floor(seconds);
			var result:String = '';
			var i:uint = 0;
			while(i < 2)
			{
				var m:int = seconds % 60;
				seconds -= m;
				seconds /= 60;
				
				result = m + result;
				if(m < 10)
					result = '0' + result;
				
				if(seconds <= 0)
					break;
				result = ':' + result;
				i++;
			}
			if(seconds > 0)//hours
			{
				m = seconds % 24;
				seconds -= m;
				seconds /= 24;
				
				result = m + result;
				
				if(seconds > 0)//days
				{
					result = seconds + '天 ' + result;
				}
			}
			return result;
		}
	}
}