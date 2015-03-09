package com.lizeqiangd.zweisystem.interfaces.scrollbar
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.proxy.StageProxy;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 滚动条
	 * @author Lizeqiangd
	 */
	public class sb_core extends BaseUI
	{
		
		public var sp_pointer:Sprite
		public var sp_content:Sprite
		
		///目前顶端显示的位置 在总高度的位置
		private var nowPosition:Number = 0
		///目前滑动块的高度
		private var _pointerHeight:Number = 200
		///总显示高度
		private var _totalHeight:Number = 0
		///显示区域的高度
		private var _displayHeight:Number = 0
		///点击背景时候的移动速度
		private var _speed:Number = 10
		///保存鼠标移动的时候 鼠标在滑动块的相对位置
		private var onMouseDownYPosition:Number = 0
		///是否应当显示滑动条
		private var _necessagry:Boolean = true
		
		public function sb_core()
		{
			sp_pointer = new Sprite
			sp_content = new Sprite
			this.removeChild(sp_background)
			sp_content.addChild(sp_background)
			addChild(sp_content)
			config(10, 100);
			addChild(sp_pointer)
		}
		
		//设置整个滚动条长宽
		public function config(_w:Number, _h:Number):void
		{
			this.configBaseUi(_w, _h)
			this.setBackGroundColor = (0xffffff)
			this.createBackground(0.5)
			this.createPointer()
			this.setDisplayHeight = _h
			addUiListener()
			//this.tween = 10
			//this.elastic = true
			//this.lineAbleClick = true
			//this.mouseWheel=false
		}
		
		//快捷方法，仅修改滚动条的高度
		public function configHeight(h:Number):void
		{
			config(getUiWidth, h);
		}
		
		//添加全部侦听器，用于在隐藏的时候移除
		public function addUiListener()
		{
			sp_pointer.addEventListener(MouseEvent.MOUSE_DOWN, onPointerMouseDown)
			StageProxy.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp)
			sp_pointer.addEventListener(MouseEvent.MOUSE_OVER, onPointerMouseOver)
			sp_pointer.addEventListener(MouseEvent.MOUSE_OUT, onPointerMouseOut)
			sp_content.addEventListener(MouseEvent.MOUSE_DOWN, onBackgroundMouseDown)
		}
		
		///鼠标在滑动块上按下
		private function onPointerMouseDown(e:MouseEvent)
		{
			onMouseDownYPosition = sp_pointer.mouseY
			StageProxy.addEnterFrameFunction(onDragPointer)
			//trace("addEnterFrameFunction")
		}
		
		///鼠标在滑动块上抬起
		private function onStageMouseUp(e:MouseEvent)
		{
			StageProxy.removeEnterFrameFunction(onDragPointer)
			//trace("onPointerMouseUp")
		}
		
		///拖动滑动块操作，会立刻移动滑动块，并且检测是否过界并立刻反馈当前位置
		private function onDragPointer()
		{
			//TweenLite.to(sp_pointer, 0.5, {y: sp_background.mouseY - onMouseDownYPosition})
			sp_pointer.y = sp_background.mouseY - onMouseDownYPosition
			judgeBoundary()
			
			dispatchPostition()
		}
		
		///鼠标经过时候的效果
		private function onPointerMouseOver(e:MouseEvent)
		{ //动画效果
		}
		
		///鼠标移开时候的效果
		private function onPointerMouseOut(e:MouseEvent)
		{ //动画效果
		}
		
		///鼠标在背景按下的时候，根据在滑块上下而做出不同反应
		private function onBackgroundMouseDown(e:MouseEvent)
		{
			//trace(sp_background.mouseY, sp_pointer.y, _pointerHeight, _speed)
			if (sp_background.mouseY > sp_pointer.y + _pointerHeight)
			{ //trace("onBackgroundMouseDown1")
				setNowDisplayTop = nowPosition + _speed
			}
			
			if (sp_background.mouseY < sp_pointer.y)
			{ //trace("onBackgroundMouseDown2")
				setNowDisplayTop = nowPosition - _speed
			}
			
			judgeBoundary()
			dispatchPostition()
		}
		
		///移除所有侦听器
		public function removeUiListener()
		{
			sp_pointer.removeEventListener(MouseEvent.MOUSE_DOWN, onPointerMouseDown)
			StageProxy.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp)
			sp_pointer.removeEventListener(MouseEvent.MOUSE_OVER, onPointerMouseOver)
			sp_pointer.removeEventListener(MouseEvent.MOUSE_OUT, onPointerMouseOut)
			sp_content.removeEventListener(MouseEvent.MOUSE_DOWN, onBackgroundMouseDown)
		}
		
		//防止出界判断
		private function judgeBoundary()
		{
			if (sp_pointer.y < 0)
			{ //trace("judgeBoundary")
				sp_pointer.y = 0
			}
			if (sp_pointer.y + _pointerHeight > sp_background.height)
			{ //trace("judgeBoundary")
				sp_pointer.y = sp_background.height - _pointerHeight
			}
		}
		
		//重新绘制滑动块
		private function createPointer()
		{
			sp_pointer.graphics.clear()
			sp_pointer.x = 0
			sp_pointer.y = 0
			sp_pointer.graphics.beginFill(0x2f2f2f)
			sp_pointer.graphics.drawRoundRectComplex(0, 0, 10, _pointerHeight, 5, 5, 5, 5)
			sp_pointer.graphics.endFill()
		}
		
		///设置总高度,立刻更新滑块
		public function set setTotalHeight(value:Number)
		{
			_totalHeight = value
			_speed = _totalHeight / BPSetting.ScrollbarScrollSpeedDenominator
			judgeNecessary()
			recalculatePointerHeight()
		}
		
		///设置显示高度,立刻更新滑块
		public function set setDisplayHeight(value:Number)
		{
			_displayHeight = value
			judgeNecessary()
			recalculatePointerHeight()
		}
		
		///重新计算滑块高度并绘制,然后重新定位
		private function recalculatePointerHeight():void
		{
			_pointerHeight = _displayHeight * _displayHeight / _totalHeight
			_pointerHeight = _pointerHeight < BPSetting.ScrollbarPointerMinimumHeight ? BPSetting.ScrollbarPointerMinimumHeight : _pointerHeight
			createPointer()
			setNowDisplayTop = (nowPosition)
			judgeBoundary()
		}
		
		///设置滑块目前位置
		public function set setNowDisplayTop(value:Number)
		{
			sp_pointer.y = value / (_totalHeight - _displayHeight) * (sp_background.height - sp_pointer.height)
			nowPosition = value
			judgeBoundary()
		}
		
		///发布自身位置变动。为UnitEvent.CHANGE事件
		private function dispatchPostition():void
		{
			nowPosition = sp_pointer.y / (sp_background.height - sp_pointer.height) * (_totalHeight - _displayHeight)
			//trace(nowPosition)
			this.dispatchEvent(new UIEvent(UIEvent.CHANGE, nowPosition))
		}
		
		///判断显示范围是否大于总大小,如果不需要滚动条则完全隐藏
		private function judgeNecessary()
		{
			if (_displayHeight < _totalHeight)
			{
				if (!_necessagry)
				{
					_necessagry = true
					setVisible = true
				}
			}
			else
			{
				if (_necessagry)
				{
					_necessagry = false
					setVisible = false
				}
			}
		}
		
		///设置是否隐藏滚动条，并且移除侦听器相关
		public function set setVisible(value:Boolean)
		{
			this.visible = value
			value ? addUiListener() : removeUiListener()
		}
	
	}

}

