package com.lizeqiangd.zweisystem.interfaces.mousetips
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import flash.text.TextFormat;	
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	/**
	 * 同样文字会直接忽视修改内容.同样
	 * 鼠标悬浮框样子.这里可调节的参数有:
	 * 阴影效果
	 * 字体颜色
	 * 背景颜色
	 * 背景样子
	 * 
	 * @see com.bilibili.player.interfaces.mousetips.GlobalMouseTips
	 * @author Lizeqiangd
	 * 20150112 完成
	 */
	public class mt_general extends BaseUI
	{
		private var tf:TextField
		
		public function mt_general()
		{
			tf = new TextField()
			tf.defaultTextFormat = new TextFormat("微软雅黑", 12, 0x000000)
			addChild(tf)
			configBaseUi(40, 20)
			sp_background.filters = [new DropShadowFilter()]
			createBackground(0.6)
			this.mouseChildren = false
			this.mouseEnabled = false
		}
		
		public function set text(e:String):void
		{
			if(tf.text==e){return}
			tf.text = e
			tf.height = getUiHeight
			tf.width = tf.textWidth + 5
			if (tf.width != getUiWidth)
			{
				configBaseUi(tf.width, getUiHeight)
				createBackground(.9)
			}
		}
		public function get text():String {
			return tf.text
		}
		override public function createBackground(background_alpha:Number = 1):void
		{
			sp_background.graphics.clear()
			sp_background.graphics.beginFill(0xffffff, background_alpha)
			sp_background.graphics.drawRoundRect(0, 0, getUiWidth, getUiHeight, 4, 4)
			sp_background.graphics.endFill()
		}
	
	}

}