package com.lizeqiangd.zweisystem.interfaces.datagird.commentlist
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
	 * lizeqiangd@gmail.com
	 * @author Lizeqiangd
	 * 弹幕列表中的标题栏
	 */
	public class dgr_commentTitle extends BaseDataGirdRow
	{
		
		private var tx_time:TextField
		private var tx_content:TextField
		private var tx_date:TextField
		
		private var sp_time:Sprite
		private var sp_comment:Sprite
		private var sp_date:Sprite
		
		public function dgr_commentTitle()
		{
			
			sp_time = new Sprite
			sp_time.graphics.beginFill(BPSetting.Color_CommentListTitleRowMouseUp, .8)
			sp_time.graphics.drawRect(0, 0, 45, BPSetting.StandardDataGirdRowHeight)
			sp_time.graphics.endFill()
			addChild(sp_time)
			
			sp_comment = new Sprite
			sp_comment.graphics.beginFill(BPSetting.Color_CommentListTitleRowMouseUp, .8)
			sp_comment.x = 45
			sp_comment.graphics.drawRect(0, 0, 155, BPSetting.StandardDataGirdRowHeight)
			sp_comment.graphics.endFill()
			addChild(sp_comment)
			
			sp_date = new Sprite
			sp_date.graphics.beginFill(BPSetting.Color_CommentListTitleRowMouseUp, .8)
			sp_date.graphics.drawRect(0, 0, 90, BPSetting.StandardDataGirdRowHeight)
			sp_date.x = 200
			sp_date.graphics.endFill()
			addChild(sp_date)
			
			tx_content = new TextField
			tx_time = new TextField
			tx_date = new TextField
			
			tx_content.mouseEnabled = false
			tx_time.mouseEnabled = false
			tx_date.mouseEnabled = false
			
			tx_content.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			tx_time.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			tx_date.defaultTextFormat = BPTextFormat.DataGirdCommentRowTextFormat
			
			tx_content.text = "评论"
			tx_time.text = "时间"
			tx_date.text = "发送日期"
			
			tx_content.y = 2
			tx_time.y = 2
			tx_date.y = 2
			
			tx_time.x = 0 + 4
			tx_time.width = 45
			tx_content.x = 45 + 4
			tx_content.width = 155
			tx_date.x = 200 + 4
			tx_date.width = 90
			
			addChild(tx_content)
			addChild(tx_date)
			addChild(tx_time)
			
			configBaseDataGirdRow(290, BPSetting.StandardDataGirdRowHeight)
			//configBaseDataGirdRow(_w, _h, _index)
			setFrameColor = 0xffffff
			setBackGroundColor = BPSetting.Color_CommentListTitleRowMouseUp
			createBackground(0.8)
			//createSplitLine(45, 200)
			
			addTitleRowListener()
		}
		
		private function addTitleRowListener():void
		{
			sp_time.addEventListener(MouseEvent.MOUSE_OUT, onTitleMouseOut)
			sp_date.addEventListener(MouseEvent.MOUSE_OUT, onTitleMouseOut)
			sp_comment.addEventListener(MouseEvent.MOUSE_OUT, onTitleMouseOut)
			
			sp_time.addEventListener(MouseEvent.MOUSE_OVER, onTitleMouseOver)
			sp_date.addEventListener(MouseEvent.MOUSE_OVER, onTitleMouseOver)
			sp_comment.addEventListener(MouseEvent.MOUSE_OVER, onTitleMouseOver)
			
			sp_time.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseDown)
			sp_date.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseDown)
			sp_comment.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseDown)
			
			sp_time.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseClick)
			sp_date.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseClick)
			sp_comment.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseClick)
			
			sp_date.addEventListener(MouseEvent.MOUSE_UP, onTitleMouseUp)
			sp_comment.addEventListener(MouseEvent.MOUSE_UP, onTitleMouseUp)
			sp_time.addEventListener(MouseEvent.MOUSE_UP, onTitleMouseUp)
		
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
				case sp_date: 
					dispatchEvent(new UIEvent(UIEvent.CLICK, "date"))
					break
				case sp_comment: 
					dispatchEvent(new UIEvent(UIEvent.CLICK, "comment"))
					break
				case sp_time: 
					dispatchEvent(new UIEvent(UIEvent.CLICK, "time"))
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