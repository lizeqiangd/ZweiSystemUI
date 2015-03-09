package com.bilibili.player.mvc.view
{
	
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.module.CommentSender.iCommentSender;
	import com.bilibili.player.module.CommentSender.StandardCommentSenderModule;
	import com.bilibili.player.system.config.BPNotification;
	import flash.events.EventDispatcher;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 */
	
	public final class CommentSenderMediator extends Mediator implements IMediator
	{
		public static const NAME:String = 'com.bilibili.player.mvc.view.CommentSenderMediator';
		
		public function CommentSenderMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
		}
		
		override public function onRegister():void
		{
			commentSender.init()
			commentSender.configCommentStyle()
			commentSenderEventDispatch.addEventListener(UIEvent.SUBMIT, onCommentSubmit)		
			
		}
		
		private function onCommentSubmit(e:UIEvent):void
		{
			trace("CommentSenderMediator.onCommentSubmit:", commentSender.getCommentText())

			sendNotification(BPNotification.CommentPublish, commentSender.getCommentText())
		}
		
		public function get commentSender():iCommentSender
		{
			return this.viewComponent as iCommentSender
		}
		
		public function get commentSenderEventDispatch():EventDispatcher
		{
			return this.viewComponent as EventDispatcher
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var name:String = notification.getName();
			var item:Object = notification.getBody();
			
			switch (name)
			{
				case BPNotification.CommentPublishFailed:
					trace("CommentSenderMediator.handleNotification:","BPNotification.CommentPublishFailed")
					break
				case BPNotification.CommentPublishComplete:
					commentSender.sendCommentCompleted()
					break
				case BPNotification.CommentSenderStyleConfigChanged: 
					commentSender.configCommentStyle()
					break
				case BPNotification.CommentSenderBarEnable: 
					commentSender.enableCommentSender()
					break
				case BPNotification.CommentSenderBarDisable: 
					commentSender.disableCommentSender(String(item))
					break
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [BPNotification.CommentPublishFailed, BPNotification.CommentPublishComplete, BPNotification.CommentSenderStyleConfigChanged, BPNotification.CommentSenderBarEnable, BPNotification.CommentSenderBarDisable];
		}
	
	}
}