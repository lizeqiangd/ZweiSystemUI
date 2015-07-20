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
		
		private var onDownAlpha:Number = 1.0// BPSetting.DefaultColor_ButtonMouseDown 
		private var onOutAlpha:Number = 0.4 // BPSetting.DefaultColor_ButtonMouseOut
		private var onOverAlpha:Number = 0.85 // BPSetting.DefaultColor_ButtonMouseOver
		private var onUpAlpha:Number = 0.4//BPSetting.DefaultColor_ButtonMouseUp
		
		/**
		 * 设置是否使用切换颜色模式
		 * @param	e
		 */
		public var changeColorMode:Boolean = false
		
		/**
		 * 设置是否使用切换alpha模式
		 * @param	e
		 */
		public var changeAlphaMode:Boolean = true
		private var isMouseOver:Boolean = false
		
		/**
		 * 这里设置开始.
		 * @param	e
		 */
		public function addMouseControlButton(e:InteractiveObject):void
		{
			e.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown)//, false, 0, true)
			e.addEventListener(MouseEvent.MOUSE_UP, onButtonMouseUp)//, false, 0, true)
			e.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut)//, false, 0, true)
			e.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver)//, false, 0, true)
			onButtonMouseOutHandle(e)
		}
		
		public function removeMouseControlButton(e:InteractiveObject):void
		{
			e.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown)
			e.removeEventListener(MouseEvent.MOUSE_UP, onButtonMouseUp)
			e.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut)
			e.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver)
			onButtonMouseOutHandle(e)
		}
		
		public function configColor(down:uint, up:uint, over:uint, out:uint /*, enable:uint*/):void
		{
			onDownColor = down
			onOutColor = out
			onOverColor = over
			onUpColor = up
		}
		
		public function configAlpha(down:Number, up:Number, over:Number, out:Number):void
		{
			onDownAlpha = down
			onOutAlpha = out
			onOverAlpha = over
			onUpAlpha = up
		}
		
		private function onButtonMouseOver(e:MouseEvent):void
		{
			isMouseOver = true
			var ct:ColorTransform = new ColorTransform
			ct.color = onOverColor;
			if (changeColorMode)
			{
				(e.target as DisplayObject).transform.colorTransform = ct
			}
			if (changeAlphaMode)
			{
				(e.target as DisplayObject).alpha = onOverAlpha
			}
		}
		
		private function onButtonMouseUp(e:MouseEvent):void
		{
			var ct:ColorTransform = new ColorTransform
			ct.color = isMouseOver ? onOverColor : onUpColor;
			if (changeColorMode)
			{
				(e.target as DisplayObject).transform.colorTransform = ct
			}
			if (changeAlphaMode)
			{
				(e.target as DisplayObject).alpha = isMouseOver ? onOverAlpha : onUpAlpha;
			}
		}
		
		private function onButtonMouseOut(e:MouseEvent):void
		{
			isMouseOver = false
			if (changeColorMode)
			{
				onButtonMouseOutHandle(e.target as InteractiveObject)
			}
			if (changeAlphaMode)
			{
				(e.target as DisplayObject).alpha = onOutAlpha
			}
		}
		
		private function onButtonMouseOutHandle(e:InteractiveObject):void
		{
			var ct:ColorTransform = new ColorTransform
			ct.color = onOutColor;
			if (changeColorMode)
			{
				(e as DisplayObject).transform.colorTransform = ct
			}
			if (changeAlphaMode)
			{
				(e as DisplayObject).alpha = onOutAlpha
			}		
		}
		
		private function onButtonMouseDown(e:MouseEvent):void
		{
			var ct:ColorTransform = new ColorTransform
			ct.color = onDownColor;
			if (changeColorMode)
			{
				(e.target as DisplayObject).transform.colorTransform = ct
			}
			if (changeAlphaMode)
			{
				(e.target as DisplayObject).alpha = onDownAlpha
			}
		}
	}
}