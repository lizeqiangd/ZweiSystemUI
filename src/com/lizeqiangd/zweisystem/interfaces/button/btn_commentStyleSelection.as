package com.lizeqiangd.zweisystem.interfaces.button
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseButton;
	import com.bilibili.player.system.config.BPSetting;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class btn_commentStyleSelection extends BaseButton
	{
		private var icon:DisplayObject
		private var isSelected:Boolean = false
		
		public function config(_w:Number, _h:Number):void
		{
			configBaseButton(_w, _h)
			//createFrame()
			createButton()
			
			onMouseUp(null)
		}
		
		override public function onMouseDown(e:MouseEvent):void
		{
			//TweenLite.to(this, 0, {tint: 0x00c2fb})
		}
		
		override public function onMouseOut(e:MouseEvent):void
		{
			//TweenLite.to(this, 0, {tint: 0xa2a2a2})
		}
		
		override public function onMouseUp(e:MouseEvent):void
		{
			//TweenLite.to(this, 0, {tint: 0xa2a2a2})		
		}
		
		override public function onMouseOver(e:MouseEvent):void
		{
			//TweenLite.to(this, 0, {tint: 0x00c2fb})
		}
		
		public function set selected(e:Boolean):void
		{
			isSelected = e
			isSelected ? TweenLite.to(this, BPSetting.AnimationTime_ButtonCommentStyleSelectionTint, {tint: 0x00c2fb}) : TweenLite.to(this, BPSetting.AnimationTime_ButtonCommentStyleSelectionTint, {tint: 0xa2a2a2})
		}
		
		public function setIcon(e:DisplayObject):void
		{
			addChildAt(e, 0)
		}
	}

}