package com.bilibili.player.applications.StageAnimation
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.bilibili.player.events.AnimationEvent;
	import com.bilibili.player.system.proxy.StageProxy;
	import flash.utils.setTimeout
	
	/**
	 * 全站遮罩是建立在动画层的,不会影响到顶层的内容.该类交给AnimationManager管理.
	 * @author Lizeqiangd
	 * @email lizeqiangd@gmail.com
	 * @website http://www.lizeqiangd.com
	 * update
	 * 2014.04.04 更新路径,增加注释.优化.
	 */
	public class StageMask extends BaseUI
	{
		public function StageMask()
		{
			//this.setDisplayLayer = "animationLayer";
			//this.setBackgroundTitle = "Einstation System Application - StageMask -";
			//this.setApplicationName = "StageMask";
			//this.setApplicationVersion = "0"
			//this.setBackgroundControlType = "none"
			init()
		}
		
		public function init():void
		{
			this.graphics.beginFill(0, 1);
			this.graphics.drawRect(0, 0, 300, 300);
			this.graphics.endFill();
			this.alpha = 0
			StageProxy.addResizeFunction(onStageResize);
			onStageResize()
			setTimeout(onStageResize, 2000)
			//dispatchEvent(new ApplicationEvent(ApplicationEvent.INITED))
			//addApplicationListener()
		}
//		
//		private function addApplicationListener()
//		{
//			//this.addEventListener(AnimationEvent.START, onAnimationFadeIn);
//			//this.addEventListener(AnimationEvent.COMPLETE, onAnimationFadeOut);
//			//this.addEventListener(ApplicationEvent.CLOSE, onApplicationClose);
//		}
//		
//		private function removeApplicationListener()
//		{
//			//this.removeEventListener(AnimationEvent.START, onAnimationFadeIn);
//			//this.removeEventListener(AnimationEvent.COMPLETE, onAnimationFadeOut);
//			//this.removeEventListener(ApplicationEvent.CLOSE, onApplicationClose);
//		}
//		
		private function onApplicationClose(e:*):void
		{
			dispose()
		}
		
		public function dispose():void
		{
//			removeApplicationListener();
			StageProxy.removeResizeFunction(onStageResize);
		}
		
		private function onStageResize():void
		{
			this.width = StageProxy.stageWidth;
			this.height = StageProxy.stageHeight;
		}
		
		public function applicationMessage(e:Object):void
		{
		/*
		   switch (e.type)
		   {
		   case "alpha":
		   masker.alpha = e.value
		   break;
		   default:
		   break;
		 }*/
		}
	}

}