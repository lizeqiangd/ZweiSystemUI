package com.lizeqiangd.zweisystem.interfaces.button
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseButton;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	import com.bilibili.player.system.config.BPSetting;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class btn_commentSubmit extends BaseButton
	{
		
		private var icon:InteractiveObject
		
		public function config(_w:Number, _h:Number):void
		{
			configBaseButton(_w, _h)
			createFrame(false)
			setBackGroundColor = BPSetting.BilibiliLightBlueUnit
			createBackground(1)
			createButton()
			
			this.setIcon(SkinManager.getObject("comment_sumbit"))
		}
		
		override public function onMouseDown(e:MouseEvent):void
		{
			TweenLite.to(this.sp_background, BPSetting.AnimationTime_ButtonCommentSubmitTint, {tint: BPSetting.AnimationTint_CommentSubmitButtonMouseDown})
		}
		
		override public function onMouseOut(e:MouseEvent):void
		{
			TweenLite.to(this.sp_background, BPSetting.AnimationTime_ButtonCommentSubmitTint, {tint: BPSetting.AnimationTint_CommentSubmitButtonMouseOut})
		}
		
		override public function onMouseUp(e:MouseEvent):void
		{
			TweenLite.to(this.sp_background, BPSetting.AnimationTime_ButtonCommentSubmitTint, {tint: BPSetting.AnimationTint_CommentSubmitButtonMouseUp})
		}
		
		override public function onMouseOver(e:MouseEvent):void
		{
			TweenLite.to(this.sp_background, BPSetting.AnimationTime_ButtonCommentSubmitTint, {tint: BPSetting.AnimationTint_CommentSubmitButtonMouseOver})
		}
		
		public function setIcon(e:InteractiveObject):void
		{
			e.mouseEnabled = false
			icon = e
			addChild(e)
		}
	}

}