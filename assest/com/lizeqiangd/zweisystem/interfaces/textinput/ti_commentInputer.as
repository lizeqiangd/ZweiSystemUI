package com.lizeqiangd.zweisystem.interfaces.textinput
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUi;
	import com.bilibili.player.components.SelectionColor;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.bilibili.player.system.proxy.StageProxy;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class ti_commentInputer extends BaseUi
	{
		private var commentTextField:TextField
		
		public function config(_w:Number, _h:Number):void
		{
			configBaseUi(_w, _h)
			this.setFrameColor = BPSetting.BilibiliGray
			commentTextField = new TextField()
			commentTextField.defaultTextFormat = BPTextFormat.CommentSenderTextFormat
			commentTextField.y = 2
			commentTextField.type = TextFieldType.INPUT
			commentTextField.width = getUiWidth
			commentTextField.text = "	今天没吃药,我觉得我萌萌哒!!!  "
			configBaseUi(getUiWidth, getUiHeight)
			addChild(commentTextField)
			addUiListener()
						
			//SelectionColor.setFieldSelectionColor(commentTextField,BPSetting.BilibiliLightBlueUnit)
		}
		
		private function addUiListener():void
		{
			commentTextField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				dispatchEvent(new UIEvent(UIEvent.SUBMIT))
			}
		}
		
		public function focus():void
		{
			StageProxy.focus = commentTextField
		}
		
		public function clear():void
		{
			commentTextField.text = ""
		}
		
		public function set text(e:String):void
		{
			commentTextField.text = e
		}
		
		public function get text():String
		{
			return commentTextField.text
		}
		
		public function set enable(e:Boolean):void
		{
			if (e)
			{
				commentTextField.mouseEnabled = true
				commentTextField.type = TextFieldType.INPUT				
				commentTextField.selectable = true
				//commentTextField.autoSize=TextFieldAutoSize.LEFT
				commentTextField.defaultTextFormat = BPTextFormat.CommentSenderTextFormat
			}
			else
			{
				commentTextField.mouseEnabled = false
				commentTextField.selectable = false
				commentTextField.type = TextFieldType.DYNAMIC
				//commentTextField.autoSize=TextFieldAutoSize.CENTER
				commentTextField.textColor=BPSetting.CommentSenderTextDisableColor
			}
		}
		
		public function setWidth(_w:Number):void
		{
			
			configBaseUi(_w, getUiHeight)
			commentTextField.width = getUiWidth
			createFrame(false)
			createBackground()
		}
	}

}