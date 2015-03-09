package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.IScriptSound;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	//import tv.bilibili.script.interfaces.IScriptSound;
	
	public class ScriptSound implements IScriptSound
	{
		protected var _sound:Sound;
		
		/**
		 * @param name 声音名称
		 * @param onLoad 加载完毕后执行
		 **/
		public function ScriptSound(name:String, onLoad:Function=null)
		{
			var url:String = "http://i2.hdslb.com/soundlib/" + name + ".mp3";
			_sound = new Sound();
			_sound.load(new URLRequest(url));
			
			if(onLoad != null)
			{
				_sound.addEventListener(Event.OPEN, function (event:Event):void
				{
					onLoad();
				});
			}
		}
		
		public function loadPercent():uint
		{
			return Math.floor(100 * _sound.bytesLoaded / _sound.bytesTotal);
		}
		
		public function play(startTime:Number=0, loops:int=0):void
		{
			_sound.play(startTime, loops);
		}
		
		public function stop():void
		{
		}
		
		public function remove():void
		{
			_sound.close();
		}
	}
}