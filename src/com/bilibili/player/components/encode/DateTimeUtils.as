package com.bilibili.player.components.encode
{
	
	/**
	 * 时间编码组件.
	 * @ori_author 勇一 (TFT)
	 * @author Lizeqiangd
	 * 20141111 增加jwplayer的东西
	 */
	public class DateTimeUtils
	{
		/**
		 * 判断传入的年份是否为闰年
		 * @param year 传入的年份
		 * @return 返回是否为闰年, true表示闰年
		 */
		public static function isLeapYear(year:Number):Boolean
		{
			if (year % 100 == 0)
			{
				if (year % 400 == 0)
				{
					return true;
				}
				return false;
			}
			else
			{
				if (year % 4 == 0)
				{
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		/**
		 * 返回YYYY-MM-DD
		 */
		public static function getTime(now:Date = null):String
		{
			var date:Date = now ? now : new Date();
			var hour:String = (date.getHours() > 9) ? String(date.getHours()) : "0" + date.getHours();
			var minutes:String = (date.getMinutes() > 9) ? String(date.getMinutes()) : "0" + date.getMinutes();
			var seconds:String = (date.getSeconds() > 9) ? String(date.getSeconds()) : "0" + date.getSeconds();
			return hour + ":" + minutes + ":" + seconds;
		}
		
		/**
		 * HH:MM:SS格式的日期字符串
		 */
		public static function getDate(now:Date = null):String
		{
			var date:Date = now ? now : new Date();
			var year:String = String(date.getFullYear());
			var month:String = (date.getMonth() + 1 > 9) ? String(date.getMonth() + 1) : "0" + (date.getMonth() + 1);
			var date_s:String = (date.getDate() > 0) ? String(date.getDate()) : "0" + date.getDate();
			return year + "-" + month + "-" + date_s;
		}
		
		/**
		 * 当前日期和时间 格式为  yyyy-mm-dd hh:mm:ss
		 */
		public static function getDateTime(now:Date = null):String
		{
			return getDate(now) + " " + getTime(now);
		}
		
		/**
		 * 通过传入的秒数返回MM:SS格式的字符串
		 * @param seconds 秒数的整数值
		 * @return 返回MM:SS格式的时间字符串
		 */
		public static function formatSecond(seconds:Number):String
		{
			var haveplayminite:Number = Math.floor(seconds / 60);
			var haveplaysecond:Number = Math.floor(Math.floor(seconds) % 60);
			var haveplayminite_s:String = String(haveplayminite);
			var haveplaysecond_s:String = String(haveplaysecond);
			if (haveplayminite < 10)
			{
				haveplayminite_s = "0" + String(haveplayminite);
			}
			if (haveplaysecond < 10)
			{
				haveplaysecond_s = "0" + String(haveplaysecond);
			}
			var out_put:String = haveplayminite_s + ":" + haveplaysecond_s;
			return out_put;
		}
		
		/**
		 * 通过传入的毫秒时间,返回MM:SS格式的字符串
		 * @param millisecond 毫秒的整数值
		 * @return 返回MM:SS格式的字符串
		 *
		 */
		public static function formatMillisecond(millisecond:Number):String
		{
			var haveplayminite:int = Math.floor(millisecond / 60000);
			var haveplaysecond:int = Math.floor(Math.floor(millisecond / 1000) % 60);
			var haveplayminite_s:String = String(haveplayminite);
			var haveplaysecond_s:String = String(haveplaysecond);
			if (haveplayminite < 10)
			{
				haveplayminite_s = "0" + String(haveplayminite);
			}
			if (haveplaysecond < 10)
			{
				haveplaysecond_s = "0" + String(haveplaysecond);
			}
			var out_put:String = haveplayminite_s + ":" + haveplaysecond_s;
			return out_put;
		}
		
		/**
		 * 获取一个通过时间来生成的字符串
		 */
		public static function getTimeString():String
		{
			var date:Date = new Date();
			var returnStr:String = String(date.getFullYear()) + String(date.getMonth()) + String(date.getDate()) + String(date.getHours()) + String(date.getMinutes()) + String(date.getMilliseconds());
			return returnStr;
		}
		
		/**
		 * 转化一个String格式的时间为秒数 Supported are 00:03:00.1 / 03:00.1 / 180.1s / 3.2m / 3.2h
		 * @param str	The input string. Supported are 00:03:00.1 / 03:00.1 / 180.1s / 3.2m / 3.2h
		 * @return		The number of seconds.
		 **/
		public static function seconds(str:String):Number
		{
			str = str.replace(',', '.');
			var arr:Array = str.split(':');
			var sec:Number = 0;
			if (str.substr(-2) == 'ms')
			{
				sec = Number(str.substr(0, str.length - 2)) / 1000;
			}
			else if (str.substr(-1) == 's')
			{
				sec = Number(str.substr(0, str.length - 1));
			}
			else if (str.substr(-1) == 'm')
			{
				sec = Number(str.substr(0, str.length - 1)) * 60;
			}
			else if (str.substr(-1) == 'h')
			{
				sec = Number(str.substr(0, str.length - 1)) * 3600;
			}
			else if (arr.length > 1)
			{
				sec = Number(arr[arr.length - 1]);
				sec += Number(arr[arr.length - 2]) * 60;
				if (arr.length == 3)
				{
					sec += Number(arr[arr.length - 3]) * 3600;
				}
			}
			else
			{
				sec = Number(str);
			}
			return sec;
		}
		
		/**
		 * 解析传入的YYYY-MM-DD格式的字符串,按照Date对象的方式返回
		 * @param s 输入的字符串对象
		 * @return 返回转换后的Date
		 */
		public static function parseDate(s:String):Date
		{
			var da:Array = s.split("-");
			return new Date(parseInt(da[0], 10), parseInt(da[1], 10) - 1, parseInt(da[2], 10));
		}
		
		/** Remove white space from before and after a string. **/
		public static function trim(s:String):String
		{
			return s.replace(/^\s+/, '').replace(/\s+$/, '');
		}
	}
}