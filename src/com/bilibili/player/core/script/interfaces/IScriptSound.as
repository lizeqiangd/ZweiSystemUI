package com.bilibili.player.core.script.interfaces
{
	/** 脚本中的声音 **/
	public interface IScriptSound
	{
		/** 加载百分比:0-100 **/
		function loadPercent():uint;
		/** 播放声音 **/
		function play(startTime:Number=0, loops:int=0):void;
		/** 停止播放声音 **/
		function stop():void;
		/** 停止加载 **/
		function remove():void;
	}
}