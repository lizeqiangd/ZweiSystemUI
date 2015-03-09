package com.bilibili.player.core.script.interfaces
{
	public interface IScriptConfig
	{
		/** 是否允许控制播放器api **/
		function get isPlayerControlApiEnable():Boolean;
		/** 是否允许脚本弹幕 **/
		function get scriptEnabled():Boolean;
		/** 是否开启调试模式 **/
		function get debugEnabled():Boolean;
		/** 是否使用代码高亮 **/
		function get codeHighlightEnabled():Boolean;
		/** commentTriggerManager,更改刚刚发送的弹幕的呈现 **/
		function get commentTriggerManager():ICommentTriggerManager;
		/** commentList弹幕列表 **/
		function get commentList():Array;
	}
}