package com.lizeqiangd.zweisystem.interfaces.textinput
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextInteractionMode;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class ti_textfield extends BaseUI
	{
		private var tf:TextField
		
		public function ti_textfield()
		{
			configBaseUi(200, 50)
			tf = new TextField
			tf.multiline = true
			tf.wordWrap=true
			tf.type='input'
			tf.defaultTextFormat = new TextFormat("微软雅黑", 12, 0xff9900)
			addChild(tf)
			createFrame(true)	
		}
		
		public function config(w:Number, h:Number):void
		{
			configBaseUi(w, h)
			tf.width = w
			tf.height = h
			createFrame(true)			
		}
		
		public function set text(s:String):void
		{
			this.title = s;
		}
		
		public function set title(s:String):void
		{
			this.tf.text = s
		}
		
		public function get title():String
		{
			return this.tf.text
		}
		
		public function get text():String
		{
			return this.title;
		}
	}

}