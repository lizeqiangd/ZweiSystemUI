package com.bilibili.player.mvc.controller 

{			
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	/**
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 */
	
	public final class CommentSenderController extends SimpleCommand implements ICommand
	{
		
		override public function execute(notification:INotification):void
		{
			var name:String = notification.getName();
			var item:Object = notification.getBody();
			
			switch (name)
			{
				case " ": 
				
				//sendNotification(ApplicationConstant.Test_Message2, {type: "test1"});
				break;
			}
		}
	}
}