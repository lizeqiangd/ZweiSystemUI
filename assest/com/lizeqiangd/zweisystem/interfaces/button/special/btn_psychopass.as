package com.lizeqiangd.zweisystem.interfaces.button.special
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseAssestButton;
	
	public class btn_psychopass extends BaseAssestButton
	{
		public function btn_psychopass()
		{
			super(true)
			tx_english.mouseEnabled = false
		}
		
		public function set title2(s:String)
		{
			this.tx_english.text = s
		}
		
		public function get titile2():String
		{
			return this.tx_english.text
		}
	
	}
}