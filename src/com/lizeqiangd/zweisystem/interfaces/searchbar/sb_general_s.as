package com.lizeqiangd.zweisystem.interfaces.searchbar
{
	import flash.events.MouseEvent;
	import com.lizeqiangd.zweisystem.events.UnitEvent;
	import flash.display.Sprite;

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class sb_general_s extends Sprite
	{
		private var _defaultText:String = "";

		public function sb_general_s()
		{
			addUiListener();
		}

		private function addUiListener()
		{
			this.tx_title.addEventListener(MouseEvent.MOUSE_DOWN, onClick, false, 0, true);
			this.mc_btn.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			this.addEventListener(KeyboardEvent.KEY_DOWN, onSubmit, false, 0, true);
		}

		private function removeUiListener()
		{
			this.removeEventListener(KeyboardEvent.KEY_DOWN, onSubmit);
			this.tx_title.removeEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.mc_btn.removeEventListener(MouseEvent.CLICK, onClick);
		}

		private function onSubmit(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				dispatchEvent(new UnitEvent(UnitEvent.SEARCH, searchData));
				dispatchEvent(new UnitEvent(UnitEvent.CLICK, searchData));
			}
		}

		private function onClick(e:MouseEvent)
		{
			switch (e.target)
			{
				case mc_btn :
					dispatchEvent(new UnitEvent(UnitEvent.SEARCH, searchData));
					dispatchEvent(new UnitEvent(UnitEvent.CLICK, searchData));
					break;
				case tx_title :
					if (tx_title.text == _defaultText)
					{
						tx_title.text = "";
					}
					break;
			}
		}

		public function dispose()
		{
			removeUiListener();
		}

		public function get searchData():String
		{
			return this.tx_title.text;
		}

		public function set defaultText(s:String)
		{
			this.tx_title.text = s;
			_defaultText = s;
		}
		public function set title(e:String )
		{
			defaultText = e;
		}

	}

}