package com.bilibili.player.net.interfaces
{
	public interface IPackSender
	{
		function writePack(index:int, payload:String):void;
	}
}