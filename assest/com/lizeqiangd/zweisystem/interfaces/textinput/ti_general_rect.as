package com.lizeqiangd.zweisystem.interfaces.textinput
{
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.display.Sprite;
	
	public class ti_general_rect extends MovieClip
	{
		public var mc_frame:Sprite = new Sprite;
		public var mc_display:Sprite
		public var tx_title:TextField
		
		public function ti_general_rect()
		{
			removeChild(mc_display);
			mc_display = null;
			//textWidth=this.width 
			//width = 120;
			//setTimeout(createFrame,100)
			createFrame();
		}
		
		[Inspectable(name="textWidth",type="Number",defaultValue=140)]
		public function set textWidth(v:Number):void
		{
			this.tx_title.width = v;
			createFrame();
		}
		
		private function createFrame():void
		{
			mc_frame.graphics.clear();
			mc_frame.graphics.lineStyle(1, 0xFF9900);
			mc_frame.graphics.drawRect(0, 0, width, height);
			mc_frame.graphics.endFill();
			addChild(mc_frame);
			mc_frame.filters = [new GlowFilter(0xFF9900, 1, 5, 5, 1, 1)]
		}
		
		[Inspectable(name="password",type="Boolean",defaultValue=false)]
		public function set password(v:Boolean):void
		{
			this.tx_title.displayAsPassword = v;
		}
		
		[Inspectable(name="text",type="String",defaultValue="")]
		public function set text(s:String):void
		{
			this.tx_title.text = s;
		}
		
		public function get text():String
		{
			return this.tx_title.text;
		}
		
		public function clear():void
		{
			this.tx_title.text = "";
		}
		
		public function get tf():TextField
		{
			return tx_title
		}
	}

}