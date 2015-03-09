package com.bilibili.player.module.CommentSender
{
	import com.bilibili.player.abstract.module.BaseModule;
	import com.bilibili.player.abstract.module.iModule;
	import com.bilibili.player.applications.CommentSenderbar.Standard.StandardCommentSender;
	import com.bilibili.player.applications.CommentSytlePanel.Standard.StandardCommentStylePanel;
	import com.bilibili.player.core.comments.CommentData;
	import com.bilibili.player.core.comments.CommentDataType;
	import com.bilibili.player.events.MukioEvent;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.manager.ModuleManager;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.namespaces.bilibili;
	import com.bilibili.player.system.proxy.StageProxy;
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 * 初始化模块,使用Mediator去激活本块.
	 * 所有内容会用模块去跟舞台加载. Mediator只负责和本模块内的所有实例通信.
	 *
	 * 本模块包含  弹幕样式选择面板  弹幕发送条
	 * 20141018
	 * @author Lizeqiangd
	 */
	public class StandardCommentSenderModule extends BaseModule implements iCommentSender, iModule
	{
		private var style_panel:StandardCommentStylePanel
		private var comment_sender:StandardCommentSender
		private var isStylePanelOpen:Boolean = false
		private var isPublishing:Boolean = false
		
		public function StandardCommentSenderModule()
		{
			this.setModuleName = "CommentSender"
		}
		
		public function init():void
		{
			style_panel = new StandardCommentStylePanel
			comment_sender = new StandardCommentSender
			
			style_panel.config()
			style_panel.alpha = 0
			style_panel.visible = false
			
			ModuleManager.addToLayer(style_panel, "float")
			ModuleManager.addToLayer(comment_sender, "application")
			StageProxy.addResizeFunction(onPlayerResize)
			
			configCommentStyle()
			onPlayerResize()
			addUiListener()
		
		}
		
		/**
		 * 设置弹幕样式.全部资源从DataManager.getCommentStyleConfig获取
		 * 设置完后调用此方法(在mediator中调用)
		 */
		public function configCommentStyle():void
		{
			style_panel.configColorVector(ValueObjectManager.getCommentStyleConfig.color_array)
			style_panel.configDefaultColor(ValueObjectManager.getCommentStyleConfig.color_array[0])
			style_panel.configStyleButton(ValueObjectManager.getCommentStyleConfig)
		}
		
		public function disableCommentSender(info:String = ""):void
		{
			isPublishing = true
			comment_sender.disableCommentSender(info)
		}
		
		public function enableCommentSender():void
		{
			isPublishing = false
			comment_sender.enableCommentSender()
		}
		
		public function getCommentText():String
		{
			return comment_sender.getCommentText()
		}
		
		public function sendCommentCompleted():void
		{
			isPublishing = false
			comment_sender.sendCommentCompleted()
		}
		
		private function addUiListener():void
		{
			comment_sender.ti_comment.addEventListener(UIEvent.SUBMIT, onSubmitClick)
			comment_sender.btn_type.addEventListener(UIEvent.CLICK, onTypeSelecetionClick)
			comment_sender.btn_submit.addEventListener(UIEvent.CLICK, onSubmitClick)
			style_panel.addEventListener(UIEvent.CHANGE, onCommentStyleChange)
			StageProxy.addEventListener(MouseEvent.CLICK, onStageClick)
		}
		
		private function onStageClick(e:MouseEvent):void
		{
			if (isStylePanelOpen)
			{
				style_panel.hitTestPoint(e.stageX, e.stageY) || comment_sender.btn_type.hitTestPoint(e.stageX, e.stageY) ? null : onTypeSelecetionClick(null)
			}
		}
		
		private function onSubmitClick(e:UIEvent):void
		{
			if (isPublishing)
			{
				return
			}
			comment_sender.btn_submit.removeUiListener()
			isPublishing = true
			//dispatchEvent(new UnitEvent(UnitEvent.SUBMIT))
			
			var cmt:CommentData = new CommentData();
			cmt.type = CommentDataType.NORMAL;
			cmt.mode = 1 //ValueObjectManager.getCommentStyleData.comment_derection
			cmt.color = ValueObjectManager.getCommentStyleData.color
			cmt.size = ValueObjectManager.getCommentStyleData.font_size
			cmt.bilibili::text = comment_sender.getCommentText()
			
			cmt.msg = '1';
			ValueObjectManager.getEventBus.sendMukioEvent(MukioEvent.DISPLAY, cmt);
			//inputTF.text = "";
			sendCommentCompleted()
		}
		
		private function onTypeSelecetionClick(e:UIEvent):void
		{
			isStylePanelOpen = !isStylePanelOpen
			comment_sender.btn_type.selected = isStylePanelOpen
			if (isStylePanelOpen)
			{
				TweenLite.to(style_panel, BPSetting.AnimationTime_StylePanelMovement, {autoAlpha: 1, ease: Quad.easeIn})
			}
			else
			{
				
				TweenLite.to(style_panel, BPSetting.AnimationTime_StylePanelMovement, {autoAlpha: 0, ease: Quad.easeOut})
			}
		}
		
		private function onPlayerResize():void
		{
			comment_sender.y = StageProxy.stageHeight - 25
			comment_sender.configWidth(StageProxy.stageWidth)
			
			style_panel.x = 10
			style_panel.y = StageProxy.stageHeight - 315
		}
		
		private function onCommentStyleChange(e:UIEvent):void
		{
			trace(ValueObjectManager.getCommentStyleData.comment_derection, ValueObjectManager.getCommentStyleData.color, ValueObjectManager.getCommentStyleData.font_size)
		}
	}
}