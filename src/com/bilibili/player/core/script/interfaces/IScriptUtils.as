package com.bilibili.player.core.script.interfaces
{
	import flash.utils.Timer;

	/** 有用的函数 **/
	public interface IScriptUtils
	{
		/**
		 * 360到饱和度为100%的颜色的映射
		 * @param v 数字参数,0-360
		 * @return 颜色值
		 **/
		function hue(v:int):int;
		/**
		 * 从r,g,b合成颜色0xrrggbb
		 **/
		function rgb(r:int, g:int, b:int):int;
		/**
		 * 格式化时间
		 * @param time 时间/秒
		 * @return ##:##格式的时间
		 **/
		function formatTimes(time:Number):String;
		/**
		 * 延迟执行
		 * @param f 需要执行的函数
		 * @time 延迟时间/毫秒
		 * @return setTimeout的返回值
		 **/
		function delay(f:Function, time:Number=1000):uint;
		/**
		 * 定时执行的函数
		 * @param f 需要执行的函数
		 * @param time 时间间隔/ms
		 * @param times 次数/0为永远执行下去(除非使用其他函数停止)
		 **/
		function interval(f:Function, time:Number=1000, times:uint=1):Timer;
		/**
		 * 计算两点间的距离
		 **/
		function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number;
		/**
		 * 伪随机数
		 * @param min 最小值
		 * @param max 最大值(不包括)
		 * @return [min,max)上的整数
		 **/
		function rand(min:Number,max:Number):Number;
		/**
		 * 深拷贝
		 **/
		function clone(object:*):*;
		/**
		 * 迭代
		 **/
		function foreach(iter:Object, func:Function):void;
	}
}