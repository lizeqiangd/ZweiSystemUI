package com.bilibili.player.manager
{
	import com.bilibili.player.applications.StageAnimation.StageMask;
	import com.bilibili.player.components.PositionUtility;
	import com.bilibili.player.events.AnimationEvent;
	import com.bilibili.player.system.config.BPSetting;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	/**
	 * @author Lizeqiangd
	 * AnimationManager是一个动画管理器，用于简单的淡入淡出动画，和管理应用程序开启动画。
	 * 同时他还可以进行简单的变色动画。当然很方便进行扩展，最重要的是他可以轻松回馈动画事件AnimationEvent
	 * 2013.02.10 集合StageMask到AnimationManager管理。
	 * 2013.06.29 修改动画时间为0.8秒，提高整个系统的体验效果
	 * 2014.04.05 重新审查.
	 */
	public class AnimationManager
	{
		private static const animeTime:Number = BPSetting.AnimationManagerDefaultTime
		private static const scale:Number = 0.5;
		private static var stagemask:StageMask
		private static var inited:Boolean = false
		
		/**
		 * 初始化方法.通过AddOnManager激活所有Tween动画插件,同时激活文字特效.并且建立stagemask应用.
		 */
		public static function init():void
		{
			if (inited)
			{
				return
			}
			inited = true
			//AddOnManager.initTweenPlugin()
			//AddOnManager.initTextAnimation()
			//重新考虑全局遮罩使用范围.
			//stagemask = LayerManager.createPopUp(StageMask)
		}
		
		/**
		 * 遮罩全舞台,只保留TopLayer能使用,默认是0.6的alpha,如果为0则取消遮罩
		 * @param	value
		 */
		public static function MaskInStage(value:Number = 0.6):void
		{
			if (value > 0)
			{
				TweenLite.to(stagemask, animeTime, {autoAlpha: value/*onUpdate :function, overwrite: 3 , onStart: dispatchEventStart, onStartParams: [stagemask], onComplete: dispatchEventComplete, onCompleteParams: [stagemask]*/});
			}
			else
			{
				AnimationManager.MaskOutStage()
			}
		}
		
		/**
		 * 取消舞台遮罩.
		 */
		public static function MaskOutStage():void
		{
			TweenLite.to(stagemask, animeTime, {autoAlpha: 0/*, overwrite: 3 , onStart: dispatchEventStart, onStartParams: [stagemask], onComplete: dispatchEventComplete, onCompleteParams: [stagemask]*/});
		}
		
		/**
		 * 简易方法调用DisplayObject从alpha0到1
		 * @param	o
		 */
		public static function fade_in(o:*):void
		{
			if (o.alpha == 1 && o.visible == true)
			{
				return
			}
			//DisplayObject(o).alpha = 0;
			TweenLite.to(DisplayObject(o), animeTime, {autoAlpha: 1/*, overwrite: 3, onStart: dispatchEventStart, onStartParams: [o], onComplete: dispatchEventComplete, onCompleteParams: [o]*/});
		}
		
		/**
		 * 简易方法调用DisplayObject从alpha1到0 ,如果元件本身就是alpha为0则将其visible设为true.然后返回.
		 * @param	o
		 */
		public static function fade_out(o:*):void
		{
			if (o.alpha == 0)
			{
				o.visible = false
			}
			if (!o.visible)
			{
				return
			}
			//DisplayObject(o).alpha = 1;
			TweenLite.to(DisplayObject(o), animeTime, {autoAlpha: 0/*, overwrite: 3, onStart: dispatchEventStart, onStartParams: [o], onComplete: dispatchEventComplete, onCompleteParams: [o]*/});
		}
		
		/**
		 * 简易方法调用DisplayObject的alpha,同时时间可以自定义并且alpha为0时visible=false
		 * @param	o
		 */
		public static function fade(o:*, n:Number = 0, time:Number = 0):void
		{
			//time == 0 ? time = animeTime : time
			TweenLite.to(DisplayObject(o), time, {autoAlpha: n/*, overwrite: 3, onStart: dispatchEventStart, onStartParams: [o], onComplete: dispatchEventComplete, onCompleteParams: [o]*/});
		}
		
		/**
		 * 切换DisplayObject颜色
		 * 默认属性 blue lightblue red orange white
		 * @param	o
		 * @param	n 颜色的名字或者unit
		 * @param	immediately 是否需要等待时间,可以用于立刻变色.
		 */
		public static function changeColor(o:DisplayObject, n:*, immediately:Boolean = false):void
		{
			var color:uint = 0
			switch (n)
			{
				case "blue": 
					color = 0x0033ff
					break;
				case "lightblue": 
					color = 0x3399ff
					break;
				case "orange": 
					color = 0xff9900
					break;
				case "red": 
					color = 0xff0000
					break;
				case "white": 
					color = 0xFFFFFF
					break;
				default: 
					color = uint(n)
					break;
			}
			if (immediately)
			{
				var ct:ColorTransform = new ColorTransform();
				ct.color = n
				o.transform.colorTransform = ct
			}
			else
			{
				var obj:Object = {tint: color, overwrite: 3, onStart: dispatchEventStart, onStartParams: [o], onComplete: dispatchEventComplete, onCompleteParams: [o]}
				TweenLite.to(DisplayObject(o), animeTime, obj);
			}
		}
		
		/**
		 * 激活一个DisplayObject的开启动画效果.(一般用于应用).
		 * 默认设置有popup fade_in left
		 * @param	o
		 * @param	type  显示的方法.
		 */
		public static function open(o:DisplayObject, type:String = ""):void
		{
			var obj:Object = {overwrite: 3, onStart: dispatchEventStart, onStartParams: [o], onComplete: dispatchEventOpened, onCompleteParams: [o]}
			switch (type)
			{
				case "popup": 
					o.alpha = 1;
					o.visible = true;
					obj.alpha=0.6
					obj.transformAroundCenter = {scaleX: 0.5, scaleY: 0.5}
					obj.ease = Elastic.easeOut
					TweenLite.from(o, 1, obj);
					break;
				case "scale_fade_in": 
					obj.autoAlpha = 0
					obj.transformAroundCenter = {scaleX: 2, scaleY: 2}
					TweenLite.from(o, animeTime, obj);
					break;
				case "fade_in": 
					o.alpha = 0;
					obj.autoAlpha = 1
					TweenLite.to(o, animeTime, obj);
					break;
				case "left": 
					obj.autoAlpha = 0.5
					obj.ease = Elastic.easeOut
					obj.x = PositionUtility.boundsRight
					TweenLite.from(o, animeTime, obj);
					break;
				default: 
					trace("AnimationManager.open找不到开启动画type：", type, o)
					break;
			
			}
		}
		
		/**
		 * 激活一个DisplayObject的关闭动画效果.(一般用于应用).
		 * 默认设置有 fade_out_and_blur fade_out left
		 * @param	o
		 * @param	type  显示的方法.
		 */
		public static function close(o:DisplayObject, type:String = ""):void
		{
			var obj:Object = {overwrite: 3, onStart: dispatchEventStart, onStartParams: [o], onComplete: dispatchEventClosed, onCompleteParams: [o]}
			switch (type)
			{
				case "fade_out_and_blur": 
					obj.autoAlpha = 0
					obj.blurFilter = {blurX: 20, blurY: 20}
					TweenLite.to(o, animeTime, obj);
					break;
				case "left": 
					break;
				case "fade_out": 
					obj.autoAlpha = 0
					TweenLite.to(o, animeTime, obj);
					break;
				default: 
					obj.autoAlpha = 0
					obj.blurFilter = {blurX: 20, blurY: 20}
					trace("AnimationManager.close找不到关闭动画type：", type, o, " 采取默认方式执行.")
					try
					{
						TweenLite.to(o, animeTime, obj);
					}
					catch (e:*)
					{
						
					}
					break;
			}
		}
		
	
		///抛出事件:OPENED
		private static function dispatchEventOpened(o:DisplayObject):void
		{
			o.dispatchEvent(new AnimationEvent(AnimationEvent.OPENED));
		}
		
		///抛出事件:START
		private static function dispatchEventStart(o:DisplayObject):void
		{
			o.dispatchEvent(new AnimationEvent(AnimationEvent.START));
		}
		
		///抛出事件:PLAYING
		private static function dispatchEventPlaying(o:DisplayObject):void
		{
			o.dispatchEvent(new AnimationEvent(AnimationEvent.PLAYING));
		}
		
		///抛出事件:COMPLETE
		private static function dispatchEventComplete(o:DisplayObject):void
		{
			o.dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE));
		}
		
		///抛出事件:Repeat
		private static function dispatchEventRepeat(o:DisplayObject):void
		{
			o.dispatchEvent(new AnimationEvent(AnimationEvent.Repeat));
		}
		
		///抛出事件:CLOSED
		private static function dispatchEventClosed(o:DisplayObject):void
		{
			o.dispatchEvent(new AnimationEvent(AnimationEvent.CLOSED));
		}
	}
}