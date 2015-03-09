package com.bilibili.player.abstract.windows
{
	import com.bilibili.player.events.ApplicationEvent;
	import com.bilibili.player.components.texteffect.TextAnimation;
	import com.bilibili.player.system.config.BPTextFormat;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	
	/** TitleWindows 有标题和关闭按钮的窗口
	 * 2013.01.27 整理函数代码，修改应用事件
	 * 2014.03.28 重新整理代码,添加注释以及修正路径.
	 */
	public class TitleWindows extends DragWindows
	{
		private var _applicationTitle:String = ""
		public var tx_title:TextField
//		public var btn_close
		
		private var orignalTitle:String = ""
		private var isInited:Boolean = false
		
		/**
		 *TitleWindows构造函数,添加2个侦听器:程序开始关闭,程序完全打开,程序初始化完成.
		 */
		public function TitleWindows()
		{
			tx_title = new TextField 
			tx_title.defaultTextFormat = BPTextFormat.LightBlueTitleTextFormat
			this.addEventListener(ApplicationEvent.CLOSE, onTitleWindowsCloseHandle);
			this.addEventListener(ApplicationEvent.OPENED, onTitleWindowsOpenedHandle);
			this.addEventListener(ApplicationEvent.INITED, onTitleWindowsInitedHandle);
		}
		
		override public function configWindows(_w:Number, _h:Number):void
		{			
			this.configBaseUi(_w, _h)
			this.createFrame(true)
			sp_frame.graphics.moveTo(0, 20)
			sp_frame.graphics.lineTo(_w, 20)
			this.createBackground(0.7)
			tx_title.width = _w
			addChild(tx_title)
		}
		
		/**
		 * 当程序完全打开的时候的事件,对标题文字取消鼠标事件,同时修改标题为初始化文字.
		 */
		private function onTitleWindowsOpenedHandle(e:ApplicationEvent):void
		{			
			try
			{
				orignalTitle = tx_title.text;
				tx_title.text = "Initializing.";
				tx_title.mouseEnabled = false;
			}
			catch (e:*)
			{
				trace("TitleWindows配置错误，找不到需要的实例,请检查是否放置tx_title");
			}
		
		}
		
		/**
		 * 当程序初始化完成的时候,会对标题建立拖拽侦听.使能端跟随DragWindows. 同时会对标题的文字激活一次动画效果.
		 */
		private function onTitleWindowsInitedHandle(e:ApplicationEvent):void
		{
			try
			{
				//getChildByName(TitleWindows._btn_close).addEventListener(MouseEvent.CLICK, onTitleWindowsCloseButtonClickHangle);
				
			}
			catch (e:*)
			{
				trace("TitleWindows配置错误，找不到需要的实例,请检查是否放置btn_close");
			}
			try
			{
				
				//getChildByName(TitleWindows._mc_title).addEventListener(MouseEvent.MOUSE_DOWN, onDragWindowsStartDrag);
				//getChildByName(TitleWindows._mc_title).addEventListener(MouseEvent.MOUSE_UP, onDragWindowsStopDrag);
			}
			catch (e:*)
			{
				trace("TitleWindows配置错误，找不到需要的实例,请检查是否放置mc_title");
			}
			isInited = true;
			tx_title.text = orignalTitle;
			//TextAnimation.Changing(tx_title,TextAnimation.CHINESE)
			TextAnimation.Typing(tx_title) ;
		}
		
		/**
		 * 当程序的关闭按钮被点击的时候,触发的方法.(调用BaseWindwos.CloseApplication())
		 */
		private function onTitleWindowsCloseButtonClickHangle(e:MouseEvent):void
		{
			this.CloseApplication()
		}
		
		/**
		 *当程序开始关闭的时候,移除本抽象类的侦听器
		 */
		private function onTitleWindowsCloseHandle(e:ApplicationEvent):void
		{
			//getChildByName(TitleWindows._btn_close).removeEventListener(MouseEvent.CLICK, onTitleWindowsCloseButtonClickHangle);
			//getChildByName(TitleWindows._mc_title).removeEventListener(MouseEvent.MOUSE_DOWN, onDragWindowsStartDrag);
			//getChildByName(TitleWindows._mc_title).removeEventListener(MouseEvent.MOUSE_UP, onDragWindowsStopDrag);
		}
		
		/**
		 * 设置程序标题文字.
		 */
		public function set setApplicationTitle(t:String):void
		{
			_applicationTitle = t;
			tx_title.text = t;
			if (true)
			{
				//TextAnimation.Typing(getChildByName(TitleWindows._tx_title) as TextField);
			}
		}
		
		/**
		 * 获取程序标题
		 */
		public function get getApplicationTitle():String
		{
			return _applicationTitle
		}
	}
}