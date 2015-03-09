package com.lizeqiangd.zweisystem.interfaces.baseunit 
{
	
	import flash.text.TextField;
	/***
	 * 为按钮的拓展类,有的按钮有文字 有的没` who knows
	 * 20150306 本类似乎已经废弃
	 * @author lizeqiangd
	 */
	public class BaseTextButton extends BaseButton
	{
		
		public static  const _tx_title:String = "tx_title";
		
		public var btn_tx_title:TextField;
		public function BaseTextButton() 
		{
			getInstaneds();
		}
		
		/**
		 * 获取该实例中的所有元件,并将文本框导入
		 */
		private function getInstaneds()
		{
			try
			{
				btn_tx_title = TextField(getChildByName(_tx_title));
			}
			catch (e:*)
			{
				trace(this.name,this,"Button没有找到文本框实例，请在flash pro中检查。")
			}
		}	
		
		/**
		 * 设置标题文字
		 */
		public function set title(s:String)
		{
			this.btn_tx_title.text = s;
		}
		
		/*
		 * 获取标题文字
		 */
		public function get title():String
		{
			return this.btn_tx_title.text;
		}
	
	}

}