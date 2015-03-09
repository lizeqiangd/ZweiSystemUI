package com.bilibili.player.core.script.interfaces
{
	import flash.display.DisplayObject;

	/** 播放器控制/属性接口 **/
	public interface IScriptPlayer
	{
		/** 播放/恢复 **/
		function play():void;
		/** 暂停 **/
		function pause():void;
		/** 
		 * seek 
		 * @param offset 视频时间/单位毫秒
		 **/
		function seek(offset:Number):void;
		/** 跳转视频页面
		 * @param av av号,如'av120040'
		 * @param page 分页/从1开始
		 * @param newWindow 是否打开新窗口
		 **/
		function jump(av:String, page:int=1, newWindow:Boolean=false):void;
		/**
		 * 播放器状态:具有以下值
		 * playing,stop,pause
		 **/
		function get state():String;
		/**
		 * 播放器当前的时间/ms
		 **/
		function get time():Number;
		/**
		 * commentTrigger:监听发送者的弹幕/勾子
		 * @param func 监听函数具有如下签名:function(item:Object):void,item为弹幕数据
		 * @param timeout 监听多长时间/ms 
		 * @return 超时的id(setTimeout返回值)
		 **/
		function commentTrigger(func:Function, timeout:Number=1000):uint;
		/**
		 * keyTrigger:监听键盘
		 * @param func 回调函数,具有如下签名:function(keyCode:int):void,keyCode为键码,只能监听0-9,方向键,页面控制键
		 * @param timeout 监听多长时间/ms
		 * @param isUp 是否为监听keyUp事件
		 * @return 超时的id(setTimeout返回值)
		 **/
		function keyTrigger(func:Function, timeout:Number=1000, isUp:Boolean=false):uint;
		/**
		 * 设置播放器视频遮罩
		 * @param mask 遮罩
		 **/
		function setMask(mask:DisplayObject):void;
		/**
		 * 建立声音元件
		 * @param type 声音名称
		 * @param onLoad 加载完成时回调函数,具有签名:function(event:Event):void(别在意event参数)
		 **/
		function createSound(t:String, onLoad:Function=null):IScriptSound;
		/**
		 * 全部的弹幕数据/建议取消该属性
		 **/
		function get commentList():Array;
		/**
		 * 弹幕刷新速度(令人费解的属性)<br />
		 * 弹幕刷新速度(毫秒):默认170<br />
		 * 范围10-500<br />
		 * 精度上限0.1秒
		 **/
		function get refreshRate():int;
		/**
		 * @private
		 **/
		function set refreshRate(value:int):void;
		/**
		 * 播放器宽度
		 **/
		function get width():uint;
		/**
		 * 播放器高度
		 **/
		function get height():uint;
	}
}