package com.lizeqiangd.zweisystem.interfaces.checkbox
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseButton;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author lizeqiangd
	 */
	public class cb_general extends BaseButton
	{
		
		private var _seleted:Boolean = false
		private var tx_title:TextField
		private var sp_selectedPointer:Shape
		private var sp_selectBox:Shape
		
		public function cb_general()
		{
			sp_selectBox = new Shape
			sp_selectBox.graphics.beginFill(0x2f2f2f, 0.5)
			sp_selectBox.graphics.drawRect(0, 0, 20, 20)
			sp_selectBox.graphics.endFill()
			sp_selectBox.alpha = 0.1
			addChild(sp_selectBox)
			
			sp_selectedPointer = new Shape
			sp_selectedPointer.graphics.beginFill(0x00c2fb, 1)
			sp_selectedPointer.graphics.lineStyle(1, 0x00c2fb, 1)
			sp_selectedPointer.graphics.drawRect(4.5, 4.5, 12, 12)
			sp_selectedPointer.graphics.endFill()
			sp_selectedPointer.visible = false
			addChild(sp_selectedPointer)
			
			tx_title = new TextField
			tx_title.defaultTextFormat = new TextFormat("微软雅黑", 12, 0xff9900)
			tx_title.selectable = false
			tx_title.mouseEnabled = false
			tx_title.x = 20
			
			config()
		}
		
		public function config():void
		{
			this.configBaseButton(20, 20)
			createButton()
			createBackground(1)
			createFrame(false)
			//setFrameColor=(0x2f2f2f)		
		}
		
		/**
		 * 绘制UI边框.
		 * @param	needFilter
		 */
		override public function createFrame(needFilter:Boolean = true):void
		{
			//sp_frame.x = sp_frame.y = 0
			sp_frame.graphics.clear()
			sp_frame.graphics.lineStyle(0.5, 0x0033ff, 1)
			sp_frame.graphics.drawRect(0, 0, getUiHeight, getUiHeight)
			//	sp_frame.filters = needFilter ? [BPFilter.DefaultLightblueGlowFilter] : []
		}
		
		public function set title(value:String):void
		{
			if (value)
			{
				tx_title.text = value
				tx_title.width = tx_title.textWidth + 6
				configBaseButton(tx_title.width + getUiHeight, getUiHeight)
				createButton()
				createBackground(1)
				addChild(tx_title)
			}
			else
			{
				removeChild(tx_title)
			}
		}
		
		override public function onMouseClick(e:MouseEvent):void
		{
			_seleted = !_seleted
			sp_selectedPointer.visible = _seleted
			dispatchEvent(new UIEvent(UIEvent.SELECTED, _seleted))
			dispatchEvent(new UIEvent(UIEvent.CLICK, _seleted))
		}
		
		override public function onMouseDown(e:MouseEvent):void
		{
			sp_selectBox.alpha = 0.5
		}
		
		override public function onMouseUp(e:MouseEvent):void
		{
			sp_selectBox.alpha = 0.0
		}
		
		override public function onMouseOver(e:MouseEvent):void
		{
			sp_selectBox.alpha = 0.3
		}
		
		override public function onMouseOut(e:MouseEvent):void
		{
			sp_selectBox.alpha = 0.0
		}
		
		public function get selected():Boolean
		{
			return _seleted
		}
		
		public function set selected(e:Boolean):void
		{
			_seleted = e
		}
	}

}