package com.lizeqiangd.zweisystem.interfaces.datagird.blocklist
{
	import com.bilibili.player.abstract.datagird.BaseDataGirdRow;
	import com.bilibili.player.abstract.datagird.iDataGirdRow;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.bilibili.player.system.proxy.StageProxy;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * 根据复制dgr_commentTitle而来
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 * 弹幕列表中的标题栏
	 */
	public class dgr_blockTitle extends BaseDataGirdRow
	{
		
		private var tx_type:TextField
		private var tx_content:TextField
		private var tx_function:TextField
		
		private var sp_type:Sprite
		private var sp_content:Sprite
		
		private var arraySplitLine:Array =[40,130]
		
		public function dgr_blockTitle()
		{
			
			sp_type = new Sprite
			sp_type.graphics.beginFill(BPSetting.Color_CommentListTitleRowMouseUp, .8)
			sp_type.graphics.drawRect(0, 0, arraySplitLine[0], BPSetting.StandardDataGirdRowHeight)
			sp_type.graphics.endFill()
			addChild(sp_type)
			
			sp_content = new Sprite
			sp_content.graphics.beginFill(BPSetting.Color_CommentListTitleRowMouseUp, .8)
			sp_content.x = arraySplitLine[0]
			sp_content.graphics.drawRect(0, 0, arraySplitLine[1]-arraySplitLine[0], BPSetting.StandardDataGirdRowHeight)
			sp_content.graphics.endFill()
			addChild(sp_content)
			
			//sp_date = new Sprite
			//sp_date.graphics.beginFill(BPSetting.Color_CommentListTitleRowMouseUp, .8)
			//sp_date.graphics.drawRect(0, 0, 90, BPSetting.StandardDataGirdRowHeight)
			//sp_date.x = 200
			//sp_date.graphics.endFill()
			//addChild(sp_date)
			
			tx_type = new TextField
			tx_content = new TextField
			tx_function = new TextField
			
			tx_content.mouseEnabled = false
			tx_type.mouseEnabled = false
			tx_function.mouseEnabled = false
			
			tx_content.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			tx_type.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			tx_function.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			
			tx_content.text = "内容"
			tx_type.text = "类别"
			tx_function.text = "功能"
			
			tx_content.y = 2
			tx_type.y = 2
			tx_function.y = 2
			
			
			tx_type.x = 0 + 4
			tx_type.width = arraySplitLine[0]
			tx_content.x = arraySplitLine[0] + 4
			tx_content.width = arraySplitLine[1] - arraySplitLine[0]
			
			tx_function.x = arraySplitLine[1] + 4
			tx_function.width = getUiWidth- arraySplitLine[1]
			
			addChild(tx_content)
			addChild(tx_function)
			addChild(tx_type)
			
			configBaseDataGirdRow(290, BPSetting.StandardDataGirdRowHeight)
			//configBaseDataGirdRow(_w, _h, _index)
			setFrameColor = 0xffffff
			setBackGroundColor = BPSetting.Color_CommentListTitleRowMouseUp
			createBackground(0.8)
			createSplitLine(arraySplitLine[0],arraySplitLine[1])
			
			addTitleRowListener()
		}
		
		private function addTitleRowListener():void
		{
			sp_type.addEventListener(MouseEvent.MOUSE_OUT, onTitleMouseOut)
			//sp_date.addEventListener(MouseEvent.MOUSE_OUT, onTitleMouseOut)
			sp_content.addEventListener(MouseEvent.MOUSE_OUT, onTitleMouseOut)
			
			sp_type.addEventListener(MouseEvent.MOUSE_OVER, onTitleMouseOver)
			//sp_date.addEventListener(MouseEvent.MOUSE_OVER, onTitleMouseOver)
			sp_content.addEventListener(MouseEvent.MOUSE_OVER, onTitleMouseOver)
			
			sp_type.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseDown)
			//sp_date.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseDown)
			sp_content.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseDown)
			
			sp_type.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseClick)
			//	sp_date.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseClick)
			sp_content.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseClick)
			
			//sp_date.addEventListener(MouseEvent.MOUSE_UP, onTitleMouseUp)
			sp_content.addEventListener(MouseEvent.MOUSE_UP, onTitleMouseUp)
			sp_type.addEventListener(MouseEvent.MOUSE_UP, onTitleMouseUp)
		
		}
		
		private function onTitleMouseUp(e:MouseEvent):void
		{
			TweenLite.to(e.target, 0, {tint: BPSetting.Color_CommentListTitleRowMouseUp})
		}
		
		///排序功能.设计
		private function onTitleMouseClick(e:MouseEvent):void
		{
			switch (e.target)
			{
				//case sp_date: 
				//		dispatchEvent(new UnitEvent(UnitEvent.CLICK, "date"))
				//		break
				case sp_content: 
					dispatchEvent(new UIEvent(UIEvent.CLICK, "content"))
					break
				case sp_type: 
					dispatchEvent(new UIEvent(UIEvent.CLICK, "type"))
					break
			}
		}
		
		private function onTitleMouseDown(e:MouseEvent):void
		{
			TweenLite.to(e.target, 0, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundDown})
		}
		
		private function onTitleMouseOver(e:MouseEvent):void
		{
			TweenLite.to(e.target, 0, {tint: BPSetting.AnimationTint_DataGirdRowBackGroundOver})
		}
		
		private function onTitleMouseOut(e:MouseEvent):void
		{
			TweenLite.to(e.target, 0, {tint: BPSetting.Color_CommentListTitleRowMouseUp})
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
		public function setEventDispatch(ed:EventDispatcher)
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