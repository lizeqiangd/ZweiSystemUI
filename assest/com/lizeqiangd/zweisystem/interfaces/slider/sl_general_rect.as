package com.lizeqiangd.zweisystem.interfaces.slider
{
	//import com.lizeqiangd.zweisystem.events.PlayerEvent;
	import com.lizeqiangd.zweisystem.events.UnitEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class sl_general_rect extends MovieClip
	{
		
		public function sl_general_rect()
		{
			addUiListener();
			onClick(null);
		}
		
		private function addUiListener()
		{
			mc_reset.addEventListener(MouseEvent.CLICK, onClick);
			mc_reset.addEventListener(MouseEvent.MOUSE_UP, onUp);
			mc_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			mc_btn.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			mc_btn.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		private function onClick(e:MouseEvent)
		{
			mc_pointer.x = 45;
			update();
			onUp(null)
		}
		
		private function onDown(e:MouseEvent)
		{
			if (e.localX * 2 - 5 < 90)
			{
				mc_pointer.x = e.localX * 2 - 5;
					//this.mc_pointer.x = adjustPointer(mc_pointer.x);
			}
			if (e.localX * 2 - 5 < 0)
			{
				mc_pointer.x = 0;
			}
			if (e.localX * 2 - 5 > 90)
			{
				mc_pointer.x = 90;
			}
			update();
		}
		
		private function onMove(e:MouseEvent)
		{
			if (e.buttonDown)
			{
				if (e.localX * 2 - 5 < 90)
				{
					mc_pointer.x = e.localX * 2 - 5;
						//this.mc_pointer.x = adjustPointer(mc_pointer.x);
				}
				if (e.localX * 2 - 5 < 0)
				{
					mc_pointer.x = 0;
				}
				if (e.localX * 2 - 5 > 90)
				{
					mc_pointer.x = 90;
				}
			}
			update();
		}
		
		private function onUp(e:MouseEvent)
		{
			dispatchEvent(new PlayerEvent(PlayerEvent.PAN_CHANGE, number));
		}
		
		private function update()
		{
			var n:Number = mc_pointer.x / 90 * 200;
			if (n == 100)
			{
				this.tx_text.text = "0";
				return;
			}
			if (n > 100)
			{
				n = n - 100;
				if (n > 99)
				{
					this.tx_text.text = "100";
					return;
				}
				if (n < 10)
				{
					this.tx_text.text = String(n).substr(0, 1);
					return;
				}
				this.tx_text.text = String(n).substr(0, 2);
				return;
			}
			if (n < 100)
			{
				n = 100 - n;
				if (n > 99)
				{
					this.tx_text.text = "100";
					return;
				}
				if (n < 10)
				{
					this.tx_text.text = String(n).substr(0, 1);
					return;
				}
				this.tx_text.text = String(n).substr(0, 2);
				return;
			}
		}
		
		private function get number():int
		{
			if (mc_pointer.x / 90 * 200 < 100)
			{
				return int(-int(this.tx_text.text));
			}
			return int(this.tx_text.text);
		}
	}

}