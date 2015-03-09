package com.lizeqiangd.zweisystem.interfaces.colorpicker
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.config.BPFilter;
	import com.bilibili.player.system.config.BPSetting;
	//import com.bilibili.player.system.proxy.StageProxy;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class cp_display extends Sprite
	{
		private var sp_color:Sprite
		private var sp_textFrame:Sprite
		private var sp_textField:Sprite
		
		private var tx_display:TextField
		private var defaultTextFormat:TextFormat
		private var display_width:Number = 40
		private var display_height:Number = 20
		
		private var textfieldwidth:Number = 70
		private var textfieldheigth:Number = 20
		
		public function cp_display()
		{
			sp_color = new Sprite
			sp_textFrame = new Sprite
			sp_textField = new Sprite
			tx_display = new TextField
			defaultTextFormat = new TextFormat()
			defaultTextFormat.color = 0xA2A2A2
			defaultTextFormat.font = "黑体"
			defaultTextFormat.size = 15
			
			tx_display.maxChars = 6
			tx_display.multiline = false
			tx_display.selectable = true
			tx_display.autoSize = TextFieldAutoSize.LEFT
			tx_display.type = TextFieldType.INPUT
			
			tx_display.width = textfieldwidth
			tx_display.height = textfieldheigth
			
			tx_display.defaultTextFormat = defaultTextFormat
			tx_display.restrict = "a-f A-F 0-9"
			sp_color.graphics.beginFill(ValueObjectManager.getCommentStyleData.color, 1)
			sp_color.graphics.drawRect(0, 0, display_width, display_height)
			sp_color.graphics.endFill()
			
			addChild(sp_textField)
			addChild(sp_textFrame)
			addChild(sp_color)
			addChild(tx_display)
			addUiListener()
		}
		
		private function addUiListener():void
		{
			sp_textField.addEventListener(MouseEvent.MOUSE_DOWN, onTextFieldClickHandle)
			tx_display.addEventListener(MouseEvent.CLICK, onTextFieldClickHandle)
			tx_display.addEventListener(KeyboardEvent.KEY_UP, onTextInputHandle)
			tx_display.addEventListener(FocusEvent.FOCUS_OUT, onTextFocusOut)
		}
		
		private function onTextFocusOut(e:FocusEvent):void
		{
			if (tx_display.text == "")
			{
				setUintToText(ValueObjectManager.getCommentStyleData.color)
				
			}
			setDisplayColor = uint("0x" + tx_display.text)
			TweenLite.to(sp_textFrame, BPSetting.AnimationTime_ColorPickerDisplayTint, {tint: BPSetting.BilibiliGray})
		}
		
		private function setUintToText(e:uint):void
		{ //trace("setUintToText")
			var temp:String = ValueObjectManager.getCommentStyleData.color.toString(16).toUpperCase()
			//trace("setUintToText2")
			for (var i:int = temp.length; i < 6; i++)
			{
				temp = "0" + temp
			} //trace("setUintToText3")
			tx_display.text = temp
		}
		
		private function onTextFieldClickHandle(e:MouseEvent):void
		{
			//StageProxy.focus = tx_display
			TweenLite.to(sp_textFrame, BPSetting.AnimationTime_ColorPickerDisplayTint, {tint: BPSetting.BilibiliLightBlueUnit})
			tx_display.text = ""
		}
		
		private function onTextInputHandle(e:KeyboardEvent):void
		{
			ValueObjectManager.getCommentStyleData.color = uint("0x" + tx_display.text)
			TweenLite.to(sp_color, 0.3, {tint: ValueObjectManager.getCommentStyleData.color})
			dispatchEvent(new UIEvent(UIEvent.SELECTED))
		}
		
		/**
		 * 设置显示色块的大小参数,同时会让文字框在色块右边10像素
		 * @param	_x 色块x
		 * @param	_y 色块y
		 * @param	_w 色块width
		 * @param	_h 色块height
		 */
		public function configDisplay(_x:Number, _y:Number, _w:Number, _h:Number):void
		{
			sp_color.x = _x
			sp_color.y = _y
			display_width = _w
			display_height = _h
			tx_display.x = _x + _w + 10
			tx_display.y = _y - 2 //雅黑字体问题
			createTextFieldFrame()
		}
		
		private function createTextFieldFrame():void
		{
			sp_textField.x = tx_display.x
			sp_textField.y = tx_display.y + 2
			sp_textField.graphics.clear()
			sp_textField.graphics.beginFill(0, 0)
			sp_textField.graphics.drawRect(0, 0, textfieldwidth, textfieldheigth)
			sp_textField.graphics.endFill()
			
			sp_textFrame.x = tx_display.x
			sp_textFrame.y = tx_display.y + 2
			sp_textFrame.graphics.clear()
			sp_textFrame.graphics.lineStyle(1, BPSetting.BilibiliGray)
			sp_textFrame.graphics.moveTo(0, 0)
			sp_textFrame.graphics.lineTo(textfieldwidth, 0)
			sp_textFrame.graphics.lineTo(textfieldwidth, textfieldheigth)
			sp_textFrame.graphics.lineTo(0, textfieldheigth)
			sp_textFrame.graphics.lineTo(0, 0)
			sp_textFrame.filters = [BPFilter.DefaultGlowFilterByUint(BPSetting.BilibiliGray)]
		}
		
		public function set setDisplayColor(e:uint):void
		{
			TweenLite.to(sp_color, 0.3, {tint: ValueObjectManager.getCommentStyleData.color})
			setUintToText(ValueObjectManager.getCommentStyleData.color)
			//	trace("setDisplayColor")
		}
	}

}