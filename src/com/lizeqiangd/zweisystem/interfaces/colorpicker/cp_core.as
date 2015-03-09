package com.lizeqiangd.zweisystem.interfaces.colorpicker
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * 2014.07.31
	 * 拾色器的色块部分.通过输入uint数组来显示颜色.
	 * 同时支持外部选择颜色,当外部输入的颜色在显示列表中.
	 * 则会让指示框出现在目标颜色,否则无视.(如果开启指示框功能)
	 * 色块的大小和颜色和间距和行数都是可操控的.
	 *
	 * 同时可配合cp_display组成cp_general.
	 * @author Lizeqiangd
	 */
	public class cp_core extends Sprite
	{
		private var data:Object
		private var color_width:Number
		private var color_heigth:Number
		private var color_rows:uint
		private var color_lines:uint
		private var color_distand:Number
		private var isUsePointer:Boolean = false
		private var mc_selector:Sprite
		private var color_array:Array
		
		public var now_color:uint=0
		public function cp_core()
		{
			mc_selector = new Sprite
			this.addChildAt(mc_selector, 0)
			
			mc_selector.mouseEnabled = false
			addUiListener()
		}
		
		private function addUiListener():void
		{
			this.addEventListener(MouseEvent.CLICK, onMouseClick)
		}
		
		///响应鼠标点击 色块
		private function onMouseClick(e:MouseEvent):void
		{
			var clickColor:uint = getColorByXY(e.localX, e.localY)
			var p:Point = getPositionByColorIndex(getColorIndexByColor(clickColor))
			//	TweenLite.to(mc_selector, 0.3, {alpha: 1, x: Math.floor(e.localX / (color_width + color_distand)) * (color_width + color_distand), y: Math.floor(e.localY / (color_heigth + color_distand)) * (color_heigth + color_distand)})
			//TweenLite.to(mc_selector, BPSetting.AnimationTime_ColorPickerCoreMovement, { alpha: 1, x: p.x, y: p.y } )
			mc_selector.x = p.x
			mc_selector.y = p.y
			mc_selector.alpha = 1
			
			now_color = clickColor
			dispatchEvent(new UIEvent(UIEvent.SELECTED))
		}
		
		///通过xy 找颜色
		private function getColorByXY(_x:Number, _y:Number):uint
		{
			var return_uint:uint = color_array[Math.floor(_x / (color_width + color_distand)) + Math.floor(_y / (color_heigth + color_distand)) * color_rows]
			return return_uint
		}
		
		///通过 color uint 找 index
		private function getColorIndexByColor(e:uint):int
		{
			for (var i:uint = 0; i < color_array.length; i++)
			{
				if (color_array[i] == e)
				{
					return i
				}
			}
			return -1
		}
		
		///通过 index 算出x和y
		private function getPositionByColorIndex(i:uint):Point
		{
			var p:Point = new Point
			p.x = (i % color_rows) * (color_width + color_distand)
			p.y = Math.floor(i / color_rows) * (color_heigth + color_distand)
			return p
		}
		
		/**
		 *把颜色数组添加进入.所有颜色从左至右,然后从上至下
		 */
		public function set setColorArray(e:Array):void
		{
			if (e.length < 1)
			{
				trace("cp_general.dataProvider:你在逗我吗.数组没长度我干啥吃?")
				return;
			}
			color_array = e
		}
		
		///列数
		public function set setMaxRows(e:uint):void
		{
			color_rows = e
		}
		
		///行数???有用吗???
		public function set setMaxLine(e:uint):void
		{
			color_lines = e
		}
		
		///色块的宽度
		public function set setColorWidth(e:Number):void
		{
			color_width = e
		}
		
		///色块的高度
		public function set setColorHeight(e:Number):void
		{
			color_heigth = e
		}
		
		///色块的间距
		public function set setDistand(e:Number):void
		{
			color_distand = e
		}
		
		///制作指针
		public function set setUsePointer(e:Boolean):void
		{
			mc_selector.graphics.clear()
			isUsePointer = e
			if (isUsePointer)
			{
				mc_selector.graphics.clear()
				mc_selector.graphics.lineStyle(2, 0x3399ff)
				mc_selector.graphics.moveTo(0, 0)
				mc_selector.graphics.lineTo(color_width, 0)
				mc_selector.graphics.lineTo(color_width, color_heigth)
				mc_selector.graphics.lineTo(0, color_heigth)
				mc_selector.graphics.lineTo(0, 0)
				
			}
		}
		
		///设置ui整体情况
		public function config(_w:Number, _h:Number, _distand:Number, _row:uint, usePointer:Boolean = false):void
		{
			setMaxRows = _row
			setColorWidth = _w
			setColorHeight = _h
			setDistand = _distand
			setUsePointer = usePointer
		
		}
		
		///当其他地方输入的颜色和库里面的颜色相等的时候 选择按钮进入,否则自动隐藏选中指针.如果没开启选中指针则无效果.
		public function setShowColor(e:uint):void
		{
			if (isUsePointer)
			{
				if (getColorIndexByColor(e) != -1)
				{
					var p:Point = this.getPositionByColorIndex(getColorIndexByColor(e))
					//TweenLite.to(mc_selector, BPSetting.AnimationTime_ColorPickerCoreMovement, { alpha: 1, x: p.x, y: p.y } )
					mc_selector.x = p.x
					mc_selector.y = p.y
					mc_selector.alpha = 1
				}
				else
				{
					//TweenLite.to(mc_selector, BPSetting.AnimationTime_ColorPickerCoreMovement, {alpha: 0})
					
					mc_selector.alpha = 0
				}
			}
		}
		
		public function createColorVector():void
		{
			this.graphics.clear()
			var w:uint = 0
			var h:uint = 0
			for (var i:uint = 0; i < color_array.length; i++)
			{
				w = i % color_rows
				h = Math.floor(i / color_rows)
				this.graphics.beginFill(color_array[i], 1)
				this.graphics.drawRect(w * (color_width + color_distand), h * (color_heigth + color_distand), color_width, color_heigth)
				this.graphics.endFill()
			}
		}
	}
}