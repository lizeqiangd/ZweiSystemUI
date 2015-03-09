package com.bilibili.player.manager
{
	import com.bilibili.player.abstract.module.iModule;
	import com.bilibili.player.abstract.windows.BaseWindows;
	import com.bilibili.player.components.CompareClass;
	import com.bilibili.player.events.ApplicationEvent;
	import com.bilibili.player.system.proxy.StageProxy;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	/**
	 * 模块管理器.播放器核心.
	 *
	 * (模块是指整个播放器的功能显示和交互部分.
	 * 模块诸如:弹幕发射模块,他拥有的显示部分为 弹幕样式窗口,弹幕发送条,以及弹幕错误提示框
	 * 3个应用组成.然后该模块负责内部所有的交互,数据则通过VOManager[暂]统一管理全局数据.
	 * 模块之间的通信通过统一的全局模块侦听器互相沟通)
	 *
	 * 所有播放器均通过模块管理器进行启动和管理.
	 * 1.通过Module从最开始的地方声明然后将Class传入
	 * 2.模块管理器会将模块类新建为实例然后储存起来.并保证这是唯一的
	 * 3.通过接口将模块写入全球侦听器
	 * 4.模块实例初始化完成,等待模块管理器调度全部初始化完成
	 * 5.(模块处于被动等待数据的状态)
	 * 6.主流程下一步初始化全部资源管理器
	 * @author Lizeqiangd
	 * 20141111 模块更新为应用程序本体
	 */
	public class ModuleManager // extends 
	{
		public static const LAYER_BACKGROUND:String = "background"
		public static const LAYER_APPLICATION:String = "application"
		public static const LAYER_WINDOWS:String = "windows"
		public static const LAYER_FLOAT:String = "float"
		
		private static const BackgroundLayer:Sprite = new Sprite
		private static const ApplicationLayer:Sprite = new Sprite
		private static const WindowsLayer:Sprite = new Sprite
		private static const FloatLayer:Sprite = new Sprite
		
		private static const DisplayObjectInLayerPool:Object = {}
		private static const ModulePool:Object = {}
		private static const WindowsPool:Object = {}
		
		///激活整个模块管理器.
		public static function init():void
		{
			StageProxy.addChild(BackgroundLayer)
			StageProxy.addChild(ApplicationLayer)
			StageProxy.addChild(WindowsLayer)
			StageProxy.addChild(FloatLayer)
		}
		
		/**
		 * 创建模块
		 * @param	module_class
		 * @return
		 */
		public static function createModule(module_class:Class):iModule
		{
			var module:* = new module_class
			//保存到库中
			//module_pool[iModule(module).getModuleName.toLowerCase()] = module
			ModulePool[iModule(module).getModuleName.toLowerCase()] = module
			trace("ModuleManager.createModule:", iModule(module).getModuleName)
			iModule(module).init()
			return iModule(module)
		}
		
		/**
		 * 寻找模块
		 * @param	module_name
		 * @return
		 */
		public static function getModule(module_name:String):*
		{
			return ModulePool[module_name.toLowerCase()]
		}
		
		/**
		 * 直接从Class创建一个实例到显示层中.通常是系统级别应用和特殊用法.不建议直接使用.
		 * 如果Class是一个BaseWindows则按照常规走法,并会根据ApplicationEvent.CLOSED将其关闭删除.如果设定错误则程序会崩溃.
		 * 如果不是则会要求显示层,默认是顶层.
		 * 使用的话会触发一个ApplicationEvent.OPENED事件.使用完毕后务必卸载掉
		 * 同时返回这个Class的实例
		 * @param	c
		 * @return
		 */
		public static function createWindows(c:Class):*
		{
			var o:* = null
			///检测是否为BaseWindows,如果是则完全按照常规
			if (CompareClass.isSuperClass(c, BaseWindows))
			{
				///建立程序实例，居中，添加到指定层，添加关闭侦听。
				o = new c;
				EventDispatcher(o).addEventListener(ApplicationEvent.CLOSED, removeWindows, false, 0, true);
				//PositionUtility.center(o);
				ModuleManager.addToLayer(o, ModuleManager.LAYER_WINDOWS)
				o.dispatchEvent(new ApplicationEvent(ApplicationEvent.OPENED));
				return o;
			}
			return null
		}
		
		/**
		 * 当窗口关闭的时候调度移除背景.同时内部已经完成全部引用的移除了
		 * @param	e
		 */
		private static function removeWindows(e:ApplicationEvent):void
		{
			ModuleManager.removeFromLayer((e.target as DisplayObject))
		}
		
		/**
		 * 物件添加到应用层上
		 * @param	display_object
		 * @param	layer_name
		 */
		public static function addToLayer(display_object:DisplayObject, layer_name:String = "application"):void
		{
			switch (layer_name.toLowerCase())
			{
				case ModuleManager.LAYER_BACKGROUND: 
					trace("ModuleManager.LAYER_BACKGROUND:add", display_object)
					BackgroundLayer.addChild(display_object)
					DisplayObjectInLayerPool[display_object] = BackgroundLayer
					break;
				case ModuleManager.LAYER_APPLICATION: 
					trace("ModuleManager.LAYER_APPLICATION:add", display_object)
					ApplicationLayer.addChild(display_object)
					DisplayObjectInLayerPool[display_object] = ApplicationLayer
					break;
				case ModuleManager.LAYER_WINDOWS: 
					trace("ModuleManager.LAYER_WINDOWS:add", display_object)
					WindowsLayer.addChild(display_object)
					DisplayObjectInLayerPool[display_object] = WindowsLayer
					break;
				case ModuleManager.LAYER_FLOAT: 
					trace("ModuleManager.LAYER_FLOAT:add", display_object)
					FloatLayer.addChild(display_object)
					DisplayObjectInLayerPool[display_object] = FloatLayer
					break;
				default: 
			}
		
		}
		
		/**
		 * 物件从应用层移除
		 * @param	display
		 */
		public static function removeFromLayer(display_object:DisplayObject):void
		{
			DisplayObjectInLayerPool[display_object].removeChild(display_object)
			switch (DisplayObjectInLayerPool[display_object])
			{
				case FloatLayer: 
				case BackgroundLayer: 
				case ApplicationLayer: 
				case WindowsLayer: 
					break;
				default: 
			}
			delete DisplayObjectInLayerPool[display_object]
		}
		
		/**
		 * 类似于windows的点击窗口使之聚焦，成为最前。只能让basewindows操作.
		 * @param	display_object
		 */
		public static function setForceLayer(display_object:BaseWindows):void
		{
			if (display_object is BaseWindows && DisplayObjectInLayerPool[display_object] == WindowsLayer)
			{
				WindowsLayer.setChildIndex(display_object, WindowsLayer.numChildren - 1)				
			}
		}
	
	}

}