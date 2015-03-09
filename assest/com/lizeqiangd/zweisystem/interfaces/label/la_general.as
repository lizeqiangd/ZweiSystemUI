package com.lizeqiangd.zweisystem.interfaces.label
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class la_general extends Sprite
	{
		public var tx_title:TextField;

		[Inspectable(name="title",type="String",defaultValue="")]
		public function set title(t:String)
		{
			this.tx_title.text = t;
			tx_title.width = tx_title.textWidth + 10;
		}
		
		public function set text(t:String)
		{
			this.tx_title.text = t;
			tx_title.width = tx_title.textWidth + 10;
		}
		
		public function get title():String
		{
			return tx_title.text
		}
		
		public function get text():String
		{
			return tx_title.text
		}
		
	}
}