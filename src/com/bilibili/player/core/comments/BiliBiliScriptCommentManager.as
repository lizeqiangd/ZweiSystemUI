package com.bilibili.player.core.comments
{
	import com.bilibili.player.core.script.CommentScriptFactory;
	import com.bilibili.player.core.script.interfaces.ICommentScriptFactory;
	import com.bilibili.player.core.utils.EventBus;
	import com.bilibili.player.events.CommentDataEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	
	import flash.display.Sprite;
	
	////
	////import org.lala.event.CommentDataEvent;
	////import org.lala.event.EventBus;
	//new EventBus
	//new CommentDataEvent
	//new comm
	////import tv.bilibili.script.CommentScriptFactory;
	////import tv.bilibili.script.interfaces.ICommentScriptFactory;
	//new CommentScriptFactory
	//new ICommentScriptFactory
	/**
	 * bilibili脚本弹幕
	 **/
	public class BiliBiliScriptCommentManager extends CommentManager
	{
		/**
		 * 弹幕执行工厂
		 **/
		protected var commentScriptFactory:ICommentScriptFactory;
		
		public function BiliBiliScriptCommentManager(clip:Sprite)
		{
			super(clip);
		}
		
		/**
		 * 设置监听弹幕的类型
		 **/
		override protected function setModeList():void
		{
			this.mode_list.push(CommentDataEvent.BILIBILI_SCRIPT);
		}
		
		/**
		 * 弹幕开始执行
		 **/
		override protected function start(data:Object):void
		{
			try
			{
				commentScriptFactory.exec(data.text, true);
				//trace("bilibiliscriptcommentmanager.高级弹幕解析开始")
			}
			catch (error:Error)
			{
				ValueObjectManager.getEventBus.log(error.toString())
//				EventBus.getInstance().log(error.toString());
			}
		}
		
		/**
		 * 在有脚本弹幕时再进行初始化执行者
		 **/
		override protected function commentDataHandler(event:CommentDataEvent):void
		{
			if(commentScriptFactory == null)
			{
				commentScriptFactory = ValueObjectManager.getCommentScriptFactory
			}
			super.commentDataHandler(event);
		}
		
		override protected function setSpaceManager():void
		{
		/** 置空 **/
		}
		
		override public function resize(width:Number, height:Number):void
		{
		/** 置空 **/
		}
		
		override protected function add2Space(cmt:IComment):void
		{
		/** 置空 **/
		}
		
		override protected function removeFromSpace(cmt:IComment):void
		{
		/** 置空 **/
		}
		
		override protected function getComment(data:Object):IComment
		{
			return null;
		}
	}
}