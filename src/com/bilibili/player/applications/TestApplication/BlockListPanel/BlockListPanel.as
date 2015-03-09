package com.bilibili.player.applications.TestApplication.BlockListPanel
{
	import com.bilibili.player.abstract.windows.iApplication;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.bilibili.player.abstract.windows.TitleWindows;
	import com.bilibili.player.events.ApplicationEvent;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.datagird.blocklist.dgr_block;
	import com.lizeqiangd.zweisystem.interfaces.datagird.blocklist.dgr_blockTitle;
	import com.lizeqiangd.zweisystem.interfaces.datagird.dg_defaultDataGird;
	import com.bilibili.player.system.config.BPSetting;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 标准弹幕显示列表.使用插件.dg_commentList 作为主类
	 * 然后其标题和其他功能都在此上面进行操作,包括全选功能
	 * @author Lizeqiangd
	 */
	public class BlockListPanel extends TitleWindows implements iApplication
	{
		//主列表
		private var dg:dg_defaultDataGird
		
		//列表标题栏
		private var dgt:dgr_blockTitle
		
		//屏蔽功能窗口  以后可能会制作出来
		//private var
		
		public function BlockListPanel()
		{
			setApplicationTitle = 'BlockListDummyPanel'
			this.setApplicationName = "BlockListPanel";
			this.addEventListener(ApplicationEvent.INIT, init);
			
			dgt = new dgr_blockTitle
			dgt.y = 20
			addChild(dgt)
			
			dg = new dg_defaultDataGird(dgr_block)
			addChild(dg)
			dg.config(300, 380)
 			dg.y = dgt.y + BPSetting.StandardDataGirdRowHeight
			
			configWindows(300, 400)
		}
		
		public function init(e:ApplicationEvent):void
		{
			
			dispatchEvent(new ApplicationEvent(ApplicationEvent.INITED))
			addApplicationEventListener()
			testStart()
		}
		
		private function addApplicationEventListener():void
		{
			dg.addEventListener(UIEvent.SELECTED, onSelected)
  			dgt.addEventListener(UIEvent.CLICK, onTitleRowClick)
		}
		
		private function removeApplicationListener():void
		{
			this.removeEventListener(ApplicationEvent.INIT, init);
			this.removeEventListener(ApplicationEvent.CLOSE, onApplicationClose);
			
			dg.removeEventListener(UIEvent.SELECTED, onSelected)
			dgt.removeEventListener(UIEvent.CLICK, onTitleRowClick)
		}
		
		private function onApplicationClose(e:ApplicationEvent):void
		{
			removeApplicationListener();
		
		}
		
		/**
		 * 点击标题的时候排序算法
		 */
		private function onTitleRowClick(e:UIEvent):void
		{
			switch (e.data)
			{
				case "content": 
					break
				case "type": 
					break
			}
		}
		
		/**
		 * 点击条目的时候获取当前点选的数据.
		 * @param	e
		 */
		private function onSelected(e:UIEvent):void
		{
			//	trace("Datagird selected index in dataprovider:")
			//trace(dg.getSelectedArray)
		}
		
		
		//测试内容
		private var ind:int = 0
		private var dummyData:Array = []
		
		private function testStart():void
		{
			for (var i:int = 0; i < 100; i++)
			{
				dummyData.push({type: ind % 3 ? "用户" : "颜色", content: "用户:" + (Math.random() * 100000000).toFixed(), date: (Math.random() * 10000000).toFixed()})
				ind++
			}
			dummyData.push({type: '', content: 0, date: 0})
			
			dg.dataProvider = dummyData
		}
	public function dispose():void
		{
			dispatchEvent(new ApplicationEvent(ApplicationEvent.CLOSE))
		}
		
		public function applicationMessage(e:Object):void
		{
			switch (e)
			{
				case "": 
					break;
				default: 
					break;
			}
		}
	}

}