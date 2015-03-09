package com.lizeqiangd.zweisystem.interfaces.button
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseButton;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	import com.bilibili.player.system.config.BPSetting;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class btn_commentType extends BaseButton //implements iUnit
	{
		private var icon:DisplayObject
		private var isSelected:Boolean = false
		
		public function config(_w:Number, _h:Number):void
		{
			configBaseButton(_w, _h)
			createButton()
			this.setFrameColor = (0xa2a2a2)
			createFrame(false)
			createBackground()
			
			this.setIcon(SkinManager.getObject("comment_style_type"))
		}
		
		public function set selected(e:Boolean):void
		{
			isSelected = e
			if (isSelected)
			{
				TweenLite.to(icon, BPSetting.AnimationTime_ButtonCommentStylePanelTint, {tint: BPSetting.BilibiliLightBlueUnit})
			}
			else
			{
				TweenLite.to(icon, BPSetting.AnimationTime_ButtonCommentStylePanelTint, {tint: BPSetting.BilibiliGray})
			}
		}
		
		public function get selected():Boolean
		{
			return isSelected
		}
		
		override public function onMouseDown(e:MouseEvent):void
		{
		
		}
		
		override public function onMouseOut(e:MouseEvent):void
		{
		}
		
		override public function onMouseUp(e:MouseEvent):void
		{
		}
		
		override public function onMouseOver(e:MouseEvent):void
		{
		}
		
		public function setIcon(e:InteractiveObject):void
		{
			icon = e
			this.addChild(e)
			e.mouseEnabled=false
			TweenLite.to(icon, 0, {tint: BPSetting.BilibiliGray})
		}
	
	}

}