package com.lizeqiangd.zweisystem.interfaces.slider
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.mousetips.GlobalMouseTips;
	import flash.events.Event;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	//import com.greensock.TweenLite;
	/**
	 * 通用的slider...其他的可以继承这个就ok
	 * 很标准设置 now max 和min即可工作
	 * 监听unitevent.change事件即可
	 * @author Lizeqiangd
	 * 2015.01.12 增加通用的鼠标提示具体数值
	 * 2015.06.18 针对stage模式修改.其次修改了知否支持动画模式以及移除stageproxy的依赖,修正对舞台的支持.增加选择区域范围反制多层重叠.
	 */
	public class sld_general extends BaseUI
	{
		private var sp_pointer:Sprite
		
		private var sp_backgroundBar:Shape
		private var sp_maskBar:Shape
		private var sp_bar:Shape
		private var sp_selectionZone:Shape
		
		private var _isMouseDown:Boolean = false
		private var use_tweenlite:Boolean = false
		private var _isVertical:Boolean = false
		private var back_zone_alpha:Number = 0
		private var bar_height:int = 6
		
		///****运行时变量****
		private var _last_now:Number = 0;
		private var _enable:Boolean = true;
		private var _now:Number = 0
		private var _max:Number = 100
		private var _min:Number = 0
		private var adjustNumber:Number = 4
		
		public function sld_general()
		{
			sp_pointer = new Sprite
			sp_bar = new Shape
			sp_backgroundBar = new Shape
			sp_maskBar = new Shape
			sp_selectionZone = new Shape
			config(100, 20)
			addChild(sp_selectionZone)
			addChild(sp_backgroundBar)
			sp_maskBar.mask = sp_bar
			addChild(sp_bar)
			addChild(sp_maskBar)
			addUiListener()
		}
		/**
		 * 设置滑块的绝对Y值.用于垂直时的校准计算.
		 * @param	e
		 */
		public var slider_y:Number = 0
		
		private var bar_color_arr:Array = [1, 1];
		private var bar_alpha_arr:Array = [1, 1];
		private var bar_ratio_arr:Array = [0x00, 0xFF];
		private var bar_mask_color:uint = 0xcdcdcd;
		
		/**
		 * 设置bar的颜色.
		 * @param	bar_color
		 * @param	bar_alpha
		 * @param	bar_ratio
		 */
		public function configBarColor(bar_color:Array, bar_alpha:Array, bar_ratio:Array):void
		{
			bar_color.length ? bar_color_arr = bar_color : null;
			bar_alpha.length ? bar_alpha_arr = bar_alpha : null;
			bar_ratio.length ? bar_ratio_arr = bar_ratio : null;
		}
		
		/**
		 * 设置覆盖颜色
		 * @param	mask_color
		 */
		public function configBarMaskColor(mask_color:uint = 0)
		{
			bar_mask_color = mask_color
		}
		
		/**
		 * 整体设置包括刷新界面.
		 * @param	_w
		 * @param	_h
		 */
		public function config(_w:Number, _h:Number):void
		{
			
			configBaseUi(_w, _h)
			getUiHeight
			getUiWidth
			sp_selectionZone.graphics.clear()
			sp_selectionZone.graphics.beginFill(0, 1)
			sp_selectionZone.graphics.drawRect(0, 0, getUiWidth, getUiHeight)
			sp_selectionZone.graphics.endFill()
			sp_selectionZone.alpha = back_zone_alpha
			
			sp_backgroundBar.graphics.clear()
			sp_backgroundBar.graphics.beginFill(bar_mask_color, 1)
			sp_backgroundBar.graphics.drawRoundRectComplex(0, 0, getUiWidth, bar_height, 3, 3, 3, 3)
			sp_backgroundBar.graphics.endFill()
			
			var colors:Array = [0x4fc1e9, 0x4fc1e9]; //[0x55ccff, 0x00C2FB];
			var alphas:Array = [1, 1]; //可以设置渐变两边的alpha值,1<alpha>0
			var ratios:Array = [0x00, 0xFF];
			var matr:Matrix = new Matrix
			matr.createGradientBox(getUiWidth, 20, 0, 0, 0);
			sp_maskBar.graphics.clear()
			sp_maskBar.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr, SpreadMethod.PAD);
			sp_maskBar.graphics.drawRoundRectComplex(0, 0, getUiWidth, bar_height, 3, 3, 3, 3)
			sp_maskBar.graphics.endFill()
			sp_bar.graphics.clear()
			sp_bar.graphics.beginFill(1, 1)
			sp_bar.graphics.drawRect(0, 0, 10, bar_height)
			sp_bar.graphics.endFill()
			sp_backgroundBar.y = sp_maskBar.y = sp_bar.y = int(getUiHeight / 2) - int(bar_height / 2)
			updatePosition()
		}
		
		/**
		 * 便利方法:只设置长度
		 * @param	_w
		 */
		public function configWidth(_w:Number):void
		{
			config(_w, getUiHeight)
		}
		
		/**
		 * 高级设置内容.
		 * @param	barHeight
		 * @param	show_zone
		 * @param	is_vertical
		 */
		public function configAdvance(barHeight:int = 6, show_zone:Number = 0, is_vertical:Boolean = false):void
		{
			bar_height = barHeight;
			back_zone_alpha = show_zone;
			_isVertical = is_vertical;
		}
		
		/**
		 * 设置最大值
		 */
		public function set setMax(value:Number):void
		{
			if (_max == value)
			{
				return
			}
			_max = value
			updatePosition()
		}
		
		/**
		 * 设置最小值
		 */
		public function set setMin(value:Number):void
		{
			if (_min == value)
			{
				return
			}
			_min = value
			updatePosition()
		}
		
		/**
		 * 直接设置目前大小.
		 */
		public function set setNow(value:Number):void
		{
			if (_now == value)
			{
				return
			}
			_now = value
			updatePosition()
		}
		
		/**
		 * 设置是否可以使用.
		 * 使用场景:静音等.调用后会触发UIEvent.Change事件.可能会与现有机制重复触发.
		 */
		public function set available(value:Boolean):void
		{
			_enable = value;
			if (!_enable)
			{
				_last_now = _now;
				setNow = 0
			}
			else
			{
				_now == 0 ? setNow = _last_now : null;
			}
		}
		
		public function addUiListener():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent)
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent)
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseEvent)
			//this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
		}
		
		public function removeUiListener():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent)
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseEvent)
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseEvent)
			//this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
		}
		
		/**
		 * 鼠标方法
		 * @param	e
		 */
		private function onMouseEvent(e:MouseEvent):void
		{
			//防止用户没法点击到最小和最大的校准数
			if (e.target == this || e.target == this.stage)
			{
				var get_mouse_x:Number = _isVertical ? getUiWidth - e.stageY + slider_y : e.stageX - this.x;
				//trace('get_mouse_x',get_mouse_x,'stage_xy',e.stageY,'slider_y',slider_y,'this.y', this.y, 'this.p.y',this.parent.y, 'this.p.p.y',this.parent.parent.y)
				var adjustX:Number = get_mouse_x
				get_mouse_x < adjustNumber ? adjustX = 0 : null
				getUiWidth - get_mouse_x < adjustNumber ? adjustX = getUiWidth : null
			}
			else
			{
				return
			}
			
			switch (e.type)
			{
			case MouseEvent.MOUSE_DOWN: 
				if (use_tweenlite)
				{
					//TweenLite.to(sp_bar, 0.5, {width: adjustX, onUpdate: onUpdateHandle, onComplete: onUpdateComplete})				
				}
				else
				{
					sp_bar.width = adjustX
					onUpdateHandle()
				}
				GlobalMouseTips.setTips(_now.toFixed(2), e.stageX, e.stageY - 30)
				this.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent)
				this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
				break;
			case MouseEvent.MOUSE_UP: 
				if (!use_tweenlite)
				{
					onUpdateComplete()
				}
				this.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent)
				this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
				GlobalMouseTips.hideTips()
				break;
			case MouseEvent.MOUSE_OUT: 
				//onUpdateHandle()
				//this.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent)
				//this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent)
				//GlobalMouseTips.hideTips()
				break;
			case MouseEvent.MOUSE_MOVE: 
				if (e.buttonDown)
				{
					if (use_tweenlite)
					{
						//TweenLite.to(sp_bar, 0.5, {width: adjustX, onUpdate: onUpdateHandle, onComplete: onUpdateComplete})
					}
					else
					{
						sp_bar.width = adjustX
						onUpdateHandle()
					}
				}
				GlobalMouseTips.setTips(_now.toFixed(2), e.stageX, e.stageY - 30)
				break;
			case MouseEvent.MOUSE_OVER: 
				if (!e.buttonDown)
				{
					GlobalMouseTips.setTips(_now.toFixed(2), e.stageX, e.stageY - 30)
				}
				break;
			default: 
			}
		}
		
		/**
		 * 完成动画调度事件.
		 */
		private function onUpdateComplete():void
		{
			_now = (sp_bar.width / getUiWidth) * (_max - _min)
			dispatchEvent(new UIEvent(UIEvent.CHANGE, _now.toFixed(2)))
		}
		
		/**
		 * 位置更新,不会触发调度事件
		 */
		private function updatePosition():void
		{
			sp_bar.width = _now / (_max - _min) * getUiWidth
		}
		
		/**
		 * 时刻更新
		 * @param	e
		 */
		private function onUpdateHandle(e:Event = null):void
		{
			onUpdateComplete()
			//_now = (sp_bar.width / getUiWidth) * (_max - _min)
			//dispatchEvent(new UIEvent(UIEvent.CHANGE, _now.toFixed(2)))
		}
	}
}