package com.bilibili.player.core.script
{
	import com.bilibili.player.system.proxy.StageProxy;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/** 脚本事件勾子集中管理 **/
	public class ScriptEventManager extends EventDispatcher
	{
		//private var stage:Stage;
		private var hooks:Vector.<Function> = new Vector.<Function>;
		private var hooksUp:Vector.<Function> = new Vector.<Function>;
		/**
		 * @param stage 键盘事件的监听位置
		 **/
		public function ScriptEventManager(/*stage:Stage*/)
		{
			//this.stage = stage;
			
			StageProxy.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			StageProxy.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		/** 将舞台事件发送给hook链 **/
		private function keyDownHandler(event:KeyboardEvent):void
		{
			if(hooks.length)
			{
				var code:uint = event.keyCode;
				if (code == 27 || (code >= 96 && code <= 105) || (code >= 34 && code <= 40)
				|| code == Keyboard.W || code == Keyboard.S || code == Keyboard.A || code == Keyboard.D)
				{
					for each(var f:Function in hooks)
					{
						try
						{
							f(code);
						}
						catch(e:Error)
						{
							trace('KeyTriggerError:' + e.toString());
						}
					}
				}
			}
		}
		/** 将舞台事件发送给hook链 **/
		private function keyUpHandler(event:KeyboardEvent):void
		{
			if(hooksUp.length)
			{
				var code:uint = event.keyCode;
				if (code == 27 || (code >= 96 && code <= 105) || (code >= 34 && code <= 40)
					|| code == Keyboard.W || code == Keyboard.S || code == Keyboard.A || code == Keyboard.D)
				{
					for each(var f:Function in hooksUp)
					{
						try
						{
							f(code);
						}
						catch(e:Error)
						{
							trace('KeyTriggerError:' + e.toString());
						}
					}
				}
			}
		}
		/**
		 * 添加键盘事件处理
		 * @param hook 事件处理函数
		 **/
		public function addKeyboardHook(hook:Function, isUp:Boolean = false):void
		{
			if(isUp)
			{
				hooksUp.push(hook);
			}
			else
			{
				hooks.push(hook);
			}
		}
		
		/**
		 * 移除键盘事件处理
		 * @param hook 事件处理函数
		 **/
		public function removeKeyboardHook(hook:Function, isUp:Boolean = false):void
		{var index:int=0
			if(isUp)
			{
				index = hooksUp.indexOf(hook);
				if(index !== -1)
				{
					hooksUp.splice(index, 1);
				}
			}
			else
			{
				index= hooks.indexOf(hook);
				if(index !== -1)
				{
					hooks.splice(index, 1);
				}
			}
		}
		
		public function removeAll():void
		{
			hooks = new Vector.<Function>;
			hooksUp = new Vector.<Function>;
		}
	}
}