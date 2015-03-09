package com.bilibili.player.applications.Unitils.NetworkTester 
{
	import com.bilibili.player.abstract.windows.TitleWindows;
	import com.bilibili.player.abstract.windows.iApplication;
	import com.bilibili.player.components.PositionUtility;
	import com.bilibili.player.events.ApplicationEvent;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.bilibili.player.system.proxy.StageProxy;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author Lizeqiangd
	 * @email lizeqiangd@gmail.com
	 * @website lizeqiangd.com
	 */
	
	public class NetworkTester extends TitleWindows implements iApplication 
	{
		private var tf:TextField
		public function NetworkTester()
		{
			this.setApplicationTitle = "- NetworkTester -";
			this.setApplicationName="NetworkTester";			
			this.addEventListener(ApplicationEvent.INIT,init);
			configWindows(400,220)
			onResize()
			tf=new TextField()
			ValueObjectManager.getNetworkTesterReporter.addEventListener(UIEvent.REPORT,onReport)
		}
		public function init(e:ApplicationEvent):void
		{
				tf.width=400
				tf.height=200
				tf.y=20
					var tformat:TextFormat=BPTextFormat.LightBlueTitleTextFormat
					tformat.align=TextFormatAlign.LEFT
				tf.defaultTextFormat=tformat
				tf.text="初始化界面完成.等待log."
			addChild(tf)
			if(ValueObjectManager.getNetworkTesterReporter.getUserIp()!="0"){
				tf.text="ip:"+ValueObjectManager.getNetworkTesterReporter.getUserIp()+"\n"
			}
			dispatchEvent (new ApplicationEvent (ApplicationEvent.INITED))
			addApplicationListener()
			
		}
		private function addApplicationListener():void
		{ 
//			ValueObjectManager.getNetworkTesterReporter.addEventListener(UnitEvent.REPORT,onReport)
			
			StageProxy.addResizeFunction(onResize)
			this.addEventListener(ApplicationEvent.CLOSE,onApplicationClose);
		}
		private function onReport(e:UIEvent):void{
			trace("type:"+e.data.type,e.data.info)
			switch(e.data.type)
			{
				case "ip":
				{
					tf.appendText("ip:"+e.data.info)

					break;
				}
				case "reconnection":
				{
					tf.appendText("re:"+e.data.info)					
					break;
				}
				case "disconnection":
				{
					tf.appendText("dis:"+e.data.info)
					break;
				}
				case "url":
				{
					tf.appendText("url:"+e.data.info)	
					break;
				}
					
				default:
				{
					break;
				}
			}tf.appendText("\n")
		}
		
		private function onResize():void 
		{
			PositionUtility.center(this)
		}
		private function removeApplicationListener()
		{
			this.removeEventListener(ApplicationEvent.INIT,init);
			this.removeEventListener(ApplicationEvent.CLOSE,onApplicationClose);
		}
		private function onApplicationClose(e:ApplicationEvent)
		{	removeApplicationListener();
			
		}
		public function dispose():void
		{
			dispatchEvent(new ApplicationEvent(ApplicationEvent.CLOSE))
		}
		public function applicationMessage(e:Object ):void
		{
			switch (e)
			{
				case "" :
					break;
				default :
					break;
			}
		}
	}
	
}