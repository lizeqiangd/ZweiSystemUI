package com.lizeqiangd.zweisystem.interfaces.baseunit
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	
	/**
	 * 任何显示对象的基本项.
	 * @author Lizeqiangd
	 * 2014.10.16:重新绘制边框的时候会让边框置顶.
	 * 2015.04.10:阴影的绘制自动识别框体颜色.
	 */
	public class BaseUI extends Sprite
	{
		public var sp_frame:Shape
		public var sp_background:Sprite
		private var color_frame:uint = 0x00c2fb
		private var color_background:uint = 0xffffff
		
		private var baseUiWidth:Number = 40
		private var baseUiHeight:Number = 40
		
		public function BaseUI()
		{
			sp_frame = new Shape
			sp_background = new Sprite
			addChild(sp_background)
			addChild(sp_frame)
		}
		
		/**
		 * 设置本显示对象的大小范围(仅用于其他功能获取用),防止实际大小和目标大小不同.
		 * @param	ui_width
		 * @param	ui_height
		 */
		public function configBaseUi(ui_width:Number, ui_height:Number):void
		{
			baseUiWidth = ui_width
			baseUiHeight = ui_height
		}
		
		/**
		 * 绘制UI边框.
		 * @param	needFilter
		 */
		public function createFrame(needFilter:Boolean = true):void
		{
			sp_frame.graphics.clear()
			sp_frame.graphics.lineStyle(0.5, color_frame, 0.5)
			sp_frame.graphics.moveTo(0, 0)
			sp_frame.graphics.lineTo(getUiWidth, 0)
			sp_frame.graphics.lineTo(getUiWidth, getUiHeight)
			sp_frame.graphics.lineTo(0, getUiHeight)
			sp_frame.graphics.lineTo(0, 0)
			createFreameFilter(needFilter)
		}
		
		public function createFreameFilter(needFilter:Boolean = true):void {
			sp_frame.filters = needFilter ? [new GlowFilter(color_frame, 1, 5, 5, 1, 1)] : []
		}
		/**
		 * 设置边框的颜色(不会重新绘制,请调用createFrame() )
		 */
		public function set setFrameColor(e:uint):void
		{
			color_frame = e
		}
		
		/**
		 * 取得边框的颜色
		 */
		public function get getFrameColor():uint
		{
			return color_frame
		}
		
		/**
		 * 创建背景色,操作的是sp_background,开发者可以对此增加鼠标事件等操作.
		 * @param	background_alpha
		 */
		public function createBackground(background_alpha:Number = 1):void
		{
			sp_background.graphics.clear()
			sp_background.graphics.beginFill(color_background, background_alpha)
			sp_background.graphics.drawRect(0, 0, getUiWidth, getUiHeight)
			sp_background.graphics.endFill()
		}
		
		/**
		 * 设置背景颜色
		 * @param	e
		 */
		public function set setBackGroundColor(e:uint):void
		{
			color_background = e
		}
		
		/**
		 * @属性 获取BaseUi中的width参数
		 */
		public function get getUiWidth():Number
		{
			return baseUiWidth
		}
		
		/**
		 * @属性 获取BaseUi中的height参数
		 */
		public function get getUiHeight():Number
		{
			return baseUiHeight
		}
	
	}

}