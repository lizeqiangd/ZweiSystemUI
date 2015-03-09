package com.lizeqiangd.zweisystem.interfaces.textfield
{
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class tx_static extends TextField
	{
		public function tx_static()
		{
			this.selectable = false;
			this.mouseEnabled = false;
		}
		
		override public function set text(e:String):void
		{
			super.text = e
			this.width = this.textWidth + 20
		}
		
		override public function get text():String
		{
			return super.text
		}
	}

}