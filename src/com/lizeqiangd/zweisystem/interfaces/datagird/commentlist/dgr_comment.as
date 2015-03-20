package com.lizeqiangd.zweisystem.interfaces.datagird.commentlist
{
	import com.bilibili.player.abstract.datagird.BaseDataGirdRow;
	import com.bilibili.player.abstract.datagird.iDataGirdRow;
	import com.bilibili.player.components.encode.DateTimeUtils;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.greensock.TweenLite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 * 弹幕列表中的条目.全部参数是调整固定了的.需要其他样式重新继承即可.
	 */
	public class dgr_comment extends BaseDataGirdRow implements iDataGirdRow
	{
		
		private var tx_time:TextField
		private var tx_content:TextField
		private var tx_date:TextField
		
		public function dgr_comment()
		{
			tx_content = new TextField
			tx_time = new TextField
			tx_date = new TextField
			
			tx_content.mouseEnabled = false
			tx_time.mouseEnabled = false
			tx_date.mouseEnabled = false
			
			tx_content.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			tx_time.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			tx_date.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			
			addChild(tx_content)
			addChild(tx_date)
			addChild(tx_time)
			
			tx_time.width = 45
			tx_time.height = 20
			
			tx_content.x = 45
			tx_content.width = 155
			tx_content.height = 20
			
			tx_date.x = 200
			tx_date.width = 90
			tx_date.height = 20
			
			configBaseDataGirdRow(290, 20)
			//configBaseDataGirdRow(_w, _h, _index)
			setFrameColor = 0xffffff
			setBackGroundColor = 0xffffff
			createBackground(0.5)
			createSplitLine(45, 200)
			addRowEventListener()
		}
		
			///检查是否点击
		private function cherkSelected(noAnime:Boolean = false):void
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
				tx_content.text = data[indexInDataGird].text + ""
				tx_date.text = data[indexInDataGird].date + ""
				tx_time.text =DateTimeUtils.formatSecond(data[indexInDataGird].stime) + ""				
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
		/*
		   if (e)
		   {
		   data = e
		   addRowEventListener()
		   }
		   else
		   {
		   removeRowEventListener()
		 }*/
		}
		
		
		
		
		
		
	}

}