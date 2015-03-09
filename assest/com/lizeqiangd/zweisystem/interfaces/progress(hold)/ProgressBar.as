package com.lizeqiangd.zweisystem.interfaces.progress(hold)
{
	import com.zweisystem.abstracts.windows.DragWindows;
	import com.zweisystem.abstracts.windows.iApplication;
	import com.zweisystem.events.ApplicationEvent;
	import com.greensock.TweenLite;
	import flash.utils.setTimeout
	
	public class ProgressBar extends DragWindows implements iApplication
	{
		private var oriWidth:Number = 365;
		private var _title:String = "";
		
		public function ProgressBar()
		{
			super();
			title = "正在初始化";
			//var randomCode:Number =(Math.random ().toFixed (3)*100)
			this.setApplicationName = "ProgressBar"; //+randomCode.toString ()
			this.setDisplayLayer = "floatLayer";
			this.setApplicationVersion = "0.2";
			addUiListener();
			mc_bar1.width = 0
			//mc_bar2.width=0
			precent = 0;
		}
		
		public function init(e:ApplicationEvent)
		{
		
		}
		
		private function addUiListener()
		{
			addEventListener(ApplicationEvent.INIT, init);
			addEventListener(ApplicationEvent.CLOSE, applicationClose);
		}
		
		private function removeUiListener()
		{
			removeEventListener(ApplicationEvent.INIT, init);
			removeEventListener(ApplicationEvent.CLOSE, applicationClose);
		}
		
		private function applicationClose(e:ApplicationEvent)
		{
			removeUiListener();
		}
		
		public function dispose()
		{
			this.dispatchEvent(new ApplicationEvent(ApplicationEvent.CLOSE));
		}
		
		public function set progress(p:Number)
		{
			precent = p;
		}
		
		public function applicationMessage(e:Object)
		{
			switch (e)
			{
				case "": 
					break;
				default: 
					break;
			}
		}
		
		public function set precent(p:Number)
		{
			if (p < 0)
			{
				return;
			}
			if (p > 1)
			{
				p = 1;
			}
			TweenLite.to(mc_bar1, 1, {width: oriWidth * p})
			title = _title + String((p * 100).toFixed(2)) + "%";
			p == 1 ? setTimeout(dispose, 2000) : null;
		}
		
		public function set progressTitle(s:String)
		{
			this._title = s;
			this.title = s;
		}
		
		private function set title(t:String)
		{
			this.tx_title.text = t;
		}
	
	}
}