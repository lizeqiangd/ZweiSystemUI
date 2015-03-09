package com.bilibili.player.core.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	/** 动画完毕 **/
	
	[Event(name="complete", type="flash.events.Event")]
	public class Tween extends EventDispatcher
	{
		private static var _FPS:uint = 60;
		protected static var Tweens:Link = new Link();
		protected static var timer:Timer;

		public static function get FPS():uint
		{
			return _FPS;
		}

		public static function set FPS(value:uint):void
		{
			if(_FPS != value)
			{
				_FPS = Math.max(12, value);
				_FPS = Math.min(value, 60);
				initail();
			}
		}

		protected static function initail():void
		{
			if(timer)
			{
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
			}
			timer = new Timer(1000 / FPS);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}
		
		protected static function timerHandler(event:TimerEvent):void
		{
			var time:int = getTimer();
			
			/** 经过一轮更新,是否具有没有暂停的动画 **/
			var hasPlaying:Boolean = false;
			
			var node:Node = Tweens.first;
			var next:Node;
			while(node !== null)
			{
				var tw:Tween = node.data as Tween;
				tw.update(time);
				
				if(!hasPlaying && !tw.paused)
					hasPlaying = true;
				
				next = node.next;
				if(tw.stopFlag)
				{
					Tweens.removeNode(node);
				}
				node = next;
			}
			
			if(hasPlaying)
				event.updateAfterEvent();
		}
		initail();
		
		protected static function isLive(tw:Tween, i:uint, parent:Vector.<Tween>):Boolean
		{
			return !tw.stopFlag;
		}
		
		private var _target:Object;
		private var _property:String;
		private var _from:Number;
		private var _to:Number;
		private var _dur:int;
		
		private var _start:int;
		private var _timePaused:int;
		
		private var _paused:Boolean = true;
		
		public var stopFlag:Boolean = false;
		
		public function Tween(){};
		
		public function initialize(target:Object
							, property:String
							, from:Number
						    , to:Number
							, duration:Number):void
		{
			_target = target;
			_property = property;
			_from = from;
			_to = to;
			_dur = duration * 1000;
			
			_paused = true;
			stopFlag = false;
		}
		
		public function start():void
		{
			paused = false;
			_start = getTimer();
			Tweens.append(this);
		}
		
		public function update(time:int):void
		{
			if(_paused)
				return;
			
			var delt:int = time - _start; 
			if(delt > _dur)
			{
				stopFlag = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				var per:Number = delt / _dur;
				/** 线性插值 **/
				_target[_property] = _from * (1 - per) + _to * per;
			}
		}
		
		public function pause():void
		{
			if(!paused)
			{
				_timePaused = getTimer();
				paused = true;
			}
		}
		
		public function resume():void
		{
			if(paused)
			{
				_start += getTimer() - _timePaused;
				paused = false;
			}
		}

		public function get paused():Boolean
		{
			return _paused;
		}

		public function set paused(value:Boolean):void
		{
			_paused = value;
		}
		
		public function stop():void
		{
			stopFlag = true;
		}
	}
}
