package com.bilibili.player.components.encode
{
	
	/**
	 * 修改显示对象尺寸
	 * 数组为[width,0]
	 */
	public class ResizeObject
	{
		public static function resizeByWidth(obj:*, bw:Number, bh:Number, aw:Number, ah:Number, _w:String = "width", _h:String = "height"):void
		{
			obj[_w] = ah / bh * bw;
			obj[_h] = ah
		}
		
		public static function resizeByHeight(obj:*, bw:Number, bh:Number, aw:Number, ah:Number, _w:String = "width", _h:String = "height"):void
		{
			obj[_w] = aw
			obj[_h] = aw / bw * bh
		}
		
		public static function resizeOutside(obj:*, bw:Number, bh:Number, aw:Number, ah:Number, _w:String = "width", _h:String = "height"):void
		{
			if (aw / bw > ah / bh)
			{
				resizeByHeight(obj, bw, bh, aw, ah, _w, _h);
			}
			else
			{
				resizeByWidth(obj, bw, bh, aw, ah, _w, _h);
			}
		}
		
		public static function resizeInside(obj:*, bw:Number, bh:Number, aw:Number, ah:Number, _w:String = "width", _h:String = "height"):void
		{
			if (aw / bw < ah / bh)
			{
				resizeByHeight(obj, bw, bh, aw, ah, _w, _h);
			}
			else
			{
				resizeByWidth(obj, bw, bh, aw, ah, _w, _h);
			}
		}
	}
}