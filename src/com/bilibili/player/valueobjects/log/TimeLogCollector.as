package com.bilibili.player.valueobjects.log
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	/**
	 * 时间事件log收集器
	 * type格式建议为"player_start"这种下划线全小写
	 * @author Lizeqiangd
	 * 20141112 初步完成
	 */
	public class TimeLogCollector extends EventDispatcher
	{
		private const _collector:Vector.<TimeLog> = new Vector.<TimeLog>
		
		public function get collector():Vector.<TimeLog>
		{
			return _collector
		}
		
		public function createTimeLog(type:String, title:String = ""):void
		{
			var tl:TimeLog = new TimeLog
			tl.type = type
			tl.title = title ? title : type
			_collector.push(tl)
			//if (_complete)
			//{
				//_complete = false
				//dispatchEvent(new UnitEvent(UnitEvent.UNIT_ACTIVE))
			//}
			dispatchEvent(new UIEvent(UIEvent.CHANGE))
			//trace("TimeLogCollector.createTimeLog:" + type)
		}
		
		public function setTimeLogEnd(type:String):void
		{
			for (var i:int = 0; i < _collector.length; i++)
			{
				if (_collector[i].type == type)
				{
					_collector[i].autoEnd()
					//_completeCount++
					//if (_completeCount == _collector.length)
					//{
						dispatchEvent(new UIEvent(UIEvent.UNIT_COMPLETED))
						//_complete = true
					//}
					dispatchEvent(new UIEvent(UIEvent.CHANGE))
					//trace("TimeLogCollector.setTimeLogEnd:" + type)
					return
				}
			}
			var tl:TimeLog = new TimeLog
			tl.type = type
			tl.title = type
			tl.autoEnd();
			_collector.push(tl)
			dispatchEvent(new UIEvent(UIEvent.UNIT_COMPLETED))
			dispatchEvent(new UIEvent(UIEvent.CHANGE))
			//trace("TimeLogCollector.setTimeLogEnd:" + type)
		}
		
		public function get length():uint
		{
			return _collector.length
		}
	}

}