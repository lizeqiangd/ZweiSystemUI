package com.bilibili.player.system.proxy
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.display.LoaderInfo;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.events.Event;
	
	/** 用于管理舞台用的类，可以方便您的添加resize和enterFrame的侦听
	 * @Creator：lizeqiangd
	 * @2012.12.12
	 * 参考了下aidn的设计。。。。
	 * 2014.03.18 重新添加注释.基本没法更改...赞,说句实话我至今无法理解这样做的好处是什么...
	 * 2014.12.17 把禁用右键添加到代理中,其次把不缩放和左上角固定放入本类.
	 * 2015.01.06 将ZweiSystem新功能添加到bilibili命名空间
	 */
	public class StageProxy
	{
		private static var _stageWidth:int;
		private static var _stageHeight:int;
		private static var _stage:Stage;
		private static var _resizeFuncs:Dictionary;
		private static var _enterFrameFuncs:Dictionary;
		private static var _enterFrameTotal:int;
		
		private static var inited:Boolean = false
		private static var _tabIndex:int = -1
		
		/**
		 * 初始化当前舞台代理.
		 */
		public static function init(_arg1:Stage , _arg2:String = "noScale", _arg3:String = "TL"):void
		{
			if (inited)
			{
				trace("StageProxy.init:already inited")
				return
			}
			_stage = _arg1;
			_stage.scaleMode = _arg2;
			_stage.align = _arg3;
			_stage.addEventListener(Event.RESIZE, _resize);
			_resizeFuncs = new Dictionary();
			_enterFrameFuncs = new Dictionary();
			_enterFrameTotal = 0;
			_stage.quality = StageQuality.BEST;
			_resize(null);
		
		}
		
		public static function get x():int
		{
			return stage.x;
		}
		
		public static function get y():int
		{
			return stage.y;
		}
		
		public static function get stageWidth():int
		{
			return _stageWidth;
		}
		
		public static function get stageHeight():int
		{
			return _stageHeight;
		}
		
		/**
		 * 将目标作为当前舞台聚焦对象
		 */
		public static function set focus(o:InteractiveObject):void
		{
			_tabIndex = 0
			o.tabIndex = _tabIndex
			stage.focus = o;
		}
		
		/**
		 * 返回当前舞台聚焦对象
		 */
		public static function get focus():InteractiveObject
		{
			return stage.focus;
		}
		
		/**
		 * 设置下一个聚焦
		 * @param	io
		 * @return
		 */
		public static function nextTabForce(io:InteractiveObject):int
		{
			_tabIndex++
			io.tabIndex = _tabIndex
			return _tabIndex
		}
		
		/**
		 * 对舞台直接添加弱侦听事件.
		 */
		public static function addEventListener(type:String, listener:Function):void
		{
			stage.addEventListener(type, listener, false, 0.0, true);
		}
		
		public static function removeEventListener(type:String, listener:Function):void
		{
			stage.removeEventListener(type, listener);
		}
		
		public static function addChild(child:DisplayObject):void
		{
			stage.addChild(child);
		}
		
		public static function removeChild(child:DisplayObject):void
		{
			stage.removeChild(child);
		}
		
		public static function setChildIndex(child:DisplayObject, index:int):void
		{
			stage.setChildIndex(child, index);
		}
		
		//////////////////////////////
		
		/**
		 * 将方法添加到Resize中.这是一个便利的方法,不需要声明一堆时间,直接调用就ok.相当方便
		 */
		public static function addResizeFunction(_arg1:Function):void
		{
			if (!(_resizeFuncs[_arg1] is Function))
			{
				_resizeFuncs[_arg1] = _arg1;
			}
		}
		
		/**
		 * 将方法从Resize中移除
		 */
		public static function removeResizeFunction(_arg1:Function):void
		{
			if ((_resizeFuncs[_arg1] is Function))
			{
				_resizeFuncs[_arg1] = null;
				delete _resizeFuncs[_arg1];
			}
		}
		
		/**
		 * 将方法添加到EnterFrame中.这是一个便利的方法,不需要声明一堆时间,直接调用就ok.相当方便
		 */
		public static function addEnterFrameFunction(_arg1:Function):void
		{
			
			if (!(_enterFrameFuncs[_arg1] is Function))
			{
				_enterFrameFuncs[_arg1] = _arg1;
				//trace("StageProxy.addEnterFrameFunction:",_arg1);
				if (++_enterFrameTotal == 1)
				{
					//trace("StageProxy.addEnterFrameFunction:开始运作");
					_stage.addEventListener(Event.ENTER_FRAME, _enterFrame);
				}
			}
		}
		
		/**
		 * 将方法从EnterFrame中移除
		 */
		public static function removeEnterFrameFunction(_arg1:Function):void
		{
			if ((_enterFrameFuncs[_arg1] is Function))
			{
				_enterFrameFuncs[_arg1] = null;
				delete _enterFrameFuncs[_arg1];
				//trace("StageProxy.removeEnterFrameFunction:",_arg1);
				if (--_enterFrameTotal == 0)
				{
					//trace("StageProxy.removeEnterFrameFunction:开始运作");
					_stage.removeEventListener(Event.ENTER_FRAME, _enterFrame);
				}
			}
		}
		
		/**
		 * 针对舞台大小更改,或者模块大小改变而强行调用舞台大小改变
		 */
		public static function updateStageSize():void
		{
			_resize(null);
		}
		
		/**
		 * 舞台大小内部方法.
		 */
		private static function _resize(_arg1:Event):void
		{
			var _local2:Function;
			_stageWidth = _stage.stageWidth;
			_stageHeight = _stage.stageHeight;
			for each (_local2 in _resizeFuncs)
			{
				if ((_local2 is Function))
				{
					_local2();
				}
			}
		}
		
		/**
		 * EnterFrame内部方法.
		 */
		private static function _enterFrame(_arg1:Event):void
		{
			
			var _local2:Function;
			for each (_local2 in _enterFrameFuncs)
			{
				if ((_local2 is Function))
				{
					_local2();
				}
			}
		}
		
		/**
		 * 获取舞台
		 */
		public static function get stage():Stage
		{
			return (_stage);
		}
		
		/**
		 * 获取当前LoaderInfo(用于递交参数和文件大小)
		 */
		public static function get loaderInfo():LoaderInfo
		{
			return (_stage.loaderInfo);
		}
		
		/**
		 * 是否禁用全局右键
		 */
		public static function enableRightClick(enable:Boolean = false):void
		{
			function onRightClick(e:MouseEvent)
			{
			};
			if (enable)
			{
				_stage.removeEventListener(MouseEvent.RIGHT_CLICK, onRightClick)
				
				//Cc.debug('StageProxy:RightClick is enabled.');
				return;
			}
			else
			{
				if (!_stage.hasEventListener(MouseEvent.RIGHT_CLICK))
				{
					_stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);					
					//Cc.debug('StageProxy:RightClick is disabled.');
					return;
				}
				//Cc.debug('StageProxy:RightClick is already disabled.');
				return;
			}
		
		}
	}
}