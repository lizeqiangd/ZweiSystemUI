package com.bilibili.player.applications.Unitils.PlayerStartWindows
{
	import com.bilibili.player.abstract.windows.iApplication;
	import com.bilibili.player.abstract.windows.TitleWindows;
	import com.bilibili.player.components.PositionUtility;
	import com.bilibili.player.events.ApplicationEvent;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.bilibili.player.system.proxy.StageProxy;
	import com.bilibili.player.valueobjects.log.TimeLog;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * @author Lizeqiangd
	 * @email lizeqiangd@gmail.com
	 * @website lizeqiangd.com
	 */
	
	public class PlayerStartWindows extends TitleWindows implements iApplication
	{
		private var log:Object = {}
		private var tx_log:TextField
		
		private var timer_fps:Timer
		private var fps:uint = 0
		private var fps_text:String = ""
		
		public function PlayerStartWindows()
		{
			this.setApplicationTitle = "- 播放器自检 -";
			this.setApplicationName = "PlayerStartWindows";
			this.addEventListener(ApplicationEvent.INIT, init);
			configWindows(400, 250)
			PositionUtility.center(this)
		}
		
		public function init(e:ApplicationEvent):void
		{
			tx_log = new TextField
			var tf:TextFormat = BPTextFormat.LightBlueTitleTextFormat
			tf.align = TextFormatAlign.LEFT
			tx_log.defaultTextFormat = tf
			tx_log.multiline = true
			tx_log.text = ""
			tx_log.width = getUiWidth
			tx_log.height = getUiHeight - 20
			addChild(tx_log)
			tx_log.y = 20
			
			timer_fps = new Timer(1000)
			timer_fps.start()
			dispatchEvent(new ApplicationEvent(ApplicationEvent.INITED))
			addApplicationListener()
		}
		
		private function addApplicationListener():void
		{
			StageProxy.addEnterFrameFunction(onTimeLogHandle)
			this.addEventListener(ApplicationEvent.CLOSE, onApplicationClose);
			StageProxy.addResizeFunction(onResize)
			//ValueObjectManager.getTimeLogCollector.addEventListener(UnitEvent.UNIT_ACTIVE, onLogActive)
			//ValueObjectManager.getTimeLogCollector.addEventListener(UnitEvent.UNIT_COMPLETED, onLogComplete)
			ValueObjectManager.getTimeLogCollector.addEventListener(UIEvent.CHANGE, onLogComplete)
			
			timer_fps.addEventListener(TimerEvent.TIMER, onFpsTimerHandle)
		}
		
		private function onFpsTimerHandle(e:TimerEvent):void
		{
			fps_text = "FPS:" + fps.toString()+"("+StageProxy.stage.frameRate+")"
			fps = 0
		}
		
		private function onResize():void
		{
			PositionUtility.center(this)
		}
		
		private function onLogComplete(e:UIEvent):void
		{
			//StageProxy.removeEnterFrameFunction(onTimeLogHandle)
			//onTimeLogHandle()
		}
		
		private function onLogActive(e:UIEvent):void
		{
			//StageProxy.addEnterFrameFunction(onTimeLogHandle)
		}
		
		private function onTimeLogHandle():void
		{
			fps++
			if (ValueObjectManager.getTimeLogCollector.length)
			{
				tx_log.text = fps_text + "\n"
				var now:uint = getTimer()
				var tl:TimeLog
				for (var i:int; i < ValueObjectManager.getTimeLogCollector.length; i++)
				{
					tl = ValueObjectManager.getTimeLogCollector.collector[i]
					if (ValueObjectManager.getTimeLogCollector.collector[i].delta > 0)
					{
						tx_log.appendText(tl.title + " S:" + tl.start + "ms E:" + tl.end + "ms 耗时:" + tl.delta + "ms 完成")
					}
					else
					{
						tx_log.appendText(tl.title + " S:" + tl.start + "ms 已经进行:" + (now - tl.start) + "ms")
					}
					tx_log.appendText("\n")
				}
			}
		}
		
		private function removeApplicationListener():void
		{
			this.removeEventListener(ApplicationEvent.INIT, init);
			this.removeEventListener(ApplicationEvent.CLOSE, onApplicationClose);
		}
		
		private function onApplicationClose(e:ApplicationEvent):void
		{
			removeApplicationListener();
		
		}
		
		public function dispose():void
		{
			dispatchEvent(new ApplicationEvent(ApplicationEvent.CLOSE))
		}
		
		public function applicationMessage(e:Object):void
		{
			switch (e)
			{
				case "": 
					break;
				default: 
					break;
			}
		}
	}

}