package com.lizeqiangd.zweisystem.interfaces.baseunit.datagird
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * DataGird的整体逻辑::
	 * 设定内部填充物的实例.
	 * 然后可以随意设定显示高度列表.然后重新初始化显示个数
	 * datagird会将填充物充满整个datagird.
	 * 这样就算datagird本身初始化完成了
	 *
	 * 数据由dataprovider提供.只需要告诉datagird当前顶端显示的就可以了.
	 * datagird会通知内部的datagirdrow去获取该条目的内容.是什么就是什么.
	 * @author Lizeqiangd
	 */
	public class BaseDataGird extends BaseUI
	{		
		public static const ValueObject_DataGirdSelected:String = "dgr_comment_selected"	
		public static function cherkVariableExist(data:*):Boolean
		{
			try
			{
				if (data[ValueObject_DataGirdSelected])
				{
					return true
				}
			}
			catch (e:*)
			{
				
			}
			return false
		}
		
		///当前顶部条目的数据index
		private var topIndex:uint
		
		///当前显示最多的条目数. 理论上外部无法用.全权交给datagird.
		private var maxDisplayRows:uint = 1
		
		///数据本身的引用.
		private var data:Array = []
		private var rowClass:Class
		private var rowHeight:Number = 20
		
		///管理显示的条目的接口实例
		private var rows_array:Vector.<iDataGirdRow>
		
		///通用所有rows用事件调度
		private var rowsEventDispatcher:EventDispatcher
		
		/**
		 * 更新datagird数据.会对其目前显示的rows调用update命令.提醒其去获取dataprovider
		 * @param newTopIndex uint 当前应当显示datagird顶部的index在dataprovider
		 * 表示当前抬头第一条目在data中的index后更新.内部的row因为也引用整个数据.所以可以做到自己访问.其次关于是否会超过格子显示 是外部的问题.
		 * 其次在外部控制数据本身有没有被选中之类的后 使用更新就可以更新全部格子的情况.
		 */
		public function update(newTopIndex:uint = 0):void
		{
			topIndex = newTopIndex
			for (var i:uint = 0; i < getRowsArray.length; i++)
			{
				getRowsArray[i].setIndexInArray(topIndex + i)
				getRowsArray[i].update()
			}
		}
		
		///更新数据提供者对显示对象的影响
		public function updateRowDataProvider():void
		{
			for (var i:int = 0; i < getRowsArray.length; i++)
			{
				getRowsArray[i].setDataProvider(data)
			}
			
			update(topIndex)
		}
		
		/**
		 * 对内部所有的rows添加侦听器
		 */
		public function addRowEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			rowsEventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference)
		}
		
		/**
		 * 对row移除侦听器.
		 */
		public function removeRowEventListener(type:String, listener:Function, userCapture:Boolean):void
		{
			rowsEventDispatcher.removeEventListener(type, listener, userCapture)
		}
		
		/**
		 * 初始化一次用.
		 * 设置要显示的条目的class.
		 * 设定完后,会立刻激活一个实例读取实例信息
		 * 同时初始化row_array,并将row放进去,也就是你无论如何都要显示一个row.
		 * @param	_rowClassPath
		 */
		public function configClass(_rowClass:Class):void
		{
			if (rowClass)
			{
				trace("BaseDataGird:already inited. now class is:", rowClass)
				return
			}
			rowsEventDispatcher = new EventDispatcher
			rowClass = _rowClass
			var row:* = new rowClass
			rowHeight = iDataGirdRow(row).getRowHeight()
			iDataGirdRow(row).dispose()
			row = null
			rows_array = new Vector.<iDataGirdRow>
			//rows_array.push(iDataGirdRow(row))
		}
		
		/**
		 * 设置整体尺寸大小.一旦设定完成,会立刻销毁超过显示大小的row,或者增加最高row
		 * @param	_w
		 * @param	_h
		 */
		public function configBaseDataGird(_w:Number, _h:Number):void
		{
			this.configBaseUi(_w, _h);
			var maxDisplayCount:int = Math.ceil(this.getUiHeight / this.rowHeight)
			maxDisplayCount = maxDisplayCount ? maxDisplayCount : 1;
			while (maxDisplayCount > rows_array.length)
			{
				addRow()
			}
			
			while (maxDisplayCount < rows_array.length)
			{
				removeLastRows()
			}
			
			updateRowDataProvider()
		}
		
		///移除最后一个显示对象
		private function removeLastRows():void
		{
			var row:* = getRowsArray.pop()
			row.dispose()
			removeChild(row)
		}
		
		///新增一个显示对象
		private function addRow():void
		{
			var row:* = new rowClass
			iDataGirdRow(row).setDataProvider(data)
			iDataGirdRow(row).setEventDispatch(rowsEventDispatcher)
			row.y = rows_array.length * iDataGirdRow(row).getRowHeight()
			//iDataGirdRow(row).update()
			addChild(row)
			getRowsArray.push(iDataGirdRow(row))
			
			
		}
		
		/**
		 * 刷新datagird. 清理掉所有显示对象,重新绘制并且重置index为0..只是用一次.初始化用.
		
		   public function refrushDataGird():void
		   {
		   rows_array = new Vector.<iDataGirdRow>
		   this.removeChildren()
		
		   var row:*
		   for (var i:uint = 0; i < getMaxRowCount; i++)
		   {
		   row = new rowClass
		   iDataGirdRow(row).setDataProvider(dataProvider)
		   row.y = i * iDataGirdRow(row).getRowHeight()
		   iDataGirdRow(row).update()
		   addChild(row)
		   getRowsArray.push(iDataGirdRow(row))
		   }
		   update(0)
		 }*/
		
		/**
		 * 导入数据的引用.外部可排序后刷新内部
		 * 如果发生弹幕池突变之类的..会修改引用则会通知内部全部引用更改
		 */
		public function set dataProvider(e:Array):void
		{
			data = e
			//updateRowDataProvider()
		}
		
		/**
		 * 返回data引用.通常是给选择器用来选择用的
		 */
		public function get dataProvider():Array
		{
			return data
		}
		/**
		 * 返回dataprovider.length
		 */
		public function get getDataProviderLength():uint
		{
			return data.length
		}
		
		/**
		 * 返回row数组  Vector.<iDataGirdRow> 无用
		 */
		private function get getRowsArray():Vector.<iDataGirdRow>
		{
			return rows_array
		}
		
		///当前顶部条目的数据index
		public function get getTopIndex():uint
		{
			return topIndex
		}
		
		///返回一个条目的高度,目前只支持一个高度
		public function get getRowHeight():Number
		{
			return rowHeight
		}
	
	}
}