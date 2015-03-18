package com.lizeqiangd.zweisystem.interfaces.label.special
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class la_psychopass extends Sprite
	{
		public function set title(e:String)
		{
			this.tx_title.text = e
			this.mc_bg.width=this.tx_title.textWidth+5
		}
		
		public function get title():String
		{
			return tx_title.text 
		}
	}

}