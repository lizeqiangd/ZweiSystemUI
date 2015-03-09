package com.lizeqiangd.zweisystem.interfaces.slider
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.mousetips.GlobalMouseTips;
	import com.bilibili.player.system.proxy.StageProxy;
	import com.greensock.TweenLite;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	/**
	 * 通用的slider...其他的可以继承这个就ok
	 * 很标准设置 now max 和min即可工作
	 * 监听unitevent.change事件即可
	 * @author Lizeqiangd
	 * 2015.01.12 增加通用的鼠标提示具体数值
	 */
	public class sld_general extends BaseUI
	{
		private var sp_pointer:Sprite
		
		private var sp_backgroundBar:Shape
		private var sp_maskBar:Shape
		private var sp_bar:Shape
		
		private var _isMouseDown:Boolean = false
		
		//private var 
		public function sld_general()
		{
			sp_pointer = new Sprite
			sp_bar = new Shape
			sp_backgroundBar = new Shape
			sp_maskBar = new Shape
			
			config(100, 20)
			//sp_pointer.
			
			addChild(sp_backgroundBar)
			sp_maskBar.mask = sp_bar
			//sp_bar.mask = sp_maskBar
			addChild(sp_bar)
			addChild(sp_maskBar)
			addUiListener()
		}
		
		public function config(_w:Number, _h:Number):void
		{
			sp_backgroundBar.graphics.clear()
			sp_backgroundBar.graphics.beginFill(0, 1)
			//sp_backgroundBar.graphics.lineStyle(0.5, 0, 0)
			sp_backgroundBar.graphics.drawRoundRectComplex(0, 0, _w, 6, 3, 3, 3, 3)
			sp_backgroundBar.graphics.endFill()
			
			var colors:Array = [0x55ccff, 0x0000ff]; //[0x55ccff, 0x00C2FB];
			var alphas:Array = [1, 1]; //可以设置渐变两边的alpha值,1<alpha>0
			var ratios:Array = [0x00, 0xFF];
			var matr:Matrix = new Matrix
			matr.createGradientBox(_w, 20, 0, 0, 0);
			sp_maskBar.graphics.clear()
			sp_maskBar.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr, SpreadMethod.PAD);
			//sp_maskBar.graphics.beginFill(0x33ccff, 1)			
			sp_maskBar.graphics.drawRoundRectComplex(0, 0, _w, 6, 3, 3, 3, 3)
			//sp_maskBar.graphics.lineStyle(0.5, 0, 0)
			//sp_maskBar.graphics.drawRect(0, 0, 10, 6)
			sp_maskBar.graphics.endFill()
			
			//sp_bar.graphics.drawRect(0, 0, 100, 100);
			sp_bar.graphics.clear()
			//sp_bar.graphics.lineStyle(0.5, 0, 0)
			sp_bar.graphics.beginFill(0x33ccff, 1)
			sp_bar.graphics.drawRect(0, 0, 10, 6)
			//sp_bar.graphics.drawRoundRectComplex(0, 0, _w, 6, 3, 3, 3, 3)
			sp_bar.graphics.endFill()
			
			//sp_bar.width = 0
			sp_backgroundBar.y = sp_maskBar.y = sp_bar.y = int(_h / 2)
			configBaseUi(_w, _h)
			updatePosition()
		}
		
		public function configWidth(_w:Number):void
		{
			config(_w, getUiHeight)
		}
		
		public function set setMax(value:Number):void
		{
			if (_max == value)
			{
				return
			}
			_max = value
			updatePosition()
		}
		
		public function set setMin(value:Number):void
		{
			if (_min == value)
			{
				return
			}
			_min = value
			updatePosition()
		}
		
		public function set setNow(value:Number):void
		{
			if (_now == value)
			{
				return
			}
			_now = value
			updatePosition()
		}
		
		private var _now:Number = 0
		private var _max:Number = 100
		private var _min:Number = 0
		private var adjustNumber:Number = 8
		
		public function addUiListener():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent)
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent)
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseEvent)
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
		}
		
		public function removeUiListener():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent)
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseEvent)
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseEvent)
			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
		}
		
		private function onMouseEvent(e:MouseEvent):void
		{
			//防止用户没法点击到最小和最大的校准数
			var adjustX:Number = e.localX
			e.localX < adjustNumber ? adjustX = 0 : null
			getUiWidth - e.localX < adjustNumber ? adjustX = getUiWidth : null
			//trace(_now)
			switch (e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					
					StageProxy.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent)
					TweenLite.to(sp_bar, 0.5, {width: adjustX, onUpdate: onUpdateHandle, onComplete: onUpdateComplete})
					//TweenLite.to(sp_bar, 0.5, {width: adjustX, onUpdate: onUpdateHandle,onComplete:onUpdateComplete})
					break;
				case MouseEvent.MOUSE_UP: 
					StageProxy.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent)
					break;
				case MouseEvent.MOUSE_OUT: 
					GlobalMouseTips.hideTips()
					break;
				case MouseEvent.MOUSE_MOVE: 
					if (e.buttonDown)
					{
						GlobalMouseTips.setTips(_now.toFixed(2), e.stageX, e.stageY - 30)
						TweenLite.to(sp_bar, 0.5, {width: adjustX, onUpdate: onUpdateHandle, onComplete: onUpdateComplete})
							//TweenLite.to(sp_bar, 0.5, {width: adjustX, onUpdate: onUpdateHandle,onComplete:onUpdateComplete})
					}
					break;
				case MouseEvent.MOUSE_OVER: 
					if (e.buttonDown)
					{ //trace("anime")
						//	TweenLite.to(sp_bar, 0.5, {width: e.localX})
					}
					break;
				default: 
			}
		
		}
		
		private function onUpdateComplete():void
		{
			_now = (sp_bar.width / getUiWidth) * (_max - _min)
			dispatchEvent(new UIEvent(UIEvent.CHANGE, _now.toFixed(2)))
		}
		
		private function updatePosition():void
		{
			sp_bar.width = _now / (_max - _min) * getUiWidth
			//dispatchEvent(new UnitEvent(UnitEvent.CHANGE, _now.toFixed(2)))
		}
		
		private function onUpdateHandle():void
		{
			_now = (sp_bar.width / getUiWidth) * (_max - _min)
			dispatchEvent(new UIEvent(UIEvent.CHANGE, _now.toFixed(2)))
		}
	
	}

}