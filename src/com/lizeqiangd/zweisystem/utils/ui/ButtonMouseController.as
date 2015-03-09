package com.lizeqiangd.zweisystem.utils.ui
{
	//import com.bilibili.player.system.config.BPSetting;
	//import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	/**
	 * 鼠标按钮默认设置类.可以简易的设置一个按钮的基本样式
	 * @author Lizeqiangd
	 */
	public class ButtonMouseController
	{
		private var onDownColor:uint = 0x333333 // BPSetting.DefaultColor_ButtonMouseDown 
		private var onOutColor:uint = 0xffffff // BPSetting.DefaultColor_ButtonMouseOut
		private var onOverColor:uint = 0xffffff // BPSetting.DefaultColor_ButtonMouseOver
		private var onUpColor:uint = 0xffffff //BPSetting.DefaultColor_ButtonMouseUp
		
		public function addMouseControlButton(e:InteractiveObject):void
		{
			e.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown, false, 0, true)
			e.addEventListener(MouseEvent.MOUSE_UP, onButtonMouseUp, false, 0, true)
			e.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut, false, 0, true)
			e.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver, false, 0, true)
			//TweenLite.to(e, 0, { tint: onOutColor } )
			onButtonMouseOutHandle(e)
		}
		
		public function removeMouseControlButton(e:InteractiveObject):void
		{
			e.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown)
			e.removeEventListener(MouseEvent.MOUSE_UP, onButtonMouseUp)
			e.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut)
			e.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver)
			//TweenLite.to(e, 0, {tint: onOutColor})
			onButtonMouseOutHandle(e)
		}
		
		public function configColor(down:uint, up:uint, over:uint, out:uint /*, enable:uint*/):void
		{
			onDownColor = down
			onOutColor = out
			onOverColor = over
			onUpColor = up
		}
		private var isMouseOver:Boolean = false
		
		private function onButtonMouseOver(e:MouseEvent):void
		{
			isMouseOver = true
			//	trace("onButtonMouseOver",onOverColor)
			var ct:ColorTransform = new ColorTransform
			ct.color = onOverColor;
			(e.target as DisplayObject).transform.colorTransform = ct
			//TweenLite.to(e.target, BPSetting.DefaultAnimationTime_ButtonMouse, {tint: onOverColor})
		}
		
		private function onButtonMouseUp(e:MouseEvent):void
		{
			//trace("onButtonMouseUp",onUpColor)
			
			var ct:ColorTransform = new ColorTransform
			ct.color = isMouseOver ? onOverColor : onUpColor;
			(e.target as DisplayObject).transform.colorTransform = ct
			//TweenLite.to(e.target, BPSetting.DefaultAnimationTime_ButtonMouse, {tint: isMouseOver ? onOverColor : onUpColor})
		}
		
		private function onButtonMouseOut(e:MouseEvent):void
		{
			isMouseOver = false
			//trace("onButtonMouseOut",onOverColor)
			
			//TweenLite.to(e.target, BPSetting.DefaultAnimationTime_ButtonMouse, {tint: onOutColor})
			onButtonMouseOutHandle(e.target as InteractiveObject)
		}
		
		private function onButtonMouseOutHandle(e:InteractiveObject):void
		{
			var ct:ColorTransform = new ColorTransform
			ct.color = onOutColor;
			(e as DisplayObject).transform.colorTransform = ct
		
		}
		
		private function onButtonMouseDown(e:MouseEvent):void
		{
			//trace("onButtonMouseDown",onDownColor)
			var ct:ColorTransform = new ColorTransform
			ct.color = onDownColor;
			(e.target as DisplayObject).transform.colorTransform = ct
			//TweenLite.to(e.target, BPSetting.DefaultAnimationTime_ButtonMouse, {tint: onDownColor})
		}	
	}
}