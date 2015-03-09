package com.bilibili.player.applications.TestApplication.CommentListPanel
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.bilibili.player.abstract.windows.iApplication;
	import com.bilibili.player.abstract.windows.TitleWindows;
	import com.bilibili.player.events.ApplicationEvent;
	import com.bilibili.player.events.CommentDataEvent;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.datagird.commentlist.dgr_comment;
	import com.lizeqiangd.zweisystem.interfaces.datagird.commentlist.dgr_commentTitle;
	import com.bilibili.player.interfaces.datagird.dg_defaultDataGird;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.config.BPSetting;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 标准弹幕显示列表.使用插件.dg_commentList 作为主类
	 * 然后其标题和其他功能都在此上面进行操作,包括全选功能
	 * @author Lizeqiangd
	 */
	public class CommentListPanel extends TitleWindows implements iApplication
	{
		//主列表
		private var dg:dg_defaultDataGird
		
		//列表标题栏
		private var dgt:dgr_commentTitle
		
		//屏蔽功能窗口  以后可能会制作出来
		//private var
		
		public function CommentListPanel()
		{
			setApplicationTitle = 'CommentListDummyPanel'
			this.setApplicationName = "CommentListPanel";
			this.addEventListener(ApplicationEvent.INIT, init);
			
			dgt = new dgr_commentTitle
			addChild(dgt)
			dgt.y = 20
			dg = new dg_defaultDataGird(dgr_comment)
			addChild(dg)
			dg.config(300, 460)
			dg.y = dgt.y + BPSetting.StandardDataGirdRowHeight
			
			this.configWindows(300, 500)
		}
		
		public function init(e:ApplicationEvent):void
		{
			dg.dataProvider = ValueObjectManager.getCommentProvider.commentResource
			dispatchEvent(new ApplicationEvent(ApplicationEvent.INITED))
			addApplicationEventListener()
		}
		
		private function addApplicationEventListener():void
		{
			ValueObjectManager.getCommentProvider.addEventListener(CommentDataEvent.COMMENT_DATA_CHANGE, onUpdateCommentList)
			dg.addEventListener(UIEvent.SELECTED, onSelected)
			dgt.addEventListener(UIEvent.CLICK, onTitleRowClick)
		}
		
		private function remoreApplicationEventListener():void
		{
			this.removeEventListener(ApplicationEvent.INIT, init);
			this.removeEventListener(ApplicationEvent.CLOSE, onApplicationClose);
			
			dg.removeEventListener(UIEvent.SELECTED, onSelected)
			dgt.removeEventListener(UIEvent.CLICK, onTitleRowClick)
		}
		
		private function onApplicationClose(e:ApplicationEvent):void
		{
			remoreApplicationEventListener();
		}
		
		/**
		 * 点击标题的时候排序算法
		 */
		private function onTitleRowClick(e:UIEvent):void
		{
			switch (e.data)
			{
				case "date": 
					break
				case "comment": 
					break
				case "time": 
					break
			}
			trace(e.data)
		}
		
		/**
		 * 点击条目的时候获取当前点选的数据.
		 * @param	e
		 */
		private function onSelected(e:UIEvent):void
		{
			trace("Datagird selected index in dataprovider:")
			trace(dg.getSelectedArray)
			//CloseApplication()
		}
		
		private function onUpdateCommentList(e:CommentDataEvent):void
		{
			dg.dataProvider = ValueObjectManager.getCommentProvider.commentResource
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