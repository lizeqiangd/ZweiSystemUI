package com.bilibili.player.mvc
{
	import com.bilibili.player.manager.AddOnManager;
	import com.bilibili.player.manager.ModuleManager;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	import com.bilibili.player.mvc.controller.CommentSenderController;
	import com.bilibili.player.mvc.controller.PlayerBaseController;
	import com.bilibili.player.system.config.BPNotification;
	import com.bilibili.player.system.proxy.StageProxy;
	import flash.display.Stage;
	import flash.events.Event;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	
	/**
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 */
	
	public final class ApplicationFacade extends Facade implements IFacade
	{
		
		public static function getInstance():ApplicationFacade
		{
			return (instance ? instance : new ApplicationFacade()) as ApplicationFacade;
		}
		
		private var sm:SkinManager
		public function startup(obj:Stage):void
		{
			
			trace("ApplicationFacade.startup")
			StageProxy.init(obj)
			ModuleManager.init(StageProxy.stage)
			AddOnManager.initTweenPlugin()
			sm = new SkinManager()
			sm.addEventListener(Event.COMPLETE, function():void
				{
					sendNotification(BPNotification.PlayerStartingUp, StageProxy.stage);
				}, false, 0, true);
			trace("ApplicationFacade.startup complete")
		}
		
		override protected function initializeController():void
		{
			super.initializeController();
			
			registerCommand(BPNotification.PlayerStartingUp, PlayerBaseController)
			
			registerCommand(BPNotification.CommentPublish, CommentSenderController)
			registerCommand(BPNotification.CommentPublishComplete, CommentSenderController)
			registerCommand(BPNotification.CommentSenderBarDisable, CommentSenderController)
			registerCommand(BPNotification.CommentSenderBarEnable, CommentSenderController)
			registerCommand(BPNotification.CommentPublishFailed, CommentSenderController)
			registerCommand(BPNotification.CommentSenderStyleConfigChanged, CommentSenderController)
		
		}
	}
}