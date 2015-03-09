package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.IScriptUtils;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	//import tv.bilibili.script.interfaces.IScriptUtils;
	
	public class ScriptUtils implements IScriptUtils
	{
		/** 脚本资源管理 **/
		protected var _scriptManager:ScriptManager;
		
		public function ScriptUtils(manager:ScriptManager)
		{
			_scriptManager = manager;
		}
		
		public function hue(v:int):int
		{
			var r:Array = [0,120,240];
			var g:Array = [124,240,360];
			var b:Array = [240,360,480];
			
			var rp:Number = 0;
			var gp:Number = 0;
			var bp:Number = 0;
			v = v % 360;
			
			if(v > r[0] && v < r[2])
			{
				rp = 100 - 50 * Math.abs(v - r[1]) / 120; 
			}
			
			if(v > g[0] && v < g[2])
			{
				gp = 100 - 50 * Math.abs(v - g[1]) / 120; 
			}
			
			if(v > b[0] && v <= b[1]) 
			{
				bp = 100 - 50 * Math.abs(v - b[1]) / 120; 
			}
			else if(v + 360 >= b[1] && v + 360 < b[2])
			{
				bp = 100 - 50 * Math.abs(v + 360 - b[1]) / 120; 
			}
			
			return int(rp * 0xff / 100) << 16 | int(gp * 0xff / 100) << 8 | int(bp * 0xff / 100);
		}
		
		public function rgb(r:int, g:int, b:int):int
		{
			return (r << 16) | (g << 8) | b;
		}
		
		public function formatTimes(time:Number):String
		{
			if(time < 0)
				return '-' + formatTimes(- time);
			
			var sec:uint = Math.floor(time % 60);
			var min:uint = Math.floor(time / 60);
			
			return (min < 10 ? '0' : '') + min.toString() + ':' + ('0' + sec.toString()).substr(-2, 2);
		}
		
		public function delay(f:Function, time:Number=1000):uint
		{
			if(time < 1)
				time = 1;
			
			var t:uint = setTimeout(function():void
			{
				f();
				clearTimeout(t);
			}, time);
			return t;
		}
		
		public function interval(f:Function, time:Number=1000, times:uint=1):Timer
		{
			var timer:Timer = new Timer(time, times);
			function timerHandler(event:TimerEvent):void
			{
				f();
			};
			function completeHandler(event:TimerEvent):void
			{
				/** 从时间管理器上移除时间柄 **/
				_scriptManager.popTimer(timer);
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, completeHandler);
			};
			/** 在时间管理器上添加时间柄 **/
			_scriptManager.pushTimer(timer);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, completeHandler);
			timer.start();
			return timer;
		}
		
		public function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		}
		
		public function rand(min:Number, max:Number):Number
		{
			return Math.floor(min + Math.random() * (max - min));
		}
		
		public function clone(object:*):*
		{
			var qClassName:String = getQualifiedClassName(object);
			var objectType:Class = getDefinitionByName(qClassName) as Class;
			registerClassAlias(qClassName, objectType);    //已AMF对一个对象进行编码时，保留该对象的类（类型）。
			
			var copier:ByteArray = new ByteArray();            
			copier.writeObject(object);
			copier.position = 0;
			return copier.readObject();
		}
		
		public function foreach(iter:Object, func:Function):void
		{
			for(var str:String in iter)
			{
				func.call(null, str, iter[str]);
			}
		}
	}
}