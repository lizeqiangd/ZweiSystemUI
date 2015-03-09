package com.lizeqiangd.zweisystem.interfaces.datagird.dragdownlist
{
	import com.bilibili.player.abstract.datagird.BaseDataGirdRow;
	import com.bilibili.player.abstract.datagird.iDataGirdRow;
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
	 * 下拉框中的文字.只有一行.
	 */
	public class dgr_dragDown extends BaseDataGirdRow implements iDataGirdRow
	{
		
		//private var tx_time:TextField
		private var tx_content:TextField
		
		//private var tx_date:TextField
		
		public function dgr_dragDown()
		{
			tx_content = new TextField
			//tx_time = new TextField
			//tx_date = new TextField
			
			tx_content.mouseEnabled = false
			//tx_time.mouseEnabled = false
			//tx_date.mouseEnabled = false
			
			tx_content.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			//tx_time.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			//tx_date.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			
			addChild(tx_content)
			//addChild(tx_date)
			//addChild(tx_time)
			
			//tx_time.x = 0 + 4
			//tx_time.width = 45
			tx_content.x = 0 // 45 + 4
			tx_content.width = 160 // 155
			//tx_date.x = 200 + 4
			//tx_date.width = 90
			
			tx_content.y = 2
			//tx_time.y = 2
			//tx_date.y = 2
			
			configBaseDataGirdRow(150, BPSetting.StandardDataGirdRowHeight)
			//configBaseDataGirdRow(_w, _h, _index)
			setFrameColor = 0xffffff
			setBackGroundColor = 0xffffff
			createBackground(0.5)
			//createSplitLine(45, 200)
			
			addRowEventListener()
		
		}
		
		override public function onMouseOut(e:MouseEvent):void
		{
			if (cherkVariableExist())
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
			//直接发送参数过去可能会导致这个参数永远不会被垃圾回收..导致内存增大..但是用户会刷新哇~管他的呢 诶嘿嘿,佐佑理不清楚~
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
				var s:String = data[indexInDataGird].value
				tx_content.text = s
				while (tx_content.textWidth > 154)
				{
					s = s.slice(0, s.length - 1)
					tx_content.text = s + "..."
				}
					//s.length>21?s.slice(0,20)+"...":s
					//tx_date.text = data[indexInDataGird].date + ""
					//tx_time.text = data[indexInDataGird].time + ""
			}
			else
			{
				tx_content.text = ""
					//tx_date.text = ""
					//tx_time.text = ""
			}
			cherkSelected()
		}
		
		///检查是否点击
		private function cherkSelected(noAnime:Boolean = false):void
		{
			if (cherkVariableExist())
			{
				TweenLite.to(sp_background, BPSetting.AnimationTime_DataGridRowBackGroundTint, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundDown})
			}
			else
			{
				TweenLite.to(sp_background, BPSetting.AnimationTime_DataGridRowBackGroundTint, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundOut})
			}
		}
		
		private function cherkVariableExist():Boolean
		{
			try
			{
				if (data[indexInDataGird][BPSetting.ValueObject_DataGirdSelected])
				{
					return true
				}
			}
			catch (e:*)
			{
				
			}
			return false
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