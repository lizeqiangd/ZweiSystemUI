package com.bilibili.player.system.config
{
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * 这是bilibili player的默认字体格式库
	 * @author lizeqiangd
	 * 20141107 增加ApplicationConstants方法进入.
	 */
	public class BPTextFormat extends TextFormat
	{
		
		private static var tf:TextFormat
		
		///默认橙色字体
		public static function get DefaultTextFormat():TextFormat
		{
			tf = new TextFormat("微软雅黑", 12, 0xff9900)
			return tf
		}
		
		///默认下拉框字体
		public static function get DefaultDragDownListTextFormat():TextFormat
		{
			tf = new TextFormat("微软雅黑", 12, 0x444444)
			return tf
		}
		
		///默认黑色字体
		public static function get DefaultBlackTextFormat():TextFormat
		{
			tf = new TextFormat("微软雅黑", 12, 0x000000)
			return tf
		}
		
		///默认标题蓝色字体
		public static function get LightBlueTitleTextFormat():TextFormat
		{
			tf = new TextFormat("微软雅黑", 12, 0x3399ff,null,null,null,null,null,TextFormatAlign.CENTER)
			return tf
		}
		
		///默认弹幕发射框字体
		public static function get CommentSenderTextFormat():TextFormat
		{
			tf = new TextFormat("微软雅黑", 15, 0xa2a2a2)
			return tf
		}
		
		///默认datagirdrow字体
		public static function get DataGirdCommentRowTextFormat():TextFormat
		{
			tf = new TextFormat("微软雅黑", 12, 0x000000)
			return tf
		}
		
		///返回刚才使用的TextFormat
		public static function get LastTextFormat():TextFormat
		{
			return tf
		}
		
		public static function getDefaultFont():String
		{
			if (Capabilities.os.indexOf('Linux') != -1)
			{
				var fontList:Array = getCommentFontList();
				if (fontList.indexOf('WenQuanYi Micro Hei') !== -1)
				{
					return 'WenQuanYi Micro Hei';
				}
				else if (fontList.length >= 1)
				{
					return fontList[0];
				}
				else
				{
					return "sans";
				}
			}
			else
				return '黑体';
		
		}
		/**
		 * 默认是否使用粗体
		 */
		public static function get useBoldFont():Boolean
		{
			//只在 Windows 平台下使用粗体
			return Capabilities.os.indexOf('Windows') != -1;;
		}
		
		/** change UI font? **/
		public static function doesChangeUIFont():Boolean
		{
			if (Capabilities.os.indexOf('Linux') != -1)
				return true;
			else
				return false;
		}
		
		/** fontList **/
		public static function getCommentFontList():Array
		{
			var ret:Array = [];
			var p:RegExp = /[\u4e00-\u9fa5]|hei|kai/i;
			for each (var f:Font in Font.enumerateFonts(true))
			{
				if (!f.fontName.match(p))
					continue;
				
				ret.push(f.fontName);
			}
			return ret;
		}	
	}
}