package com.lizeqiangd.zweisystem.events
{
	import flash.events.Event;
	
	/**
	 * 本类为ZweiSystem的Unit事件.会负责大部分UI中反馈的事件.同时该事件会附带数据在其中.
	 * 据说这样做会导致这个事件一辈子无法被消除.你觉得可能吗~?呵呵呵 我相信Adobe
	 * 2014.03.18 修改类路径.
	 * 2014.09.29 给player做准备.
	 * 2015.03.06 重新打包成为独立类.
	 * @author:Lizeqiangd
	 */
	public class UIEvent extends Event
	{
		//模块组件触发的事件.
		public static const UNIT_ACTIVE:String = "unit_active";
		public static const UNIT_INACTIVE:String = "unit_inactive";
		public static const UNIT_ERROR:String = "unit_error";
		public static const UNIT_OPENED:String = "unit_opened";
		public static const UNIT_COMPLETED:String = "unit_completed";
		public static const UNIT_CLOSE:String = "unit_close";
		//单独的组件触发的事件
		public static const SUBMIT:String = "unit_submit"
		public static const CLICK:String = "unit_click";
		public static const CLOSE:String = "unit_close";
		public static const CANCEL:String = "unit_cancel";
		public static const BROWSE:String = "unit_browse";
		public static const CREATE:String = "unit_create";
		public static const EDIT:String = "unit_edit";
		public static const DELETE:String = "unit_delete";
		public static const SELECTED:String = "unit_selected";
		public static const CHANGE:String = "unit_change";
		public static const SEARCH:String = "unit_search";
		public static const CONFIG:String = "unit_config";
		//特殊操控指令
		public static const POSITION_CHANGE:String = "position_change";
		public static const STATE_CHANGE:String = "state_change";
		public static const REPORT:String = "report";
		public var data:*;
		
		public function UIEvent(type:String, DispatchData:* = null, bubbles:Boolean = false)
		{
			super(type, bubbles);
			data = DispatchData;
		}
	}
}