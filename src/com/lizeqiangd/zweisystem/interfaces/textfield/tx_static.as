package com.lizeqiangd.zweisystem.interfaces.textfield
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class tx_static extends TextField
	{
		public function tx_static(font:String = '微软雅黑', size:Object = 12, color:Object = 0x3399ff, bold:Object = null, italic:Object = null, underline:Object = null, url:String = null, target:String = null, align:String = null, leftMargin:Object = null, rightMargin:Object = null, indent:Object = null, leading:Object =null )
		{			
			this.defaultTextFormat = new TextFormat(font,size,color,bold,italic,underline,url,target,align,leftMargin,rightMargin,indent,leading)
			this.height = 20
			this.width = 20
			this.selectable = false;
			this.mouseEnabled = false;
		}
		
		public function set setColor(color:uint):void
		{
			this.defaultTextFormat.color = color
		}
		
		public function set setSize(size:Number):void
		{
			this.defaultTextFormat.size = size
		}
		
		public function set setAlign(align:String):void
		{
			this.defaultTextFormat.align = align
		}
		
		override public function set text(e:String):void
		{
			super.text = e
			this.width = this.textWidth + 10
			this.height = this.textHeight + 4
		}
		
		override public function get text():String
		{
			return super.text
		}
	}

}