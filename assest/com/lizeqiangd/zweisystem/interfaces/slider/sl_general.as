package com.lizeqiangd.zweisystem.interfaces.slider
{
	import com.greensock.TweenLite;
	import com.lizeqiangd.zweisystem.events.UnitEvent;
	import com.lizeqiangd.zweisystem.manager.AnimationManager;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 这下艹了..这是一个pan系统.我给他做成了slider...这尼玛我疯了..
	 * 2014.05.10 开始修复重做工作.
	 * @author Lizeqiangd
	 * @email lizeqiangd@gmail.com
	 * @website http://www.lizeqiangd.com
	 */
	public class sl_general extends Sprite
	{
		///是否流畅的一直发布信息,还是直接发送结果.
		public var smooth:Boolean = false
		
		private var buttonBarWidth:int = 162
		private var buttonPointerWidth:int = 11.6
		private var isMouseDown:Boolean = false
		
		public function sl_general()
		{
			mc_pointer.mouseEnabled = false
			addUiListener();
			this.setNowPosition = 0
		}
		
		private function addUiListener()
		{
			mc_button.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			mc_button.addEventListener(MouseEvent.MOUSE_MOVE, onMouse);
			//mc_btn.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		private function removeUiListener()
		{
			mc_button.removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			mc_button.removeEventListener(MouseEvent.MOUSE_MOVE, onMouse);
		}
		
		///鼠标移动和点击后触发的事件.
		private function onMouse(e:MouseEvent)
		{
			
			if (e.buttonDown)
			{
				var m:Number = 0
				if (e.localX <= buttonPointerWidth / 2)
				{
					m = 0
				}
				else if (e.localX >= (buttonBarWidth - buttonPointerWidth / 2))
				{
					m = 1
				}
				else
				{
					m = (e.localX - (buttonPointerWidth / 2)) / (buttonBarWidth)
				}
				TweenLite.to(mc_pointer, 0.5, {x: m * buttonBarWidth, onUpdate: update})
				if (!smooth)
				{
					dispatchEvent(new UnitEvent(UnitEvent.CHANGE, m / buttonPointerWidth * 100))
				}
			}
		
		}
		
		/**
		 * 每次更新数据的时候会发送一个UnitEvent.CHANGE事件,附带当时的数值 [0-100]
		 * 同时是显示具体数字的地方.
		 */
		private function update()
		{
			if (smooth)
			{
				dispatchEvent(new UnitEvent(UnitEvent.CHANGE, getNowPosition))
			}
			
			//显示的是数字,这个设计完全是脑残设计啊...但是懒得想凑合着用吧.
			var n:Number = getNowPosition
			if (n >= 100)
			{
				AnimationManager.fade_out(ani_right)
				this.tx_title.text = "满"
			}
			else if (n >= 10)
			{
				AnimationManager.fade(ani_right, 1)
				AnimationManager.fade(ani_left, 1)
				this.tx_title.text = String(n).substr(0, 2);
				
			}
			else if (n > 0)
			{
				AnimationManager.fade_out(ani_left)
				
				this.tx_title.text = String(n).substr(0, 1);
			}
			else
			{
				this.tx_title.text = "0"
			}
		
		}
		
		public function get getNowPosition():Number
		{
			return mc_pointer.x / (buttonBarWidth - buttonPointerWidth) * 100
		}
		
		///在外部设置当前音量[0-100]
		public function set setNowPosition(e:Number)
		{
			this.tx_title.text = String(e).substr(0, 2);
			TweenLite.to(mc_pointer, 0.5, {x: e / 100 * buttonBarWidth, onUpdate: update})
		}
		
		public function dispose()
		{
			//removeUiListener()
		}
	}
}

