package com.bilibili.player.valueobjects.log
{
	import flash.utils.getTimer;
	
	/**
	 * 记录一个事件的名称和时间
	 * @author Lizeqiangd
	 */
	public class TimeLog
	{
		public var type:String = ""
		public var title:String = ""
		private var _start:uint = 0
		private var _end:uint = 0
		private var _delta:uint = 0
		
		public function TimeLog()
		{
			_start = getTimer()
		}
		
		public function autoEnd():void
		{
			end = getTimer()
		}
		
		public function set end(value:uint):void
		{
			//trace("TimeLog." + type + ": endTime inited")
			_end = _end > 0 ? _end : value;
			_delta = _end - _start
		}
		
		public function get start():uint
		{
			return _start
		}
		
		public function get end():uint
		{
			return _end;
		}
		
		public function get delta():uint
		{
			return _delta;
		}
	
	}

}