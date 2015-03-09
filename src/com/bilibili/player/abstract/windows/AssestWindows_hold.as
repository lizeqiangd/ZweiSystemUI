package com.lizeqiangd.zweisystem.abstract.windows
{
	import com.zweisystem.events.UnitEvent;
	import com.zweisystem.modules.progress.ProgressBar;
	import com.zweisystem.events.ApplicationEvent;
	import com.zweisystem.managers.LayerManager;
	import flash.display.Loader;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	/**
	 * 本窗口用于给外部加载的flash提供载体和自loader服务。用于文件大的应用，或者编译时间太长，无法次次都编译所制作。
	 * 缺点是编译过后无法通过App Stone。
	 * @author Lizeqiangd
	 * 2013.02.17 删除多余导入，重新适应新系统
	 */
	public class AssestWindows(hold extends TitleWindows
	{
		private var _assestSwfUrl:String = "";
		private var _assestLoader:Loader;
		private var _progressbar:ProgressBar;
		
		public function AssestWindows(hold()
		{
			//trace("AssestWindows 构造函数");
			/*try
			   {
			
			   }
			   catch (e: * )
			   {
			 }*/
			this.addEventListener(ApplicationEvent.INIT, onAssestWindows);
		}
		
		private function onAssestWindows(e:ApplicationEvent)
		{
			_assestLoader = new Loader();
			_assestLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_assestLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_assestLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_progressbar = LayerManager.createPopUp(ProgressBar);
			_progressbar.progressTitle = "初始化完成";
			_assestLoader.load(new URLRequest(_assestSwfUrl));
		}
		
		private function onProgress(s:ProgressEvent)
		{
			_progressbar.progress = s.bytesLoaded / s.bytesTotal
		}
		
		private function onComplete(s:Event)
		{
			_progressbar.progress = 1;
			this.addChild(content);
			_assestLoader.y = 20;
			this.dispatchEvent(s);
		}
		
		private function onError(s:IOErrorEvent)
		{
			_progressbar.progressTitle = "加载失败";
			_progressbar.progress = 1;
			this.dispatchEvent(s);
		}
		
		private function onCloseHandle(e:Event = null)
		{
			_assestLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_assestLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_assestLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			this.removeEventListener(ApplicationEvent.INIT, onAssestWindows);
			try
			{
				_assestLoader.unloadAndStop();
			}
			catch (e:*)
			{
				
			}
			try
			{
				_progressbar.dispose();
			}
			catch (e:*)
			{
				
			}
		}
		
		public function get content():*
		{
			return _assestLoader.content;
		}
		
		public function set setAssestUrl(s:String)
		{
			_assestSwfUrl = _assestSwfUrl == "" ? s : _assestSwfUrl;
		}
		
		public function get getAssestUrl():String
		{
			return _assestSwfUrl;
		}
	}
}