package com.lizeqiangd.zweisystem.interfaces.baseunit.datagird
{
	import com.greensock.TweenLite;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class BaseDataGirdRow extends BaseUI
	{
		public static const AnimationTint_DataGirdRowBackGroundOver:uint = 0xcce1ff
		public static const AnimationTint_DataGirdRowBackGroundDown:uint = 0xaacfff
		public static const AnimationTint_DataGirdRowBackGroundOut:uint = 0xffffff
		
		///dataprovider
		public var data:Object
		
		///设置basedatagirdrow的大小参数.
		public var indexInDataGird:uint = 0
		
		public var rowEventDispatch:EventDispatcher
		private var sp_splitLine:Sprite
		
		public function BaseDataGirdRow()
		{
			//indexInDataGird = _indexInDataGird
			sp_splitLine = new Sprite
			addChild(sp_splitLine)
			
			configBaseDataGirdRow(290, 20)
			setFrameColor = 0xffffff			
			setBackGroundColor = 0xe8e8e8
			createBackground(0.8)
			addRowEventListener()
		}
		
		/**
		 * 添加对row本身的按钮侦听
		 */
		public function addRowEventListener():void
		{
			this.addEventListener(MouseEvent.CLICK, onMouseClick)
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)		
			
		}
		
		/**
		 * 移除对row本身的按钮侦听
		 */
		public function removeRowEventListener():void
		{
			this.removeEventListener(MouseEvent.CLICK, onMouseClick)
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp)
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
		}
				/**
		 * 制作分割线 分割线的x位置  颜色使用framecolor 粗细为1
		 */
		public function createSplitLine(... arg):void
		{
			sp_splitLine.graphics.clear()
			sp_splitLine.graphics.lineStyle(1, getFrameColor, 1)
			for (var i:int = 0; i < arg.length; i++)
			{
				sp_splitLine.graphics.moveTo(arg[i], 0)
				sp_splitLine.graphics.lineTo(arg[i], this.getUiHeight)
			}setChildIndex(sp_splitLine,numChildren-1)
		}
		
		public function onMouseDown(e:MouseEvent):void
		{//trace("onMouseDown")
			//等待覆盖
		}

		public function onMouseOut(e:MouseEvent):void
		{
			if (BaseDataGird.cherkVariableExist(data[indexInDataGird]))
			{
				TweenLite.to(sp_background, 0.5, {tint: 0xaacfff})
			}
			else
			{
				TweenLite.to(sp_background, 0.5, {tint: 0xffffff})
			}
		}
		
		public function onMouseOver(e:MouseEvent):void
		{
			TweenLite.to(sp_background, 0.5, {tint:0xaacfff})
		}
		
		public function onMouseUp(e:MouseEvent):void
		{
			//等待覆盖
		}
		
		public function onMouseClick(e:MouseEvent):void
		{
			var dispatchObj:Object = {}
			dispatchObj.selectIndex = indexInDataGird
			dispatchObj.altKey = e.altKey
			dispatchObj.shiftKey = e.shiftKey
			dispatchObj.ctrlKey = e.ctrlKey
			//直接发送参数过去可能会导致这个参数永远不会被垃圾回收..导致内存增大..但是用户会刷新哇~  嗯.~诶嘿嘿,佐佑理不清楚~  让外部来获取是最好的.但是~咕嘿嘿
			rowEventDispatch.dispatchEvent(new UIEvent(UIEvent.SELECTED, dispatchObj))
			
		}
		
		/**
		 * 设置basedatagirdrow的大小参数.
		 */
		public function configBaseDataGirdRow(_width:Number, _height:Number/*, _index:uint*/):void
		{
			//indexInDataGird = _index
			configBaseUi(_width, _height)
		}
		
		/**
		 * 获取本row在datagird中的index
		 */
		public function get getIndexInDataGird():uint
		{
			return indexInDataGird
		}
		
		public function cherkSelected(noAnime:Boolean = false):void
		{			
			if (BaseDataGird.cherkVariableExist(data[indexInDataGird]))
			{
				TweenLite.to(sp_background, 0.2, {tint: 0xaacfff})
			}
			else
			{
				TweenLite.to(sp_background,0.2, {tint:0xffffff})
			}
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