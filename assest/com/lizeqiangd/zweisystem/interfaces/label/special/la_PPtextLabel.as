package com.lizeqiangd.zweisystem.interfaces.label.special
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class la_PPtextLabel extends Sprite
	{
		public function set title(e:String)
		{
			this.tx_title.text = e
		}
		
		public function get title():String
		{
			return tx_title.text 
		}
	}

}