package com.lizeqiangd.zweisystem.interfaces.colorpicker
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	
	/**
	 * 拾色器组件.包含色块区域和文字输入区域.
	 * 20150306 移除依赖库
	 * @author Lizeqiangd
	 */
	public class cp_general extends BaseUI
	{
		private var cp_cores:cp_core
		private var cp_displays:cp_display
		
		private var now_color:uint=0
		public function cp_general()
		{
			cp_cores = new cp_core
			cp_displays = new cp_display
			addChild(cp_cores)
			addChild(cp_displays)
			cp_cores.y = 30
			
			addUiListener()
		}
		
		//设置允许的颜色
		public function configColorVector(color_vector:Array):void
		{
			cp_cores.setColorArray = color_vector
			cp_cores.createColorVector()
		}
		
		public function configCore(color_width:Number, color_height:Number, color_distand:Number, color_in_row_cont:uint, color_pointer:Boolean = true):void
		{
			cp_cores.config(color_width, color_height, color_distand, color_in_row_cont, color_pointer)
		}
		
		public function configDisplay(display_color_x:Number, display_color_y:Number, display_color_width:Number, display_color_height:Number):void
		{
			cp_displays.configDisplay(display_color_x, display_color_y, display_color_width, display_color_height)
		}
		
		//设置默认颜色 
		public function setDefaultShowColor(e:uint):void
		{
			cp_displays.setDisplayColor = e
			now_color = e
			cp_cores.setShowColor(uint("0x" + e.toString(16)))
		}
		
		private function addUiListener():void
		{
			cp_displays.addEventListener(UIEvent.SELECTED, onDisplayTyping)
			cp_cores.addEventListener(UIEvent.SELECTED, onColorCoreSelected)
		}
		
		private function onDisplayTyping(e:UIEvent):void
		{
			cp_cores.setShowColor(now_color)
			dispatchEvent(new UIEvent(UIEvent.CHANGE))
		}
		
		private function onColorCoreSelected(e:UIEvent):void
		{
			cp_displays.setDisplayColor = now_color
			dispatchEvent(new UIEvent(UIEvent.CHANGE))
		}
	}

}