package com.lizeqiangd.zweisystem.interfaces.numericstepper
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.utils.ui.ButtonMouseController;
	//import com.bilibili.player.components.SelectionColor;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	//import com.bilibili.player.system.config.BPSetting;
	//import com.bilibili.player.system.config.BPTextFormat;
	import flash.text.TextFormat;
	//import com.bilibili.player.system.proxy.StageProxy;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.Timer;
	
	/**
	 * 比较标准的步进数字框. 用于反馈数字显示.
	 * 使用方法:setMax  setMin setStep setNow
	 * 设置基本属性.
	 * 不用的时候可以考虑dispose爆炸掉,之后会考虑统一管理这些内存
	 * 按钮样式请去swf里面修改numberstepper_icon
	 * @author Lizeqiangd
	 * 2014.10.15 创建
	 * 2015.03.09 移除依赖库
	 */
	public class ns_number extends BaseUI
	{
		private var sp_up:Sprite
		private var sp_down:Sprite
		private var bc_up:ButtonMouseController
		private var bc_down:ButtonMouseController
		private var sp_icon:Sprite
		private var tx_content:TextField
		
		private var _max:Number = 100
		private var _min:Number = 0
		private var _step:Number = 1
		private var _increase:Number = 0
		private var _now:Number = 0
		private var tr_delayStep:Timer
		private var _fixedCount:uint = 0
		
		public function ns_number()
		{
			setFrameColor = (0xffffff)
			configBaseUi(35, 20)
			createFrame(false)
			
			sp_up = new Sprite
			sp_up.graphics.beginFill(0)
			sp_up.graphics.lineStyle(0.5, 0xffffff, 1)
			sp_up.graphics.drawRoundRectComplex(getUiWidth, 0, 20, 10, 0, 4, 0, 0)
			sp_up.graphics.endFill()
			addChild(sp_up)
			
			sp_down = new Sprite
			sp_down.graphics.beginFill(0)
			sp_down.graphics.lineStyle(0.5, 0xffffff, 1)
			sp_down.graphics.drawRoundRectComplex(getUiWidth, 10, 20, 10, 0, 0, 0, 4)
			sp_down.graphics.endFill()
			addChild(sp_down)
			
			bc_up = new ButtonMouseController()
			bc_up.addMouseControlButton(sp_up)
			bc_down = new ButtonMouseController()
			bc_down.addMouseControlButton(sp_down)
			
			tx_content = new TextField
			tx_content.defaultTextFormat = new TextFormat("微软雅黑", 12, 0x000000)
			//tx_content.text = "0.0"
			tx_content.width = getUiWidth
			tx_content.type = TextFieldType.INPUT
			tx_content.restrict = "0-9 ."
			//SelectionColor.setFieldSelectionColor(tx_content, 0xcce1ff)
			addChild(tx_content)
			//StageProxy
			tr_delayStep = new Timer(700, 1)
			
			sp_icon = new Sprite
			sp_icon.mouseChildren = sp_icon.mouseEnabled = false
			sp_icon.addChild(SkinManager.getObject("numberstepper_icon"))
			sp_icon.x = getUiWidth + 5
			addChild(sp_icon)
			
			addUiListener()
			
			setNow = 0
		}
		
		public function set setMax(e:Number):void
		{
			_max = e < _min ? _max : e
		}
		
		public function set setMin(e:Number):void
		{
			_min = e > _max ? _min : e
		}
		
		public function set setStep(e:Number):void
		{
			_step = e
			//trace(e)
			var temp:Number = _step
			while (temp <= 1)
			{
				_fixedCount++
				temp *= 10
			}
			_fixedCount -= 1
			//trace(_fixedCount)
		}
		
		public function set setNow(e:Number):void
		{
			_now = e
			tx_content.text = String(_now)
		}
		
		private function addUiListener():void
		{
			tx_content.addEventListener(MouseEvent.CLICK, onTextFieldClick)
			tr_delayStep.addEventListener(TimerEvent.TIMER_COMPLETE, onDelayTimerHandle)
			sp_up.addEventListener(MouseEvent.MOUSE_DOWN, onMouseHandle)
			sp_up.addEventListener(MouseEvent.MOUSE_UP, onMouseHandle)
			sp_up.addEventListener(MouseEvent.MOUSE_OUT, onMouseHandle)
			sp_down.addEventListener(MouseEvent.MOUSE_OUT, onMouseHandle)
			sp_down.addEventListener(MouseEvent.MOUSE_UP, onMouseHandle)
			sp_down.addEventListener(MouseEvent.MOUSE_DOWN, onMouseHandle)
		}
		
		private function onTextFieldClick(e:MouseEvent):void
		{
			tx_content.setSelection(0, tx_content.text.length)
		}
		
		private function onDelayTimerHandle(e:TimerEvent):void
		{
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame)
			//StageProxy.addEnterFrameFunction(onEnterFrame)
		}
		
		private function onEnterFrame(e:Event = null):void
		{
			_now += _increase
			_now = _now > _max ? _max : _now
			_now = _now < _min ? _min : _now
			tx_content.text = String(_now.toFixed(_fixedCount))
		}
		
		private function onMouseHandle(e:MouseEvent):void
		{
			_increase = e.target == sp_up ? _step : _step * -1
			switch (e.type)
			{
				case MouseEvent.MOUSE_DOWN: 
					onEnterFrame()
					tr_delayStep.reset()
					tr_delayStep.start()
					
					//	removeChild(sp_icon)
					break;
				case MouseEvent.MOUSE_OUT: 
				case MouseEvent.MOUSE_UP: 
					tr_delayStep.stop()
					this.removeEventListener(Event.ENTER_FRAME, onEnterFrame)
					//StageProxy.removeEnterFrameFunction(onEnterFrame)					
					//	addChild(sp_icon)
					break;
				default: 
			}
		}
		
		public function dispose():void
		{
			tr_delayStep.reset()
			tx_content.removeEventListener(MouseEvent.CLICK, onTextFieldClick)
			tr_delayStep.removeEventListener(TimerEvent.TIMER_COMPLETE, onDelayTimerHandle)
			sp_up.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseHandle)
			sp_up.removeEventListener(MouseEvent.MOUSE_UP, onMouseHandle)
			sp_up.removeEventListener(MouseEvent.MOUSE_OUT, onMouseHandle)
			sp_down.removeEventListener(MouseEvent.MOUSE_OUT, onMouseHandle)
			sp_down.removeEventListener(MouseEvent.MOUSE_UP, onMouseHandle)
			sp_down.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseHandle)
			tr_delayStep = null
			//StageProxy.removeEnterFrameFunction(onEnterFrame)
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame)
		}
	}

}