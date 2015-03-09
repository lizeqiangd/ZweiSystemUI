package com.bilibili.player.applications.CommentSenderbar.Standard
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.bilibili.player.interfaces.button.btn_commentSubmit;
	import com.lizeqiangd.zweisystem.interfaces.button.btn_commentType;
	import com.bilibili.player.interfaces.textinput.ti_commentInputer;
	import flash.display.Sprite;
	
	/**
	 * 标准弹幕发送条,包含 样式选择按钮,文字发送条,发送按钮
	 * @author Lizeqiangd
	 * 20150130 重新制作
	 * 
	 */
	public class StandardCommentSender extends BaseUI
	{
		
		public var btn_type:btn_commentType
		public var btn_submit:btn_commentSubmit
		public var ti_comment:ti_commentInputer
		
		public function StandardCommentSender()
		{
			btn_type = new btn_commentType
			ti_comment = new ti_commentInputer
			btn_submit = new btn_commentSubmit
			
			btn_type.config(36, 25)
			btn_submit.config(70, 25)
			ti_comment.config(300, 25)
			config(200, 25)
			
			addChild(btn_type)
			addChild(ti_comment)
			addChild(btn_submit)
		}
		
		public function config(_w:Number, _h:Number):void
		{
			configBaseUi(_w, _h)
			
			btn_type.x = 0
			
			//btn_type.y = 300 - 25
			
			btn_submit.x =getUiWidth - 70
			//btn_submit.y = 300- 25
			
			ti_comment.setWidth(getUiWidth - btn_type.width - btn_submit.width + 2)
			ti_comment.x = btn_type.width - 1
			//ti_comment.y = 300 - 25
		
		}
		
		public function configWidth(_w:Number):void
		{
			config(_w, getUiHeight)
		}
		
		public function disableCommentSender(info:String = ""):void
		{
			
			//isPublishing = true
			btn_submit.removeUiListener()
			ti_comment.text = info
			ti_comment.enable = false
		}
		
		public function enableCommentSender():void
		{
			//isPublishing = false
			btn_submit.addUiListener()
			ti_comment.enable = true
			sendCommentCompleted()
		}
		
		public function getCommentText():String
		{
			return ti_comment.text
		}
		
		public function sendCommentCompleted():void
		{
			//isPublishing = false
			btn_submit.addUiListener()
			ti_comment.clear()
			ti_comment.focus()
		}
	}

}