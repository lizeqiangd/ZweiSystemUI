package com.lizeqiangd.zweisystem.interfaces.slider
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.utils.encode.DateTimeUtils;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.mousetips.GlobalMouseTips;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	//import com.bilibili.player.system.proxy.StageProxy;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 视频滑块拖动条.针对视频进度条设计的 3重进度
	 * 属于sld_general的异类.普通滑块请使用那个
	 * @author Lizeqiangd
	 * 2015.01.12 增加鼠标提示
	 */
	public class sld_videoprogressbar extends BaseUI
	{
		///点击相应区域
		private var sp_mousezone:Sprite
		
		///滑块
		private var sp_pointer:Sprite
		
		///视频拖动条
		private var sp_backgroundBar:Shape
		private var sp_playedBar:Shape
		private var sp_bufferBar:Shape
		
		///是否处于点击状态
		private var _isMouseDown:Boolean = false
		
		///滑块状态
		private var _max:Number = 1
		private var _played:Number = 0
		private var _buffer:Number = 0
		
		///滑块修正数字
		private var adjustNumber:Number = 8 //8
		
		private var _isUpdateImmediately:Boolean = true
		
		///构造函数
		public function sld_videoprogressbar()
		{
			sp_mousezone = new Sprite
			sp_backgroundBar = new Shape
			sp_playedBar = new Shape
			sp_bufferBar = new Shape
			sp_pointer = (SkinManager.getObject("controller_pointer"))?(SkinManager.getObject("controller_pointer")):new Sprite;
			sp_pointer.mouseChildren = false
			sp_pointer.mouseEnabled = false
			sp_pointer.y = 5
			config(100, 25)
			//sp_pointer.
			
			addChild(sp_mousezone)
			addChild(sp_backgroundBar)
			addChild(sp_bufferBar)
			addChild(sp_playedBar)
			addChild(sp_pointer)
			addUiListener()
		}
		
		/**
		 * 设置baseui
		 * @param	_w
		 * @param	_h
		 */
		public function config(_w:Number, _h:Number):void
		{
			configBaseUi(_w, _h)
			updatePosition()
		}
		
		/**
		 * 只设置宽度
		 * @param	_w
		 */
		public function configWidth(_w:Number):void
		{
			config(_w, getUiHeight)
		}
		
		/**
		 * 增加内部侦听器
		 */
		public function addUiListener():void
		{
			sp_mousezone.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent)
			//sp_mousezone.addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent)
			sp_mousezone.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
			sp_mousezone.addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent)
		}
		
		/**
		 * 移除内部侦听器
		 */
		public function removeUiListener():void
		{
			sp_mousezone.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent)
			//sp_mousezone.removeEventListener(MouseEvent.MOUSE_OUT, onMouseEvent)
			sp_mousezone.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
			sp_mousezone.removeEventListener(MouseEvent.MOUSE_OUT, onMouseEvent)
		}
		
		/**
		 * 设置已经播放长度
		 */
		public function set setPlayed(e:Number):void
		{if(_played==e){return}
			_played = e
			_isUpdateImmediately ? updatePosition() : null
		}
		
		/**
		 * 设置已经缓存长度
		 */
		public function set setBuffer(e:Number):void
		{if(_buffer==e){return}
			_buffer = e
			_isUpdateImmediately ? updatePosition() : null
		}
		
		/**
		 * 设置总播放长度
		 */
		public function set setMax(e:Number):void
		{if(_max==e){return}
			_max = e
			_isUpdateImmediately ? updatePosition() : null
		}
		
		/**
		 * 返回seek滑块最新的秒数.
		 */
		private function get seekPosition():Number
		{
			return (sp_pointer.x - adjustNumber) / (getUiWidth - adjustNumber) * _max
		}
		
		/**
		 * 鼠标事件,直接对舞台进行侦听移动,然后会进行一个ui校准
		 * @param	e
		 */
		private function onMouseEvent(e:MouseEvent):void
		{
			//防止用户没法点击到最小和最大的校准数
			var adjustX:Number = sp_background.mouseX
			if (sp_background.mouseX < adjustNumber)
			{
				adjustX = adjustNumber
			}
			if (sp_background.mouseX > getUiWidth - adjustNumber)
			{
				adjustX = getUiWidth - adjustNumber
			}
			//adjustX = sp_background.mouseX < adjustNumber ? adjustNumber : sp_background.mouseX
			//adjustX = sp_background.mouseX > getUiWidth - adjustNumber ? getUiWidth - adjustNumber : sp_background.mouseX
			//trace("adjustX", adjustX, "getUiWidth", getUiWidth)
			switch (e.type)
			{
				case MouseEvent.MOUSE_DOWN: 
					_isMouseDown = true
					//StageProxy.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent)
					//StageProxy.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
					sp_pointer.x = adjustX
					break;
				case MouseEvent.MOUSE_UP: 
					_isMouseDown = false
					dispatchEvent(new UIEvent(UIEvent.CHANGE, seekPosition))
					//StageProxy.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent)
					//StageProxy.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
					break;
				case MouseEvent.MOUSE_MOVE: 
					GlobalMouseTips.setTips(DateTimeUtils.formatSecond((e.localX - adjustNumber) / (getUiWidth - adjustNumber) * _max), e.stageX, e.stageY - 30)
					if (_isMouseDown)
					{
						sp_pointer.x = adjustX
					}
					break;
				case MouseEvent.MOUSE_OUT: 
					GlobalMouseTips.hideTips()
					break
				default: 
			}
		
		}
		
		/**
		 * 重新绘制所有模块大小,为了保证圆角方形
		 */
		private function updatePosition():void
		{
			if (getUiWidth < 0)
			{
				return
			}
			//trace("updatePosition", _max, _buffer, _played)
			sp_backgroundBar.graphics.clear()
			sp_backgroundBar.graphics.beginFill(0, 1)
			sp_backgroundBar.graphics.lineStyle(0.5, 0, 0)
			sp_backgroundBar.graphics.drawRoundRectComplex(0, 10, getUiWidth, 6, 3, 3, 3, 3)
			sp_backgroundBar.graphics.endFill()
			
			if (_played > _max)
			{
				_played = _max
			}
			if (_buffer > _max)
			{
				_buffer = _max
			}
			sp_playedBar.graphics.clear()
			sp_playedBar.graphics.beginFill(0x00A1D6, 1)
			sp_playedBar.graphics.lineStyle(0.5, 0, 0)
			sp_playedBar.graphics.drawRoundRectComplex(0, 10, getUiWidth * _played / _max, 6, 3, 3, 3, 3)
			sp_playedBar.graphics.endFill()
			
			sp_bufferBar.graphics.clear()
			sp_bufferBar.graphics.beginFill(0x007CAF, 1)
			sp_bufferBar.graphics.lineStyle(0.5, 0, 0)
			sp_bufferBar.graphics.drawRoundRectComplex(0, 10, getUiWidth * _buffer / _max, 6, 3, 3, 3, 3)
			sp_bufferBar.graphics.endFill()
			
			sp_mousezone.graphics.clear()
			sp_mousezone.graphics.beginFill(0, 0)
			sp_mousezone.graphics.drawRect(0, 0, getUiWidth, getUiHeight)
			sp_mousezone.graphics.endFill()
			
			if (!_isMouseDown)
			{
				sp_pointer.x = getUiWidth * _played / _max
				if (sp_pointer.x < adjustNumber)
				{
					sp_pointer.x = adjustNumber
				}
				if (sp_pointer.x > getUiWidth - adjustNumber)
				{
					sp_pointer.x = getUiWidth - adjustNumber
				}
			}
		}
		
		/**
		 * 设置是否在修改参数后立刻更新尺寸
		 */
		public function set updateImmediately(e:Boolean):void
		{
			_isUpdateImmediately = e
		}
		
		public function get updateImmediately():Boolean
		{
			return _isUpdateImmediately
		}
		
		/**
		 * 更新全部尺寸
		 */
		public function update():void
		{
			updatePosition()
		}
	}

}