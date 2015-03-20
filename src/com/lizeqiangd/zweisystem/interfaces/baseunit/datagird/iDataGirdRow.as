package com.lizeqiangd.zweisystem.interfaces.baseunit.datagird
{
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public interface iDataGirdRow
	{
		function update():void
		//function animation_start():void
		//function animation_init():void
		
		function setDataProvider(e:Object):void
		function getRowHeight():Number 
		
		function dispose():void
		function setIndexInArray(e:uint):void
		function setEventDispatch(ed:EventDispatcher):void 
	}

}