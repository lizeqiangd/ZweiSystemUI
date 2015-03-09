package com.bilibili.player.net.api
{
	/**
	 * 用于QQ源的一些方法
	 **/
	public class QQTool
	{
		public function QQTool()
		{
		}
		/**
		 * 根据URL判断是否是QQ源
		 **/
		public static function isQQSrc(url:String):Boolean
		{
			return url.indexOf("qq.com/") !== -1;
		}
		/**
		 * 源切换
		 **/
		public static function alterSrc(url:String):String
		{
			var vid:String = getVid(url);
			if(isTypeA(url))
			{
				return getTypeB(vid);
			}
			else
			{
				return getTypeA(vid);
			}
		}
		/**
		 * 默认源
		 **/
		public static function defaultSrc(vid:String):String
		{
//			return getTypeA(vid);
			return getTypeB(vid);
		}
		
		protected static function getVid(url:String):String
		{
			var a:Array = url.match(/\/([^\.]*).flv/i);
			return a[1];
		}
		
		/**
		 * 是否是类型A的源
		 * 类型A:http://vsrc.store.qq.com/{vid}.flv?channel=vhot2&sdtfrom=v2&r=256&rfc=v10
		 **/
		protected static function isTypeA(url:String):Boolean
		{
			return url.indexOf('vsrc') !== -1;
		}
		
		/**
		 * 得到类型A的地址
		 **/
		protected static function getTypeA(vid:String):String
		{
			return 'http://vsrc.store.qq.com/' + vid + '.flv?channel=vhot2&sdtfrom=v2&r=256&rfc=v10';
		}
		
		/**
		 * 得到类型B的地址
		 **/
		protected static function getTypeB(vid:String):String
		{
			var _loc_2:Number = 4294967295 + 1;
			var _loc_3:Number = 10000 * 10000;
			var fs:Number = getTot(vid, _loc_2) % _loc_3;
			return 'http://vhot2.qqvideo.tc.qq.com/' + fs + '/' + vid + '.flv?sdtfrom=v2';
		}
		
		private static function getTot(param1:String, param2:Number) : Number
		{
			var _loc_3:Number = NaN;
			var _loc_4:Number = NaN;
			var _loc_5:* = undefined;
			var _loc_6:Number = NaN;
			_loc_3 = NaN;
			_loc_4 = NaN;
			_loc_5 = param1;
			_loc_6 = 0;
			_loc_3 = 0;
			while (_loc_3 < _loc_5.length)
			{
				
				_loc_4 = _loc_5.charCodeAt(_loc_3);
				_loc_6 = _loc_6 * 32 + _loc_6 + _loc_4;
				if (_loc_6 >= param2)
				{
					_loc_6 = _loc_6 % param2;
				}
				_loc_3 = _loc_3 + 1;
			}
			return _loc_6;
		}// end function

	}
}