package com.lizeqiangd.zweisystem.interfaces.baseunit
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.mousetips.GlobalMouseTips;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 所有按钮类的基类.
	 * 20150306 增加FlashProfressional协助模式
	 * @author Lizeqiangd
	 */
	public class BaseButton extends BaseUI
	{
		public var tips_title:String = "按钮"
		public var sp_click:*
		public var isEnable:Boolean = true
		
		public function BaseButton(assest_mode:Boolean = false)
		{
			if (assest_mode)
			{
				
			}
			else
			{
				sp_click = new Sprite
			}
		}
		/**
		 * 设置按钮是否可用
		 */
		public function set enable(value:Boolean):void
		{
			if (value)
			{
				if (!isEnable)
				{
					isEnable = true;
					onMouseUp(null)
					addUiListener();
					this.alpha=0.4
				}
			}
			else
			{
				if (isEnable)
				{
					isEnable = false;
					sp_click.alpha = 0.05;
					removeUiListener();
					this.alpha=1
				}
			}
		}
		
		/**
		 * 设置按钮点击范围的大小.(可以和icon大小不一致)
		 * @param	basebutton_width
		 * @param	basebutton_height
		 */
		public function configBaseButton(basebutton_width:Number, basebutton_height:Number):void
		{
			super.configBaseUi(basebutton_width, basebutton_height)
		}
		
		/**
		 * 绘制(重新绘制)按钮大小区域.
		 */
		public function createButton():void
		{
			sp_click.graphics.clear()
			sp_click.graphics.beginFill(0, 0)
			sp_click.graphics.drawRect(0, 0, getUiWidth, getUiHeight)
			sp_click.graphics.endFill()
			addChild(sp_click)
			addUiListener()
		}
		
		/**
		 * 添加对按钮的事件侦听
		 */
		public function addUiListener():void
		{
			sp_click.addEventListener(MouseEvent.CLICK, onMouseClick)
			sp_click.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
			sp_click.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
			sp_click.addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
			sp_click.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
			sp_click.addEventListener(MouseEvent.MOUSE_OVER, onMouseTipsOver)
			sp_click.addEventListener(MouseEvent.MOUSE_OUT, onMouseTipsOut)
		}
		
		/**
		 * 移除对按钮的事件侦听
		 */
		public function removeUiListener():void
		{
			sp_click.removeEventListener(MouseEvent.CLICK, onMouseClick)
			sp_click.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
			sp_click.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
			sp_click.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp)
			sp_click.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
			sp_click.removeEventListener(MouseEvent.MOUSE_OVER, onMouseTipsOver)
			sp_click.removeEventListener(MouseEvent.MOUSE_OUT, onMouseTipsOut)
		}
		
		/**
		 * 当按钮被点击的时候做出的反应
		 * @param	e
		 */
		public function onMouseClick(e:MouseEvent):void
		{
			dispatchEvent(new UIEvent(UIEvent.CLICK))
		}
		
		/**
		 * 等待覆盖.
		 * 当按下按钮时候的方法
		 */
		public function onMouseDown(e:MouseEvent):void
		{
		
		}
		
		/**
		 * 等待覆盖.
		 * 当鼠标离开按钮时候的方法
		 */
		public function onMouseOut(e:MouseEvent):void
		{
		
		}
		
		/**
		 * 等待覆盖.
		 * 当鼠标抬起按钮时候的方法
		 */
		public function onMouseUp(e:MouseEvent):void
		{
		
		}
		
		/**
		 * 等待覆盖.
		 * 当鼠标经过按钮时候的方法
		 */
		public function onMouseOver(e:MouseEvent):void
		{
		}
		
		/**
		 * 用于提示
		 * 当鼠标经过按钮时候的方法
		 */
		private function onMouseTipsOver(e:MouseEvent):void
		{
			GlobalMouseTips.setTipsByDisplayObject(tips_title, this)
		}
		
		private function onMouseTipsOut(e:MouseEvent):void
		{
			GlobalMouseTips.hideTips()
		}
	}
}