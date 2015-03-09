package com.bilibili.player.abstract.datagird
{
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
			//等待覆盖
		}
		
		public function onMouseOver(e:MouseEvent):void
		{
			//等待覆盖
		}
		
		public function onMouseUp(e:MouseEvent):void
		{
			//等待覆盖
		}
		
		public function onMouseClick(e:MouseEvent):void
		{
			//等待覆盖
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
		
		
		
/**
		private var isSelected:Boolean = false
		
		/**
		 * 设置选择
		
		public function set setSelected(e:Boolean):void
		{
			isSelected = e
			//cherkSelected()
		} 
		/**
		 * 读取选择
		 
		public function get getSelected():Boolean
		{
			return isSelected
		}*/
		
		
		
		
	}
}