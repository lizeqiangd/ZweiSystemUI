package com.bilibili.player.mvc.controller 

{			
	import com.bilibili.player.module.CommentSender.StandardCommentSenderModule;
	import com.bilibili.player.mvc.view.CommentSenderMediator;
	import com.bilibili.player.system.config.BPNotification;
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	/**
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 */
	
	public final class PlayerBaseController extends SimpleCommand implements ICommand
	{
		
		override public function execute(notification:INotification):void
		{
			var name:String = notification.getName();
			var item:Object = notification.getBody();
			
			switch (name)
			{
				case BPNotification.PlayerStartingUp: 
				facade.registerMediator(new CommentSenderMediator(new StandardCommentSenderModule))
					
					
					
					
					
					
					
					
					
					
					
				break;
			}
		}
	}
}