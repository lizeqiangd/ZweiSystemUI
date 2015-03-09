package com.bilibili.player.abstract.windows
{
	import com.bilibili.player.components.PositionUtility;
	import com.bilibili.player.events.ApplicationEvent;
	import com.bilibili.player.manager.AnimationManager;
	import com.bilibili.player.system.proxy.StageProxy;
	
	import flash.events.MouseEvent;

	/** DragWindows 程序可以被拖动。
	 * 2013.01.27修改了点击关系，修改了应用事件
	 * 2014.03.28修正bug,备注方法,修正路径.
	 * 2014.11.12为bilibili player更新
	 */
	public class DragWindows extends AnimeWindows
	{
		private static const _mc_bg:String = "sp_background";
		private var dragAble:Boolean = true
		
		/**
		 *DragWindows 构造函数,添加2个侦听器:程序开始关闭,程序初始化完成.
		 */
		public function DragWindows()
		{
			this.addEventListener(ApplicationEvent.CLOSE, onDragWindowsCloseHangle);
			this.addEventListener(ApplicationEvent.INITED, onDragWindiowsInitedHandle);
		}
		
		/**
		 *当程序初始化完成的时候,对程序添加拖拽侦听
		 */
		private function onDragWindiowsInitedHandle(e:ApplicationEvent):void
		{
			this.removeEventListener(ApplicationEvent.INITED, onDragWindiowsInitedHandle);
			try
			{
				StageProxy.addEventListener(MouseEvent.MOUSE_UP, onDragWindowsStopDrag);
				this[DragWindows._mc_bg].addEventListener(MouseEvent.MOUSE_DOWN, onDragWindowsStartDrag);
					//stage.addEventListener(MouseEvent.RELEASE_OUTSIDE, onDragWindowsStopDrag, false, 0, true);
			}
			catch (e:*)
			{
				trace("DragWindows配置错误，找不到需要的实例，请检查mc_bg是否存在。");
			}
		}
		
		/**
		 *当程序开始关闭的时候,移除本抽象类的侦听器
		 */
		private function onDragWindowsCloseHangle(e:ApplicationEvent):void
		{
			this.removeEventListener(ApplicationEvent.CLOSE, this.onDragWindowsCloseHangle);
			this[DragWindows._mc_bg].removeEventListener(MouseEvent.MOUSE_DOWN, this.onDragWindowsStartDrag);
			
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onDragWindowsStopDrag);
			//StageProxy.stage.removeEventListener(Event.MOUSE_LEAVE,onUIStopDrag);
		}
		
		/**
		 *当拖动开始的时候的操作.同时也是子类拖动用的方法.
		 */
		protected function onDragWindowsStartDrag(e:MouseEvent):void
		{
			if (dragAble)
			{
				this.startDrag();
			}
		}
		
		/**
		 *当拖动结束的时候,如果窗口已经飞离舞台,则重新让它回到舞台.
		 */
		protected function onDragWindowsStopDrag(e:MouseEvent):void
		{
			this.stopDrag();
			PositionUtility.setDisplayBackToStage(this)
		}
		
		/**
		 *设置背景色块的alpha属性
		 */
		public function set setBgAlpha(e:Number):void
		{
			AnimationManager.fade(getChildByName(DragWindows._mc_bg), e)
		}
		
		/**
		 *设置是否可以拖拽本窗口
		 */
		public function set setDragEnable(e:Boolean):void
		{
			this.stopDrag();
			dragAble = e
		}
		
		/**
		 *获取当前窗口是否可以拖拽.
		 */
		public function get getDragEnable():Boolean
		{
			return dragAble
		}
	
	}
}