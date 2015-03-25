package com.lizeqiangd.zweisystem.interfaces.datagird
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.datagird.BaseDataGird;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.datagird.BaseDataGirdRow;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.datagird.iDataGirdRow;
	import com.lizeqiangd.zweisystem.system.config.ESTextFormat;
	import flash.text.TextFormat;
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
	public class dgr_defaultDataGirdRow extends BaseDataGirdRow implements iDataGirdRow
	{
		
		private var tx_1:TextField
		private var tx_2:TextField
		private var tx_3:TextField
				
		public function dgr_defaultDataGirdRow()
		{
			tx_1 = new TextField
			tx_2 = new TextField
			tx_3 = new TextField
			
			tx_1.mouseEnabled = false
			tx_2.mouseEnabled = false
			tx_3.mouseEnabled = false
			
			tx_1.defaultTextFormat = ESTextFormat.LightBlueTitleTextFormat// BPTextFormat.DataGirdCommentRowTextFormat
			tx_2.defaultTextFormat = ESTextFormat.LightBlueTitleTextFormat// BPTextFormat.DataGirdCommentRowTextFormat
			var tf:TextFormat = ESTextFormat.LightBlueTitleTextFormat
			tf.align='left'
			tx_3.defaultTextFormat =tf//  BPTextFormat.DataGirdCommentRowTextFormat
			
			tx_1.text = ""
			tx_2.text = ""
			tx_3.text = ""
			
			tx_1.y = 2
			tx_2.y = 2
			tx_3.y = 2
			
			tx_1.x = 2
			tx_1.width = 30
			tx_2.x = 32
			tx_2.width = 20
			tx_3.defaultTextFormat.align='left'
			tx_3.x = 52
			tx_3.width = 238
			
			addChild(tx_1)
			addChild(tx_2)
			addChild(tx_3)			
		}
		
		public function update():void
		{
			if (data[indexInDataGird])
			{
				//tx_1.text = data[indexInDataGird].id + ""
				//tx_2.text = data[indexInDataGird].type + ""
				//tx_3.text =data[indexInDataGird].title			
			}else {
				tx_1.text = ''
				tx_2.text =''
				tx_3.text =''
			}
			cherkSelected()
		}
	}

}