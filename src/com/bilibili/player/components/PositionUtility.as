package com.bilibili.player.components
{
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.proxy.StageProxy
	import flash.display.DisplayObject;
	import flash.display.StageAlign;
	/**
	 * 2014.04.05 没有过多的使用功能,因此转变为一个组件,更新逻辑.
	 */
	public class PositionUtility
	{
		private static const offsetX:int = BPSetting.PositionUtilityOffsetX
		private static const offsetY:int = BPSetting.PositionUtilityOffsetY
		private static var displayObjects:Array;
		private static var isInited:Boolean = false
		
		/**
		 * 如果第一次使用,会初始化在StageProxy中添加onStageResize方法.
		 * 将一个显示对象添加到管理器当中
		 * @param pos_obj 显示对象
		 * @param align_method 对齐的方式
		 */
		public static function addPosObject(pos_obj:DisplayObject, align_method:String):void
		{
			if (!isInited)
			{
				displayObjects = new Array();
				StageProxy.addResizeFunction(onStageResize)
				isInited = true
			}
			var pos_value:Object = new Object();
			pos_value.displayobj = pos_obj;
			pos_value.method = align_method;
			displayObjects.push(pos_value);
			onStageResize()
		}
		
		/**
		 * 将显示对象从管理器移除,如果需要管理的对象数为0从SP中移除
		 * @param p 需要被移除的显示对象
		 */
		public static function removePosObject(p:DisplayObject):void
		{
			for (var i:int = 0; i < displayObjects.length; i++)
			{
				if (displayObjects[i].displayobj == p)
				{
					displayObjects.splice(i, 1);
					break;
				}
				if (displayObjects.length == 0)
				{
					StageProxy.removeResizeFunction(onStageResize)
				}
			}
		}
		
		private static function onStageResize():void
		{
			for (var i:int = 0; i < displayObjects.length; i++)
			{
				setDisplayPosition(displayObjects[i].displayobj, displayObjects[i].method);
			}
		}
		
		/**
		 * 防止应用在窗口变化时出界用的方法
		 * @param display_obj 需要设置的对象
		 */
		public static function setDisplayBackToStage(display_obj:DisplayObject):void
		{
			if (display_obj.x > (StageProxy.stageWidth - 20))
			{
				display_obj.x = StageProxy.stageWidth - 20;
			}
			if (display_obj.y > (StageProxy.stageHeight - 20))
			{
				display_obj.y = StageProxy.stageHeight - 20;
			}
			if (display_obj.x < (20 - display_obj.width))
			{
				display_obj.x = 20 - display_obj.width
			}
			if (display_obj.y < (20 - display_obj.height))
			{
				display_obj.y >= 20 - display_obj.height
			}
		}
		
		/**
		 * 设置显示对象的位置
		 * ↑ ↓ ← →  ↘ ↙ ↖ ↗ 然后就是StageAlign的全部内容.↑↑ TC(在上方正中间)
		 * @param display_obj 需要被设置的对象
		 * @param method 位置的对齐方式
		 */
		public static function setDisplayPosition(display_obj:DisplayObject, method:String = null):void
		{
			switch (method)
			{
				case "↓": 
				case StageAlign.BOTTOM: 
					bottom(display_obj);
					break;
				case "←": 
				case StageAlign.LEFT: 
					left(display_obj);
					break;
				case "→": 
				case StageAlign.RIGHT: 
					right(display_obj);
					break;
				case "↑": 
				case StageAlign.TOP: 
					top(display_obj);
					break;
				case "↑↑": 
				case "TC": 
					widthCenter(display_obj);
					top(display_obj);					
					break;
				case "↓↓": 
				case "BC": 
					widthCenter(display_obj);
					bottom(display_obj);
					break;
				case "↘": 
				case StageAlign.BOTTOM_LEFT: 
					bottom(display_obj);
					left(display_obj);
					break;
				case "↙": 
				case StageAlign.BOTTOM_RIGHT: 
					bottom(display_obj);
					right(display_obj);
					break;
				case "↖": 
				case StageAlign.TOP_LEFT: 
					top(display_obj);
					left(display_obj);
					break;
				case "↗": 
				case StageAlign.TOP_RIGHT: 
					top(display_obj);
					right(display_obj);
					break;
				default: 
					center(display_obj);
			}
		}
		
		/**
		 * 将显示对象和舞台底部对齐
		 * @param o 显示对象
		 *
		 */
		public static function bottom(o:*):void
		{
			o.y = int(boundsBottom - o.height)+1;
		}
		
		/**
		 * 将显示对象和舞顶部部对齐
		 * @param o 显示对象
		 *
		 */
		public static function top(o:*):void
		{
			o.y = boundsTop + offsetY;
		}
		
		/**
		 * 将显示对象和舞台左边对齐
		 * @param o 显示对象
		 *
		 */
		public static function left(o:*):void
		{
			o.x = boundsLeft + offsetX;
		}
		
		/**
		 * 将显示对象和舞台右边对齐
		 * @param o 显示对象
		 *
		 */
		public static function right(o:*):void
		{
			o.x = int(boundsRight - o.width);
		}
		
		/**
		 * 将显示对象和舞台居中对齐
		 * @param o 显示对象
		 *
		 */
		public static function center(o:*):void
		{
			widthCenter(o)
			heightCenter(o)
		}
		
		/**
		 * 长居中
		 * @param	o
		 */
		public static function widthCenter(o:*):void
		{
			o.x = int((StageProxy.stageWidth - offsetX) / 2 - o.width / 2) + offsetX;
		}
		
		/**
		 * 高居中
		 * @param	o
		 */
		public static function heightCenter(o:*):void
		{
			o.y = int((StageProxy.stageHeight - offsetY) / 2 - o.height / 2) + offsetY;
		}
		
		/**
		 * 获取左边界的坐标 目前是返回0
		 * @return 坐标值
		 *
		 */
		public static function get boundsLeft():int
		{
			return 0;
		}
		
		/**
		 * 获取右边界的坐标  目前是舞台StageProxy.stageWidth
		 * @return 坐标值
		 *
		 */
		public static function get boundsRight():int
		{
			return StageProxy.stageWidth;
		}
		
		/**
		 * 获取上边界的坐标 目前是0
		 * @return 坐标值
		 *
		 */
		public static function get boundsTop():int
		{
			return 0;
		}
		
		/**
		 * 获取下边界的坐标 目前是StageProxy.stageHeight
		 * @return 坐标值
		 *
		 */
		public static function get boundsBottom():int
		{
			return StageProxy.stageHeight;
		}
	
	}
}