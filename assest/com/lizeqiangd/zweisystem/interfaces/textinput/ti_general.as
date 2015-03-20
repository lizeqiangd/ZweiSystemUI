package com.lizeqiangd.zweisystem.interfaces.textinput
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	
	public class ti_general extends Sprite
	{
		public var mc_frame:Sprite = new Sprite;
		public var tx_title:TextField
		
		public function ti_general()
		{
			tx_title.addEventListener(KeyboardEvent.KEY_DOWN, onTypeEnter,false,0,true)
		}
		
		private function onTypeEnter(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				dispatchEvent(new UIEvent(UIEvent.SUBMIT, tx_title.text))
			}
		}
		
		/*
		 * 设置为密码显示模式.
		 */
		[Inspectable(name="password",type="Boolean",defaultValue=false)]
		public function set password(v:Boolean):void
		{
			this.tx_title.displayAsPassword = v;
		}
		
		/*
		 * 获取文本文字.
		 */
		[Inspectable(name="title",type="String",defaultValue="")]
		public function set title(s:String):void
		{
			this.tx_title.text = s;
		}
		
		/*
		 * 获取文本文字.
		 */
		public function set text(s:String):void
		{
			this.tx_title.text = s;
		}
		
		/*
		 * 读取文本文字
		 */
		public function get title():String
		{
			return this.tx_title.text;
		}
		
		/*
		 * 读取文本文字
		 */
		public function get text():String
		{
			return this.tx_title.text;
		}
		
		public function get tf():TextField
		{
			return tx_title
		}
		
		public function clear():void
		{
			this.tx_title.text = "";
		}
	}

}