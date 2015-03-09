package com.lizeqiangd.zweisystem.abstract.windows
{
	import com.lizeqiangd.zweisystem.system.applications.background.BackgroundManager;
	import com.lizeqiangd.zweisystem.system.applications.title.TitleManager;
	import com.lizeqiangd.zweisystem.events.ApplicationEvent;
	import com.lizeqiangd.zweisystem.manager.AnimationManager;
	
	/**
	 * 这是一个全屏用的程序.他直接继承有开启动画的应用.
	 */
	public class FullWindows extends AnimeWindows
	{
		private static const _mc_bg:String = "mc_bg";
		private var _backgroundControlType:String = BackgroundManager.whiteWithoutText
		
		public function FullWindows()
		{
			this.setDisplayLayer = "backgroundLayer";
			this.setClosingAnimationType = "fade_out";
			this.setOpeningAnimationType = "fade_in";
			this.setFocusAble = false
			this.addEventListener(ApplicationEvent.INITED, onFullWindowsOpenHangle);
			this.addEventListener(ApplicationEvent.CLOSE, onFullWindowsCloseHangle);
		}
		
		private function onFullWindowsOpenHangle(e:ApplicationEvent)
		{
			BackgroundManager.control(_backgroundControlType)
		}
		
		private function onFullWindowsCloseHangle(e:ApplicationEvent)
		{
			removeEventListener(ApplicationEvent.INITED, onFullWindowsOpenHangle);
			removeEventListener(ApplicationEvent.CLOSE, onFullWindowsCloseHangle);
			BackgroundManager.control(BackgroundManager.recover)
		}
		
		public function set setBgAlpha(e:Number)
		{
			
		
		   try
		   {
		if (getChildByName(FullWindows._mc_bg))
			{
				AnimationManager.fade(getChildByName(FullWindows._mc_bg), e)
			}
		   }
		   catch (e:*)
		   {
		   trace("FullWindows配置错误，找不到需要的实例，请检查mc_bg是否存在。");
		 }
		}
		
		public function set setBackgroundTitle(s:String)
		{
			if (s)
			{
				TitleManager.MainTitle = s
			}
		}
		
		public function get getBackgroundControlType():String
		{
			return _backgroundControlType;
		}
		
		public function set setBackgroundControlType(value:String):void
		{
			_backgroundControlType = value;
		}
	}
}