package com.lizeqiangd.zweisystem.interfaces.dropdownlist
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.utils.ui.ButtonMouseController;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.datagird.dragdownlist.dg_dragDownList;
	import com.bilibili.player.manager.AnimationManager;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.bilibili.player.system.proxy.StageProxy;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	/**
	 * 标准下拉框.目前应该是给弹幕字体使用
	 * 使用组件 scrollbar datagird(全尺寸,使用遮罩)
	 * 注意置顶框处理
	 * @author Lizeqiangd
	 */
	public class ddl_general extends BaseUI
	{
		private var data:Array = []
		private var sp_dropdown:Sprite
		private var sp_icon:Sprite
		private var tx_select:TextField
		private var dg:dg_dragDownList
		private var isConfiged:Boolean = false
		private var bc_dropdown:ButtonMouseController
		
		public function ddl_general()
		{
			sp_dropdown = new Sprite
			sp_icon = SkinManager.getObject("select_arrow_down") as Sprite
			sp_icon.mouseChildren = false
			sp_icon.mouseEnabled = false
			
			tx_select = new TextField
			tx_select.defaultTextFormat = BPTextFormat.DefaultDragDownListTextFormat
			tx_select.selectable = false
			tx_select.mouseEnabled = false
			tx_select.type = TextFieldType.DYNAMIC
			
			addChild(sp_dropdown)
			addChild(sp_icon)
			addChild(tx_select)
			
			dg = new dg_dragDownList
			addChild(dg)
			this.setFrameColor = (0xaaaaaa)
			bc_dropdown = new ButtonMouseController()
		}
		
		public function config(_w:Number, _h:Number = 20)
		{
			if (isConfiged)
			{
				trace("dll_general:already configed");
				return
			}
			
			this.configBaseUi(_w, _h)
			
			createFrame(false)
			//sp_frame.graphics.lineStyle(1, getFrameColor, 1)
			sp_frame.graphics.moveTo(_w - _h, 0)
			sp_frame.graphics.lineTo(_w - _h, _h)
			
			createBackground(0.1)
			
			sp_dropdown.graphics.clear()
			sp_dropdown.graphics.beginFill(1, 1)
			sp_dropdown.graphics.drawRect(0, 0, _w, _h)
			sp_dropdown.graphics.endFill()
			
			bc_dropdown.addMouseControlButton(sp_dropdown)
			//sp_dropdown.x = _w - sp_dropdown.width
			
			sp_icon.x = _w - 20 + 5
			sp_icon.y = 7
			
			dg.config(_w, 100)
			dg.y = 20 + 2
			dg.visible = false
			addUiListener()
			test()
		}
		
		private function addUiListener():void
		{
			dg.addRowsEventListener(UIEvent.SELECTED, onRowSelected)
			sp_dropdown.addEventListener(MouseEvent.CLICK, onListOpen)
			StageProxy.addEventListener(MouseEvent.CLICK, onStageClick)
		}
		
		private function onRowSelected(e:UIEvent):void
		{
			onListClose()
			tx_select.text = data[e.data.selectIndex].value
		}
		private var _isListOpen:Boolean = false
		
		private function onStageClick(e:MouseEvent):void
		{
			if (_isListOpen)
			{
				this.hitTestPoint(e.stageX, e.stageY) || dg.hitTestPoint(e.stageX, e.stageY) ? null : onListClose()
			}
		}
		
		private function onListOpen(e:MouseEvent):void
		{
			_isListOpen = true
			AnimationManager.fade_in(dg)
			//	dg.visible = _isListOpen
		}
		
		private function onListClose():void
		{
			_isListOpen = false
			
			AnimationManager.fade_out(dg)
			//dg.visible = _isListOpen
		}
		
		private function test():void
		{
			for (var i:uint; i < 20; i++)
			{
				data.push({value: (1000000 * Math.random()).toFixed()})
			}
			this.dataProvider = data
			tx_select
		}
		
		public function set dataProvider(value:Array)
		{
			dg.dataProvider = value
			data=value
			tx_select.text = data[0].value
		}
		
		private function createDropDownList()
		{
		
		}
	}

}