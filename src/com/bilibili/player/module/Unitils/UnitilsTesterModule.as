package com.bilibili.player.module.Unitils
{
	import com.bilibili.player.abstract.module.BaseModule;
	import com.bilibili.player.abstract.module.iModule;
	import com.bilibili.player.applications.TestApplication.BlockListPanel.BlockListPanel;
	import com.bilibili.player.applications.TestApplication.CommentListPanel.CommentListPanel;
	import com.bilibili.player.manager.ModuleManager;
	import com.bilibili.player.system.proxy.StageProxy;
	
	/**
	 * 测试用module
	 * @author Lizeqiangd
	 */
	public class UnitilsTesterModule extends BaseModule implements iModule
	{
		private var windows_blp:BlockListPanel
		private var windows_clp:CommentListPanel
		public function UnitilsTesterModule()
		{
			StageProxy.addResizeFunction(onStageResize)
			setModuleName = "UnitilsTester";
		}
		
		public function init():void
		{
			windows_blp = ModuleManager.createWindows(BlockListPanel)
			windows_clp = ModuleManager.createWindows(CommentListPanel)
		}
		
		private function onStageResize():void
		{
		
		}
	
	}

}