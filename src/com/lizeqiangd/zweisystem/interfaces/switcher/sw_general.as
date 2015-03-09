package com.lizeqiangd.zweisystem.interfaces.switcher {
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class sw_general extends Sprite
	{
		
		private var sp_background:Sprite
		private var sp_pointer:Sprite
		
		private var tx_open:TextField
		private var tx_close:TextField
		
		private var timer_delayDispatchEvent:Timer
		private var _selected:Boolean = false
		
		public function sw_general()
		{
			TweenPlugin.activate([TintPlugin, AutoAlphaPlugin]);
			
			sp_background = new Sprite
			sp_pointer = new Sprite
			sp_pointer.mouseEnabled = false
			addChild(sp_background)
			addChild(sp_pointer)
			createText()
			config(70, 20)
			
			timer_delayDispatchEvent = new Timer(550, 1)
			
			addUiListener()
		}
		
		private function createText():void
		{
			tx_open = new TextField
			tx_open.defaultTextFormat = new TextFormat("微软雅黑", 12, 0xffffff)
			tx_open.text = "关闭"
			tx_open.y = 0
			tx_open.x = 40
			tx_open.mouseEnabled = false
			tx_open.selectable = false
			
			tx_close = new TextField
			tx_close.defaultTextFormat = new TextFormat("微软雅黑", 12, 0xffffff)
			tx_close.text = "开启"
			tx_close.y = 0
			tx_close.x = 2
			tx_close.mouseEnabled = false
			tx_close.selectable = false
			tx_close.alpha = 0
			addChild(tx_open)
			addChild(tx_close)
		}
		
		public function config(_w:Number, _h:Number):void
		{
			sp_background.graphics.clear()
			sp_background.graphics.beginFill(0xaaaaaa, 1)
			//sp_background.graphics.lineStyle(1, 0xaaaaaa)
			sp_background.graphics.drawRoundRectComplex(0, 0, _w, _h, 4, 4, 4, 4)
			
			sp_pointer.x = 2
			sp_pointer.y = 2
			sp_pointer.graphics.clear()
			sp_pointer.graphics.beginFill(0xffffff, 1)
			//sp_pointer.graphics.lineStyle(1, 0xffffff)
			sp_pointer.graphics.drawRoundRectComplex(0, 0, 25, 16, 4, 4, 4, 4)
		}
		
		private function addUiListener()
		{
			timer_delayDispatchEvent.addEventListener(TimerEvent.TIMER_COMPLETE, onDelayDispatchEventHandle)
			sp_background.addEventListener(MouseEvent.CLICK, onMouseEventHandle)
			//sp_background.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEventHandle)
			sp_background.addEventListener(MouseEvent.MOUSE_OUT, onMouseEventHandle)
			sp_background.addEventListener(MouseEvent.MOUSE_OVER, onMouseEventHandle)
			//sp_background.addEventListener(MouseEvent.MOUSE_UP, onMouseEventHandle)
		}
		
		private function onMouseEventHandle(e:MouseEvent):void
		{
			switch (e.type)
			{
				case MouseEvent.CLICK: 
					_selected = !_selected
					onSwitchAnimation()
					break;
				case MouseEvent.MOUSE_DOWN:
					
					break;
				case MouseEvent.MOUSE_OUT:
					
					break;
				case MouseEvent.MOUSE_OVER:
					
					break;
				case MouseEvent.MOUSE_UP:
					
					break;
				default: 
			}
		}
		
		private function onSwitchAnimation():void
		{
			TweenLite.to(sp_background, 0.5, {tint: _selected ? 0x02a0d8 : 0xaaaaaa})
			TweenLite.to(sp_pointer, 0.5, {x: _selected ? 43 : 2})
			TweenLite.to(tx_close, 0.5, {autoAlpha: _selected ? 1 : 0})
			TweenLite.to(tx_open, 0.5, {autoAlpha: _selected ? 0 : 1})
			timer_delayDispatchEvent.reset()
			timer_delayDispatchEvent.start()
		}
		
		public function get selected():Boolean
		{
			return _selected
		}
		
		public function set selected(value:Boolean)
		{
			_selected = value
			onSwitchAnimation()
		}
		
		private function onDelayDispatchEventHandle(e:TimerEvent):void
		{
			dispatchEvent(new Event(Event.CHANGE))
		}
	}

}