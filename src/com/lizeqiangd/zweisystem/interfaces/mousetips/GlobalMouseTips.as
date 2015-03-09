package com.lizeqiangd.zweisystem.interfaces.mousetips
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.Timer;
	
	/**
	 * 鼠标悬浮提示框控制
	 * 全舞台只有一个悬浮框因此使用这个方法即可.
	 * 使用前需要初始化,以保证不初始化不会占用内存.
	 * 本类可以控制为 非动画模式,需要注释掉整个tweenlite和响应的方法.
	 * 已经删除tweenlite
	 * 
	 * @author Lizeqiangd
	 * 2015.01.12 添加工具,增加动画模式
	 * 2015.03.06 移除所有依赖库,可独立使用,删除tweenlite依赖
	 */
	public class GlobalMouseTips
	{
		private static var _stage:Stage
		private static var mt:mt_general
		private static var isinited:Boolean = false
		private static var hideTimer:Timer
		//private static var hideAnime:TweenLite
		/**
		 * 初始化本功能
		 */
		public static function init(s:Stage):void
		{
			if (isinited)
			{
				//trace('GloablMouseTips:already inited')
				return
			}
			_stage=s
			isinited=true
			mt = new mt_general
			_stage.addChild(mt)
			
			mt.visible = false
			hideTimer = new Timer(3000, 1)
			hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onHideTimerComplete)
			
			_stage.addEventListener(Event.ADDED,onSomethingAddToStage)
		}
		
		/**
		 * 重新恢复至舞台顶层
		 * @param	e
		 */
		static private function onSomethingAddToStage(e:Event):void 
		{
			//_stage.setChildIndex(mt, _stage.numChildren -1);
		}
		
		/**
		 * 直接设置信息
		 * @param	text 内容文字
		 * @param	x 舞台的x
		 * @param	y 舞台的y
		 * @param	autoFixPosition 是否自动修正x坐标以防超出舞台
		 */
		public static function setTips(text:String, x:Number, y:Number, autoFixPosition:Boolean = false):void
		{
			if (!isinited)
			{
				//trace('GloablMouseTips:need init')
				return
			}
			mt.text = text;
			var mt_y:Number =y
			var mt_x:Number = x 
			if (autoFixPosition)
			{
				mt_x = mt_x > _stage.stageWidth - mt.width ? _stage.stageWidth - mt.width - 5 : mt_x
				mt_x = mt_x < 0 ? 0 : mt_x
			}
			mt.alpha = 1
			mt.visible = true
			
			mt.x = mt_x
			mt.y = mt_y
			hideTimer.reset()
			hideTimer.start()
			//trace(text, 'd tips on');
		}
		
		/**
		 * 根据物件直接提示,会自动寻找10层嵌套直到舞台.用来确定显示对象是舞台上的.
		 * 使用后可以根据情况调用取消显示方法.
		 * 同时
		 * @param	text 内容文字.
		 * @param	display 需要附着的对象.
		 */
		public static function setTipsByDisplayObject(text:String, display:DisplayObject):void
		{
			if (!isinited)
			{
				//trace('GloablMouseTips:need init')
				return
			}
			mt.text = text
			var mt_y:Number = (display.y + display.height + 2)
			var mt_x:Number = display.x + display.height / 2 - mt.width / 2
			var temp_display:DisplayObject = display.parent
			//最多10层嵌套
			for (var i:int = 0; i < 10; i++)
			{
				if (temp_display != _stage)
				{
					mt_y += temp_display.y
					mt_x += temp_display.x
					temp_display = temp_display.parent
				}
			}
			
			mt_y = mt_y > _stage.stageHeight + mt.height ? display.y - 2 - mt.height : mt_y
			mt_x = mt_x > _stage.stageWidth - mt.width ? _stage.stageWidth - mt.width - 5 : mt_x
			mt_x = mt_x < 0 ? 0 : mt_x
			
			mt.alpha = 1
			mt.visible = true
			
			mt.x = mt_x
			mt.y = mt_y
			hideTimer.reset()
			hideTimer.start()
			//trace(text, 'tips on');
		}
		
		/**
		 * 隐藏提示,当鼠标移开的时候可以调用.
		 */
		public static function hideTips():void
		{
			if (!isinited)
			{
				//trace('GloablMouseTips:need init')
				return
			}
			//TweenLite.to(mt, 0.5, {autoAlpha: 0})
			//mt.visible = false
			var timer_int:uint = setInterval(function():void {
				mt.alpha -= 0.2;
				if (mt.alpha <= 0) {
					mt.visible = false;
					clearInterval(timer_int);
				}
			},100)
			hideTimer.stop()
		}
		
		static private function onHideTimerComplete(e:TimerEvent):void
		{
			mt.visible = false
		}
	}

}