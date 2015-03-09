package com.bilibili.player.core.script
{
	//import com.longtailvideo.jwplayer.events.MediaEvent;
	//import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	//import com.longtailvideo.jwplayer.player.IPlayer;
	//import com.longtailvideo.jwplayer.player.PlayerState;
	
	import com.bilibili.player.core.script.interfaces.IScriptManager;
	import com.bilibili.player.events.MediaEvent;
	import com.bilibili.player.events.PlayerStateEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	
//	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import com.bilibili.player.core.script.interfaces.IMotionElement;
	import com.bilibili.player.core.script.interfaces.IScriptManager;
	import com.bilibili.player.system.namespaces.bilibili
		
	public class ScriptManager implements IScriptManager
	{
		protected var _elements:Dictionary = new Dictionary(true);
		protected var _timers:Dictionary = new Dictionary(true);
		
		//private var _player:IPlayer;
		/**
		 * 用于对外部库提供对factory的引用：使用更多的脚本相关变量
		 **/
		bilibili var factory:CommentScriptFactory;
		/**
		 * @param player 用于暂停/恢复运动物体
		 **/
		public function ScriptManager(/*player:IPlayer*/)
		{
			/*_player = player;*/
			
			ValueObjectManager.getMediaProvider.addEventListener(PlayerStateEvent.PLAYER_STATE, stateHandler);
			ValueObjectManager.getMediaProvider.addEventListener(MediaEvent.MEDIA_SEEK, seekHandler);
			ValueObjectManager.getMediaProvider.addEventListener(MediaEvent.MEDIA_COMPLETE, playerCompleteHandler);
		}
		/**
		 * 播放完成后清除所有的运动元件
		 **/
		private function playerCompleteHandler(event:MediaEvent):void
		{
			for(var elm:* in _elements)
			{
				if(elm is IMotionElement)
				{
					elm['visible'] = false;
				}
			}
		}
		/**
		 * 拖动视频后清除所有的运动元素
		 **/
		private function seekHandler(event:MediaEvent):void
		{
			//注意.
			var time:Number = ValueObjectManager.getMediaProvider.position * 1000;
			for(var elm:* in _elements)
			{
				if(elm is IMotionElement)
				{
					elm['visible'] = IMotionElement(elm).motionManager.forcasting(time);
				}
			}
		}
		/**
		 * 动画元件的播放与暂停,一旦进入舞台,将受播放器的播放/暂停状态影响
		 **/
		private function stateHandler(event:PlayerStateEvent):void
		{
			if(event.newstate === PlayerStateEvent.PLAYING)//resume
			{
				for(var elm:* in _elements)
				{
					if(elm is IMotionElement)
						IMotionElement(elm).motionManager.play();
				}
				
				for(var tm:* in _timers)
				{
					if(tm is Timer)
						Timer(tm).start();
				}
			}
			else if(event.oldstate === PlayerStateEvent.PLAYING)//pause
			{
				for(var elm1:* in _elements)
				{
					if(elm1 is IMotionElement)
						IMotionElement(elm1).motionManager.stop();
				}
				
				for(var tm1:* in _timers)
				{
					if(tm1 is Timer)
						Timer(tm1).stop();
				}
			}
		}
		
		public function pushTimer(t:Timer):void
		{
			_timers[t] = true;
		}
		
		public function popTimer(t:Timer):void
		{
			try
			{
				delete _timers[t];
				t.stop();
			}
			catch(error:Error)
			{
				
			}
		}
		
		public function clearTimer():void
		{
			for(var t:* in _timers)
			{
				try
				{
					delete _timers[t];
					t['stop']();
				}
				catch(error:Error)
				{
					
				}
			}
		}
		
		public function pushEl(m:IMotionElement):void
		{
			_elements[m] = true;
		}
		
		public function popEl(m:IMotionElement):void
		{
			try
			{
				delete _elements[m];
				m.motionManager.stop();
				m['remove']();
			}
			catch(error:Error)
			{
				
			}
		}
		public function clearEl():void
		{
			for(var m:* in _elements)
			{
				try
				{
					delete _elements[m];
					m['motionManager'].stop();
					m['remove']();
				}
				catch(error:Error)
				{
					
				}
			}
		}
		
		public function clearTrigger():void
		{
			
//			(CommentScriptFactory.getInstance().splayer as ScriptPlayer).bilibili::scriptEventManager.removeAll();
		}
		
	}
}