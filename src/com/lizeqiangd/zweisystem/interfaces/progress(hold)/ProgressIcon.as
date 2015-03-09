package com.lizeqiangd.zweisystem.interfaces.progress(hold)
{
	import flash.display.Sprite;
	public class ProgressIcon extends Sprite 
	{
		public function ProgressIcon()
		{
			precent = 0;
		}
		public function set precent(p:Number )
		{
			this.tx_text.text = p * 100 + "%";
		}

	}
}