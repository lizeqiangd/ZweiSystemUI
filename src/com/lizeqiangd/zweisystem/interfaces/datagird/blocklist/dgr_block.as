package com.lizeqiangd.zweisystem.interfaces.datagird.blocklist
{
	import com.bilibili.player.abstract.datagird.BaseDataGirdRow;
	import com.bilibili.player.abstract.datagird.iDataGirdRow;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.interfaces.button.blocklist.btn_active;
	import com.lizeqiangd.zweisystem.interfaces.button.blocklist.btn_deactive;
	import com.lizeqiangd.zweisystem.interfaces.button.blocklist.btn_delete;
	import com.bilibili.player.manager.AnimationManager;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.greensock.TweenLite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 * 屏蔽列表中的记录条
	 * 20141013:重新复制制作
	 */
	public class dgr_block extends BaseDataGirdRow implements iDataGirdRow
	{
		
		private var tx_type:TextField
		private var tx_content:TextField
		//private var tx_date:TextField
		private var arraySplitLine:Array = [40, 130]
		
		private var btnDelete:btn_delete
		private var btnActive:btn_active
		private var btnDeactive:btn_deactive
		
		public function dgr_block()
		{
			tx_content = new TextField
			tx_type = new TextField
			//tx_date = new TextField
			
			tx_content.mouseEnabled = false
			tx_type.mouseEnabled = false
			//tx_date.mouseEnabled = false
			
			tx_content.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			tx_type.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			//tx_date.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			
			addChild(tx_content)
			addChild(tx_type)
			//addChild(tx_date)
			
			tx_content.height =25
			tx_type.height = 25
			
			tx_type.x = 0 + 4
			tx_type.width = arraySplitLine[0]
			tx_content.x = arraySplitLine[0] + 4
			tx_content.width = arraySplitLine[1] - arraySplitLine[0] - 4
			//tx_date.x = 200 + 4
			//tx_date.width = 90
			
			tx_content.y = 2
			tx_type.y = 2
			//tx_date.y = 2
			
			configBaseDataGirdRow(290, BPSetting.StandardDataGirdRowHeight)
			//configBaseDataGirdRow(_w, _h, _index)
			setFrameColor = 0xffffff
			setBackGroundColor = 0xffffff
			createBackground(0.5)
			createSplitLine(arraySplitLine[0], arraySplitLine[1])
			
			btnDelete = new btn_delete
			btnActive = new btn_active
			btnDeactive = new btn_deactive
			
			btnDelete.y = btnActive.y = btnDeactive.y = 1
			btnActive.x = btnDeactive.x = 10 + arraySplitLine[1]
			btnDelete.x = 20 + btnDeactive.getUiWidth + arraySplitLine[1]
			
			btnDeactive.visible = false
			
			addChild(btnDelete)
			addChild(btnActive)
			addChild(btnDeactive)
			
			addRowEventListener()
			addButtonEventListener()
		}
		
		private function addButtonEventListener():void
		{
			btnDelete.addEventListener(UIEvent.CLICK, onFunctionButtonClicked)
			btnActive.addEventListener(UIEvent.CLICK, onFunctionButtonClicked)
			btnDeactive.addEventListener(UIEvent.CLICK, onFunctionButtonClicked)
		}
		
		private function onFunctionButtonClicked(e:UIEvent):void
		{
			switch (e.target)
			{
				case btnActive: 
					data[indexInDataGird][BPSetting.ValueObject_BlockListActive] = 1
					AnimationManager.fade(btnDeactive, 1, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
					AnimationManager.fade(btnActive, 0, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
					
					break;
				case btnDelete: 
					data[indexInDataGird][BPSetting.ValueObject_BlockListDelete] = 1
					AnimationManager.fade(btnDelete, 0, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
					
					break;
				case btnDeactive: 
					data[indexInDataGird][BPSetting.ValueObject_BlockListActive] = 0
					AnimationManager.fade(btnDeactive, 0, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
					AnimationManager.fade(btnActive, 1, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
					
					break;
				default: 
			}
		}
		
		///检查是否点击
		private function cherkSelected(noAnime:Boolean = false):void
		{
			if (!cherkVariableExist(BPSetting.ValueObject_BlockListActive))
			{
				AnimationManager.fade(btnDeactive, 0, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
				AnimationManager.fade(btnActive, 1, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
			}
			else
			{
				AnimationManager.fade(btnDeactive, 01, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
				AnimationManager.fade(btnActive, 0, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
			}
			
			if (cherkVariableExist(BPSetting.ValueObject_BlockListDelete))
			{
				AnimationManager.fade(btnDelete, 0, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
			}
			else
			{
				AnimationManager.fade(btnDelete, 1, BPSetting.AnimationTime_BlockListRowFunctionButtonFade)
			}
			
			if (cherkVariableExist(BPSetting.ValueObject_DataGirdSelected))
			{
				TweenLite.to(sp_background, BPSetting.AnimationTime_DataGridRowBackGroundTint, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundDown})
			}
			else
			{
				TweenLite.to(sp_background, BPSetting.AnimationTime_DataGridRowBackGroundTint, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundOut})
			}
		}
		
		private function cherkVariableExist(e:String):Boolean
		{
			try
			{
				if (data[indexInDataGird][e])
				{
					return true
				}
			}
			catch (e:*)
			{
				
			}
			return false
		}
		
		override public function onMouseOut(e:MouseEvent):void
		{
			if (cherkVariableExist(BPSetting.ValueObject_DataGirdSelected))
			{
				TweenLite.to(sp_background, BPSetting.AnimationTime_DataGridRowBackGroundTint, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundDown})
			}
			else
			{
				TweenLite.to(sp_background, BPSetting.AnimationTime_DataGridRowBackGroundTint, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundOut})
			}
		}
		
		override public function onMouseDown(e:MouseEvent):void
		{
			var dispatchObj:Object = {}
			dispatchObj.selectIndex = indexInDataGird
			dispatchObj.altKey = e.altKey
			dispatchObj.shiftKey = e.shiftKey
			dispatchObj.ctrlKey = e.ctrlKey
			//直接发送参数过去可能会导致这个参数永远不会被垃圾回收..导致内存增大..但是用户会刷新哇~  嗯.~诶嘿嘿,佐佑理不清楚~  让外部来获取是最好的.但是~咕嘿嘿
			rowEventDispatch.dispatchEvent(new UIEvent(UIEvent.SELECTED, dispatchObj))
			//data[indexInDataGird]["dgr_comment_selected"] = true
			//cherkSelected()
		}
		
		override public function onMouseOver(e:MouseEvent):void
		{
			TweenLite.to(sp_background, BPSetting.AnimationTime_DataGridRowBackGroundTint, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundOver})
		}
		
		public function update():void
		{
			if (data[indexInDataGird])
			{
				var s:String = data[indexInDataGird].content
				tx_content.text = s
				while (tx_content.textWidth > (arraySplitLine[1] - arraySplitLine[0] - 5))
				{
					s = s.slice(0, s.length - 1)
					tx_content.text = s + "..."
				}
				//s.length>21?s.slice(0,20)+"...":s
				//tx_date.text = data[indexInDataGird].date + ""
				tx_type.text = data[indexInDataGird].type + ""
			}
			else
			{
				tx_content.text = ""
				//tx_date.text = ""
				tx_type.text = ""
			}
			cherkSelected()
		}
		
		public function animation_start():void
		{
		
		}
		
		public function animation_init():void
		{
		
		}
		
		/**
		 * 设置本类通用的eventDispatch
		 * @param	ed
		 */
		public function setEventDispatch(ed:EventDispatcher):void
		{
			this.rowEventDispatch = ed
		}
		
		/**
		 * 获取本rowheight
		 * @return
		 */
		public function getRowHeight():Number
		{
			return getUiHeight
		}
		
		/**
		 * 销毁本row
		 */
		public function dispose():void
		{
			removeRowEventListener()
		}
		
		public function setIndexInArray(e:uint):void
		{
			indexInDataGird = e
		}
		
		/**
		 * 设置总的dataprovider,之后只需要更改index就可以了.
		 * @param	e
		 */
		public function setDataProvider(e:Object):void
		{
			data = e
		}
	}

}