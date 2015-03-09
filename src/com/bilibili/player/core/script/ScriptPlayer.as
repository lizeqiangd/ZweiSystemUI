package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.IScriptConfig;
	import com.bilibili.player.core.script.interfaces.IScriptPlayer;
	import com.bilibili.player.core.script.interfaces.IScriptSound;
	import com.bilibili.player.events.MediaEvent;
	import com.bilibili.player.events.PlayerStateEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.namespaces.bilibili;
	
	import flash.display.DisplayObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	//import tv.bilibili.script.interfaces.IScriptConfig;
	//import tv.bilibili.script.interfaces.IScriptPlayer;
	//import tv.bilibili.script.interfaces.IScriptSound;
	
	public final class ScriptPlayer implements IScriptPlayer
	{
		/** JW播放器 **/
		//protected var _player:IPlayer;
		/** 记录播放器的状态 **/
		protected var _state:String;
		/** 记录播放器的时间/s **/
		protected var _time:Number;
		/** 播放器控制配置 **/
		protected var _config:IScriptConfig;
		/** 脚本勾子 **/
		bilibili var scriptEventManager:ScriptEventManager; 
		
		public function ScriptPlayer(/*player:IPlayer,*/ scriptConfig:IScriptConfig)
		{
			/*_player = player;*/
			_state = 'pause';
			_time = 0;
			_config = scriptConfig;
			
			bilibili::scriptEventManager = new ScriptEventManager(/*_player['stage']*/);

			ValueObjectManager.getMediaProvider.addEventListener(PlayerStateEvent.PLAYER_STATE, stateHandler);
			ValueObjectManager.getMediaProvider.addEventListener(MediaEvent.MEDIA_COMPLETE, completeHandler);
			ValueObjectManager.getMediaProvider.addEventListener(MediaEvent.MEDIA_TIME, timeHandler);
		}
		
		public function play():void
		{
			if(!_config.isPlayerControlApiEnable)
				return;
			ValueObjectManager.getMediaProvider.play()
			//_player.play();
		}
		
		public function pause():void
		{
			if(!_config.isPlayerControlApiEnable)
				return;
			
			ValueObjectManager.getMediaProvider.pause();
			//_player.pause();
		}
		
		public function seek(offset:Number):void
		{
			if(!_config.isPlayerControlApiEnable)
				return;
			
			ValueObjectManager.getMediaProvider.seek(offset / 1000);
			//_player.seek(offset / 1000);
		}
		
		public function jump(av:String, page:int=1, newWindow:Boolean=false):void
		{
			if(!_config.isPlayerControlApiEnable)
				return;
			
			var url:String = BPSetting.HOST+"/video/" + av + "/" + (page && page != 1 ? "index_" + page + ".html" : "");
			navigateToURL(new URLRequest(url), (newWindow ? "_blank" : "_self"));
		}
		
		public function get state():String
		{
			return _state;
		}
		
		public function get time():Number
		{
			return _time * 1000;
		}
		
		public function commentTrigger(func:Function, timeout:Number=1000):uint
		{
			if(!_config.isPlayerControlApiEnable)
				return 0;
			
			_config.commentTriggerManager.addTrigger(func);
			var timer:uint = setTimeout(function ():void
			{
				clearTimeout(timer);
				_config.commentTriggerManager.removeTrigger(func);
			}, timeout);
			
			return timer;
		}
		
		public function keyTrigger(func:Function, timeout:Number=1000, isUp:Boolean=false):uint
		{
			if(!_config.isPlayerControlApiEnable)
				return 0;
			
			bilibili::scriptEventManager.addKeyboardHook(func, isUp);
			var timer:uint = setTimeout(function():void
			{
				clearTimeout(timer);
				bilibili::scriptEventManager.removeKeyboardHook(func, isUp);
			},timeout);
			
			return timer;
		}
		
		public function setMask(mask:DisplayObject):void
		{
			if(!_config.isPlayerControlApiEnable)
				return;
			//遮罩功能似乎完全无用,这里请注意
			trace("setMask failed")
//			var p:DisplayObject = _player['parent'];
//			p.mask = mask;
		}
		
		public function createSound(t:String, onLoad:Function=null):IScriptSound
		{
			if(!_config.isPlayerControlApiEnable)
				return null;
			
			var s:IScriptSound = new ScriptSound(t, onLoad);
			return s;
		}
		
		public function get commentList():Array
		{
			if(!_config.isPlayerControlApiEnable)
				return [];
			
			/** 不引入CommentView, ArrayCollection依赖 **/
			return _config.commentList;
		}
		
		public function get refreshRate():int
		{
			return 0;
		}
		
		public function set refreshRate(value:int):void
		{
		}

		public function get width():uint
		{
			return ValueObjectManager.getCommentDisplayer.width;
		}
		
		public function get height():uint
		{
			return ValueObjectManager.getCommentDisplayer.height;
		}

		public function get videoWidth():uint
		{
			return ValueObjectManager.getMediaProvider.videoWidth;
		}
		
		public function get videoHeight():uint
		{
			return ValueObjectManager.getMediaProvider.videoHeight;
		}
		
		public function get isContinueMode():Boolean
		{
			return false;
		}
		
		protected function stateHandler(event:PlayerStateEvent):void
		{
			if(event.newstate == PlayerStateEvent.PAUSED)
				_state = 'pause';
			else
				_state = 'playing';
		}
		
		protected function completeHandler(event:MediaEvent):void
		{
			_state = 'stop';
		}
		
		protected function timeHandler(event:MediaEvent):void
		{
			_time = event.position;
		}
		
	}
}