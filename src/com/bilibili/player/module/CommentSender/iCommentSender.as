package com.bilibili.player.module.CommentSender {
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public interface iCommentSender
	{
		 
		 function configCommentStyle():void
		 function getCommentText():String
		 function disableCommentSender(info:String = ""):void
		 function enableCommentSender():void
		 function sendCommentCompleted():void
	}
}