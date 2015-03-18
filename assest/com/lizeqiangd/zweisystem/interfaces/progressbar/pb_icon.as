package com.lizeqiangd.zweisystem.interfaces.progressbar
{
	import flash.display.Sprite;
	
	public class pb_icon extends Sprite
	{
		public function pb_icon()
		{
			title = '00';
		}
		
		//public function set precent(p:Number )
		//{
		//this.tx_text.text = p * 100 ;
		//}
		public function set title(t:*):void
		{
			this.tx_text.text = String(t)
		}
	
	}
}