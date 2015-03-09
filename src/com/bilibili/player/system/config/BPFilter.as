package com.bilibili.player.system.config {
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.net.FileFilter;
	
	/**
	 * EinStation默认的滤镜.
	 * @author lizeqiangd
	 */
	public class BPFilter
	{
		
		///默认发光橙色滤镜.
		public static const DefaultOrangeGlowFilter:GlowFilter = new GlowFilter(0xFF9900, 1, 5, 5, 1, 1);
		
		///淡蓝色发光滤镜
		public static const DefaultLightblueGlowFilter:GlowFilter = new GlowFilter(0x3399ff, 1, 5, 5, 1, 1);
		
		public static function DefaultGlowFilterByUint(e:uint=0x3399ff):GlowFilter {
			return new GlowFilter(e, 1, 5, 5, 1, 1);
		}
		
		public static const DefaultBlurFilter:BlurFilter=new BlurFilter(5,5,1)
		///图片文件过滤器.
		//public static const ImageFileFilter:FileFilter = new FileFilter("Images(图片)", "*.jpg;*.gif;*.png;*.jpeg");
	}
}