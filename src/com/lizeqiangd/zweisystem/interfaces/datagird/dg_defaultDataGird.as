package com.lizeqiangd.zweisystem.interfaces.datagird 
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.datagird.BaseDataGird;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.datagird.iDataGirdRow;
	import com.lizeqiangd.zweisystem.interfaces.scrollbar.sb_core;
	
	/**
	 * 二次封装过后的datagird模型.
	 * 需要对本类进行config 设置其基础占位大小.可随时调整.
	 * 使用继承时请输入super(class)
	 * 或者请直接使用,new的时候附带参数.
	 * 
	 * 本类使用sb_core组件和 basedatagird组件
	 * 开发者只需处理几个属性和方法
	 * config(width,height)  设置宽高(注意滚动条)
	 * configHeight(height)  设置高度
	 * topIndex  属性  设置当前顶部条目,用于其他地方遥控挑选弹幕
	 * dataProvider  只写属性  设置弹幕数据提供者即可 绑定一次即可
	 * update   当界面属性出现变动的时候,请调用一次,会自动调节.
	 * 
	 * @author Lizeqiangd
	 * 20150107 将弹幕和屏蔽列表和下拉框代码复用处整合.
	 * 20150324 修正点击空白位置时候的bug
	 */
	public class dg_defaultDataGird extends BaseUI
	{
		
		
		///内部条目的核心管理器.
		private var dg_core:BaseDataGird
		///滚动条
		private var sb_datagird:sb_core
		///已经选中的列表在datagird中的index
		private var selectedArray:Array = []
		///最后一个点击的数字
		private var lastSelectedIndexInDataProvider:uint = 0
		
		public function dg_defaultDataGird(dataGirdRowClass:Class)
		{
			dg_core = new BaseDataGird()
			dg_core.configClass(dataGirdRowClass)
			addChild(dg_core);			
			sb_datagird = new sb_core()
			addChild(sb_datagird)
			addDataGirdEventListener()
		}
		
		/**
		 * 添加对datagird内部的侦听器,用于集体移除
		 */
		private function addDataGirdEventListener():void
		{
			sb_datagird.addEventListener(UIEvent.CHANGE, onScrollBarChanged)
			addRowsEventListener(UIEvent.SELECTED, onRowsSelected)
		}
		
		/**
		 * 移除所有datagird方法
		 */
		private function removeDataGirdEventListener():void
		{
			
			sb_datagird.removeEventListener(UIEvent.CHANGE, onScrollBarChanged)
			removeRowsEventListener(UIEvent.SELECTED, onRowsSelected)
		}
		
		/**
		 * 用于反馈用户点击datagird里面的事件进行反馈,可是用shift和ctrl按钮. alt按钮也做了但是目前没用.
		 * 其次逻辑和windows逻辑一致.看起来好像挺漂亮的~
		 */
		private function onRowsSelected(e:UIEvent):void
		{
			var i:int = 0
			if (e.data.selectIndex >= dg_core.dataProvider.length) {
				return 				
			}
			if (!e.data.ctrlKey)
			{
				i = 0
				for (; i < dg_core.dataProvider.length; i++)
				{
					dg_core.dataProvider[i][BaseDataGird.ValueObject_DataGirdSelected] = false
				}
			}
			if (e.data.shiftKey)
			{
				dg_core.dataProvider[lastSelectedIndexInDataProvider][BaseDataGird.ValueObject_DataGirdSelected] = true
				for (i = lastSelectedIndexInDataProvider; i != e.data.selectIndex; )
				{
					i > e.data.selectIndex ? i-- : i++
					dg_core.dataProvider[i][BaseDataGird.ValueObject_DataGirdSelected] = true
				}
			}
			else
			{
				if (e.data.selectIndex >= dg_core.dataProvider.length) {
					return;
				}
				dg_core.dataProvider[e.data.selectIndex][BaseDataGird.ValueObject_DataGirdSelected] = !dg_core.dataProvider[e.data.selectIndex][BaseDataGird.ValueObject_DataGirdSelected]
			}
			
			//保存当前点击的位置,用于下一次使用shift
			lastSelectedIndexInDataProvider = e.data.selectIndex
			
			selectedArray = []
			for (i = 0; i < dg_core.dataProvider.length; i++)
			{
				if (dg_core.dataProvider[i][BaseDataGird.ValueObject_DataGirdSelected])
				{
					selectedArray.push(i)
				}
			}
			//更新内部效果
			dg_core.updateRowDataProvider()
			dispatchEvent(new UIEvent(UIEvent.SELECTED))
		}
		
		private function onScrollBarChanged(e:UIEvent):void
		{
			dg_core.update(uint(e.data / dg_core.getRowHeight))
		}
		
		
		/**
		 * 设定核心以及滚动条
		 * @param	_w
		 * @param	_h
		 */
		public function config(_w:Number, _h:Number):void
		{
			configBaseUi(_w, _h)
			createBackground(0.5)
			dg_core.configBaseDataGird(_w, _h)
			sb_datagird.x = _w - 10
			sb_datagird.configHeight(_h)
		}
		
		/**
		 * 简便方法,只设置高度
		 * @param	dgHeight
		 */
		public function configHeight(dgHeight:Number):void
		{
			config(dg_core.getUiWidth, dgHeight)
		}
		
		/**
		 * 更新显示列表.无论是dataprovider更改还是滚动条更改 还是其他 反正你觉得不对就update()好了
		 */
		public function update():void
		{
			sb_datagird.setTotalHeight = dg_core.getDataProviderLength * dg_core.getRowHeight
			dg_core.updateRowDataProvider()
		}
		
		/**
		 * 对内部所有的rows添加侦听器,没错就是所有
		 */
		public function addRowsEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			dg_core.addRowEventListener(type, listener, useCapture, priority, useWeakReference)
		}
		
		/**
		 * 对row移除侦听器.
		 */
		public function removeRowsEventListener(type:String, listener:Function, userCapture:Boolean = false):void
		{
			dg_core.removeRowEventListener(type, listener, userCapture)
		}
		
		/**
		 * 导入的数据.[{xx:123},{xx:321}]数组. 会交给里面的类处理.
		 * 其次还是复制模式.
		 *
		 * 直接dataprovider引用给core中
		 */
		public function set dataProvider(e:Array):void
		{
			dg_core.dataProvider = e
			for (var i:int =0; i < dg_core.dataProvider.length; i++)
			{
				dg_core.dataProvider[i][BaseDataGird.ValueObject_DataGirdSelected] = false
			}
			update()
		}
		
		/**
		 * 设置顶部index
		 */
		public function set topIndex(e:uint):void
		{
			dg_core.update(e)
			sb_datagird.setNowDisplayTop = (e * dg_core.getRowHeight)
		}
		
		/**
		 * 读取顶部index
		 */
		public function get topIndex():uint
		{
			return dg_core.getTopIndex
		}
		/**
		 * 返回当前所选序列.
		 */
		public function get getSelectedArray():Array
		{
			return selectedArray
		}
		
	}

}