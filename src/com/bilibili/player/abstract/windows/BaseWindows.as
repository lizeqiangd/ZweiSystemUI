package com.bilibili.player.abstract.windows
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.bilibili.player.events.ApplicationEvent;
	import com.bilibili.player.manager.ModuleManager;
	import flash.events.MouseEvent;
	
	/**BaseWindows是所有windows的基类，记录应用程序的基本信息。
	 * Lizeqiangd @2012.10.29
	 * 2013.01.27 更新应用事件。
	 * 2014.03.28 更新所有备注.并重新检查.  目前无法进行任何更改...很完善?
	 * 2014.11.11 为bilibili player更新
	 */
	public class BaseWindows extends BaseUI
	{
		private var appName:String = "untitled";
		private var displayLayer:String = "windowsLayer";
		private var mutiExist:Boolean = false;
		private var isFocusAble:Boolean = true;
		
		/**
		 * BaseWindows的构造函数,对本应用添加事件侦听器,打开完成和完全关闭,以及对鼠标的侦听以触发聚焦.
		 * 同时调度ApplicationEvent.OPEN事件
		 */
		public function BaseWindows()
		{
			this.setBackGroundColor = 0x000000
			this.addEventListener(ApplicationEvent.CLOSED, onBaseWindowsClosedHangle);
			this.addEventListener(ApplicationEvent.OPENED, onBaseWindowsOpenedHangle);
			this.addEventListener(ApplicationEvent.OPEN, onBaseWindowsOpenHangle);
			this.dispatchEvent(new ApplicationEvent(ApplicationEvent.OPEN));
		}
		
		/**
		 * 设置basewindows的设置
		 * @param	_w
		 * @param	_h
		 */
		public function configWindows(_w:Number, _h:Number):void
		{
			this.configBaseUi(_w, _h)
			this.createFrame(true)
			this.createBackground(0.7)
		}
		
		/**
		 * 该方法将 ApplicationEvent.CLOSE 事件放入本应用,则应用将会和常规关闭方法一样被关闭.
		 */
		public function CloseApplication(e:* = null):void
		{
			this.dispatchEvent(new ApplicationEvent(ApplicationEvent.CLOSE));
		}
		
		/**
		 * 强行将本应用成为LayerManager中的聚焦程序,相当于被点击.
		 */
		private function onBaseWindowsFocus(e:MouseEvent):void
		{
			if (isFocusAble)
			{
				ModuleManager.setForceLayer(this);
			}
		}
		
		/**
		 * BaseWindows当窗口被确认打开后执行的方法.
		 * private function onBaseWindowsOpenedHangle(e:ApplicationEvent):void
		 */
		private function onBaseWindowsOpenedHangle(e:ApplicationEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, onBaseWindowsFocus);
		}
		
		/**
		 * BaseWindows当窗口被打开时执行的方法. 默认无事件,可覆盖
		 * 本方法原本只在LayerManager中处理
		 */
		private function onBaseWindowsOpenHangle(e:ApplicationEvent):void
		{
		
		}
		
		/**
		 * BaseWindows当窗口被关闭完成的时候调用的方法.
		 * 例如重新恢复背景菜单等.不建议覆盖.
		 */
		private function onBaseWindowsClosedHangle(e:ApplicationEvent):void
		{
			this.removeEventListener(ApplicationEvent.CLOSED, onBaseWindowsClosedHangle);
			this.removeEventListener(ApplicationEvent.OPENED, onBaseWindowsOpenedHangle);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onBaseWindowsFocus);
			if (!(this is AnimeWindows))
			{
				//trace("BaseWindows CLOSED函数");
				dispatchEvent(new ApplicationEvent(ApplicationEvent.CLOSED));
			}
		}
		
		/**
		 *获取该应用是否允许多重存在.
		 */
		
		public function set setMutiExistEnable(e:Boolean):void
		{
			mutiExist = e;
		}
		
		/**
		 * 获取应用程序是否允许多重存在
		 */
		public function get getMutiExistEnable():Boolean
		{
			return mutiExist;
		}
		
		/**
		 * 设置当前应用程序名字.
		 */
		public function set setApplicationName(e:String):void
		{
			appName = e;
		}
		
		/**
		 * 获取应用程序名字.
		 */
		public function get getApplicationName():String
		{
			return appName;
		}
		
		/**
		 * 设置当前应用显示层.初始化之前定义有效.之后修改无效.
		 * 目前锁死不允许更改.
		 */
		public function set setDisplayLayer(e:String):void
		{
			//displayLayer = e;
		}
		
		/**
		 * 获取当前应用程序显示层名称
		 */
		public function get getDisplayLayer():String
		{
			return displayLayer;
		}
		
		/**
		 * 设置当前应用是否允许被聚焦(放置最前)
		 */
		public function set setFocusAble(e:Boolean):void
		{
			isFocusAble = e;
		}
		
		/**
		 * 获取该程序是否允许被聚焦.
		 */
		public function get getFocusAble():Boolean
		{
			return isFocusAble;
		}
	
	}
}