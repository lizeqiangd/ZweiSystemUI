package com.lizeqiangd.zweisystem.interfaces.checkbox
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseAssestButton;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	
	public class cb_content extends BaseAssestButton
	{
		private var _selected:Boolean
		public var mc_mark:MovieClip
		
		public function cb_content()
		{
			super(true)
			mc_mark.mouseEnabled=false
			selected = false
		}
		
		/*
		 * 覆盖原来的Click事件
		 */
		override public function onMouseClick(e:MouseEvent):void
		{
			selected = !selected
			dispatchEvent(new UIEvent(UIEvent.CHANGE, _selected));
			dispatchEvent(new UIEvent(UIEvent.SELECTED, _selected))
			dispatchEvent(new UIEvent(UIEvent.CLICK, _selected))
			dispatchEvent(e);
		}
		
		public function set selected(s:Boolean)
		{
			this._selected = s;
			mc_mark.alpha = _selected ? 1 : 0
		}
		
		public function get selected():Boolean
		{
			return this._selected;
		}
	}
}