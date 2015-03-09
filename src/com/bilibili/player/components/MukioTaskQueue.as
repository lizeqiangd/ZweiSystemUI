package com.bilibili.player.components
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * 同步事件队列
	 * @author Aristotle9
	 * 20141208 可耻的修改了类路径.其次.这类写的好简单暴力评论.
	 **/
	public class MukioTaskQueue extends EventDispatcher
	{
		private var _tasks:Array = [];
		
		/** 是否二进制数据:全部任务!! **/
		public var isBinary:Boolean = false;
		
		public function MukioTaskQueue(target:IEventDispatcher = null)
		{
			super(target);
		}
		
		/**
		 * 添加工作api
		 * @param name 工作名称,不可重复
		 * @param action 工作函数
		 * @param args:Array 工作函数的参数,type:Array
		 * @return 任务id
		 **/
		private function add(name:String, action:Function, args:Array = null):int
		{
			_tasks.push({name: name, action: action, args: args});
			return _tasks.length;
		}
		
		/**
		 * 移除任务api
		 * 当所有任务都移除后发送complete事件
		 * @param name 工作名称
		 **/
		public function remove(name:String):void
		{
			for (var i:int = 0; i < _tasks.length; i++)
			{
				var o:Object = _tasks[i];
				if (o.name == name)
				{
					_tasks.splice(i, 1);
//                    trace("小工作完成:"+name);
					break;
				}
			}
			if (_tasks.length == 0)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * 开始执行工作队列
		 * 在添加好工作后方可以执行
		 * 当所有工作完成后发送complete事件
		 **/
		public function work():void
		{
			for each (var o:Object in _tasks)
			{
//                trace("小工作开始:"+o.name);
				o.action.apply(null, o.args);
			}
		}
		
		/**
		 * 加载工作api
		 * @param url url
		 * @param complete function(data:*):void,在成功时执行
		 * @return 任务id
		 **/
		public function beginLoad(url:String, complete:Function):int
		{
			return add(_tasks.length.toString(), loadTask(_tasks.length.toString(), url, complete), [this]);
		}
		
		/** 加载functor **/
		private function loadTask(name:String, url:String, complete:Function):Function
		{
			return function loadConfigXML(tasks:MukioTaskQueue):void
			{
				var loader:URLLoader = new URLLoader();
				var req:URLRequest = new URLRequest(url);
				if (isBinary)
				{
					loader.dataFormat = URLLoaderDataFormat.BINARY;
				}
				var completeHandler:Function = function(event:Event):void
				{
					complete(loader.data);
					loader.removeEventListener(Event.COMPLETE, completeHandler);
					loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
					tasks.remove(name);
				};
				var errorHandler:Function = function(event:Event):void
				{
					trace('加载任务失败:' + event.toString())
					complete(null);
					loader.removeEventListener(Event.COMPLETE, completeHandler);
					loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
					tasks.remove(name);
				}
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				try
				{
					loader.load(req);
				}
				catch (error:Error)
				{
					trace('加载任务失败:' + error.toString())
				}
			}
		}
	}
}