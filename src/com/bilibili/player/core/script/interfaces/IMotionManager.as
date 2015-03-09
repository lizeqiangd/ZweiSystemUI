package com.bilibili.player.core.script.interfaces
{
	/** 动画组 **/
	public interface IMotionManager
	{
		/** 是否在播放中 **/
		function get running():Boolean;
		/** 重置 **/
		function reset():void;
		/** 播放动画 **/
		function play():void;
		/** 停止动画 **/
		function stop():void;
		/** 
		 * 在给定的时间测试动画是否正在运行 
		 * @param time 给定的时间点/ms
		 **/
		function forcasting(time:Number):Boolean;
		/** 
		 * 设置开始播放的时间
		 * @param time 播放时间/ms 
		 **/
		function setPlayTime(time:Number):void;
		/**
		 * 初始化动画配置
		 * @param MotionConfig 配置对象
		 * @param motionGroup 是否添加为组
		 **/
		function initTween(MotionConfig:Object, motionGroup:Boolean=false):String;
		/**
		 * 用配置组来初始化动画配置
		 * @param MotionConfigs 配置对象的数组
		 * @param lifeTime 总体持续时间
		 **/
		function initTweenGroup(MotionConfigs:Array, lifeTime:Number=NaN):void;
		/**
		 * 设置完成时执行的函数
		 * @param tmr_f 完成时执行的函数
		 **/
		function setCompleteListener(tmr_f:Function):void;
	}
}