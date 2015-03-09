package com.lizeqiangd.zweisystem.interfaces.datagird.dragdownlist
{
	import com.bilibili.player.abstract.datagird.BaseDataGird;
	import com.bilibili.player.abstract.datagird.iDataGirdRow;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUi;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.scrollbar.sb_core;
	import com.bilibili.player.system.config.BPSetting;
	
	/**
	 * 需要对本类进行config 设置其基础占位大小.可随时调整.
	 * 对本datagird中的row输入其class path
	 *
	 * 本类使用sb_core组件和 basedatagird组件
	 * 开发者只需处理几个属性和方法
	 * configHeight()  设置高度
	 * topIndex  属性  设置当前顶部条目,用于其他地方遥控挑选弹幕
	 * dataProvider  只写属性  设置弹幕数据提供者即可 绑定一次即可
	 * update   当界面属性出现变动的时候,请调用一次,会自动调节.
	 * @author Lizeqiangd
	 */
	public class dg_dragDownList extends BaseUi
	{
		///内部条目的实例
		private var dg_core:BaseDataGird
		///滚动条
		private var sb_datagird:sb_core
		///已经选中的列表在datagird中的index
		private var selectedArray:Array = []
		
		///当前顶部显示数据(有可能交给外部类统一处理)
		//private var now_top_index:uint =0
		///外部数据引用回来后复制重建.
		//private var clone_data:Array 
		
		private var lastSelectedIndexInDataProvider:uint = 0
		
		public function dg_dragDownList()
		{
			dg_core = new BaseDataGird()
			dg_core.configClass(dgr_dragDown)
			//title_row=new dgr_comment		
			
			addChild(dg_core);
			
			sb_datagird = new sb_core()
			addChild(sb_datagird)
			
			//边框颜色
			this.setFrameColor=0x333333
			
			//config(290, 438)
			//sb_datagird.configHeight(438)
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
		private function removeDataGirdEventListener()
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
			
			//if (!e.data.ctrlKey)
			//{
				i = 0
				for (; i < dg_core.dataProvider.length; i++)
				{
					dg_core.dataProvider[i][BPSetting.ValueObject_DataGirdSelected] = false
				}
			//}
			//if (e.data.shiftKey)
			//{
				//dg_core.dataProvider[lastSelectedIndexInDataProvider][BPSetting.ValueObject_DataGirdSelected] = true
				//for (i = lastSelectedIndexInDataProvider; i != e.data.selectIndex; )
				//{
					//i > e.data.selectIndex ? i-- : i++
					//dg_core.dataProvider[i][BPSetting.ValueObject_DataGirdSelected] = true
				//}
			//}
			//else
			//{
				dg_core.dataProvider[e.data.selectIndex][BPSetting.ValueObject_DataGirdSelected] = !dg_core.dataProvider[e.data.selectIndex][BPSetting.ValueObject_DataGirdSelected]
			//}
			
			//保存当前点击的位置,用于下一次使用shift
			lastSelectedIndexInDataProvider = e.data.selectIndex
			
			selectedArray = []
			for (i = 0; i < dg_core.dataProvider.length; i++)
			{
				if (dg_core.dataProvider[i][BPSetting.ValueObject_DataGirdSelected])
				{
					selectedArray.push(i)
				}
			}
			//更新内部效果
			dg_core.updateRowDataProvider()
			//trace("Datagird selected index in dataprovider:")
			//trace(selectedArray)
			//trace("shiftKey:", e.data.shiftKey, "altKey:", e.data.altKey, "ctrlKey:", e.data.ctrlKey, "index:", e.data.selectIndex)
			dispatchEvent(new UIEvent(UIEvent.SELECTED))
		}
		
		private function onScrollBarChanged(e:UIEvent):void
		{
			dg_core.update(uint(e.data / dg_core.getRowHeight))
		}
		
		/**
		 * 返回当前所选序列.
		 */
		public function get getSelectedArray():Array
		{
			return selectedArray
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
			//dg_core.y=sb_datagird.y=20
			dg_core.configBaseDataGird(_w, _h)
			sb_datagird.x = _w - 10
			sb_datagird.configHeight(_h)
		
			createFrame(false)
			//var tempUint:int = Math.ceil((getUiHeight) / BPSetting.StandardDataGirdRowHeight)
			//dg_core.configRowMaxCount(tempUint)
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
		 * 导入的数据.[{xx:123},{xx:321}]数组. 会交给里面的类处理.
		 * 其次还是复制模式.
		 *
		 * 直接dataprovider引用给core中
		 */
		public function set dataProvider(e:Array):void
		{
			dg_core.dataProvider = e
			
			var i:int = 0
			
			for (; i < dg_core.dataProvider.length; i++)
			{
				dg_core.dataProvider[i][BPSetting.ValueObject_DataGirdSelected] = false
			}
			update()
		}
		
		/**
		 * 刷新整个界面重新加载dataprovider内容 同时重置index为0
		
		   public function refrush():void
		   {
		   dg_core.update(0)
		   if (title_row)
		   {
		   addChild(title_row)
		   }
		 } */
		
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
		 * 更新显示列表.无论是dataprovider更改还是滚动条更改 还是其他
		 */
		public function update():void
		{
			sb_datagird.setTotalHeight = dg_core.getDataProviderLength * dg_core.getRowHeight
			dg_core.updateRowDataProvider()
		}
		
		/**
		 * 对内部所有的rows添加侦听器
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
	}

}