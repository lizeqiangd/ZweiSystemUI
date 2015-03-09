package com.bilibili.player.manager
{
	
	/**
	 * 负责激活外部插件。
	 * @author Lizeqiangd
	 * 2014.04.02 增加全部
	 */
	
	import com.bilibili.player.module.CommentSender.StandardCommentSenderModule
	import com.bilibili.player.components.texteffect.TextAnimation;
	import com.greensock.plugins.*;
	import com.greensock.loading.*;
	
	public class AddOnManager
	{
		
		/**
		 * 激活GreenSock的全部动画
		 */
		public static function initTweenPlugin():void
		{
			TweenPlugin.activate([AutoAlphaPlugin, TintPlugin, BlurFilterPlugin, MotionBlurPlugin, GlowFilterPlugin, EndArrayPlugin]);
			TweenPlugin.activate([TransformAroundCenterPlugin, ShortRotationPlugin, TransformAroundPointPlugin]);
			//	Cc.debug("TweenPlugin activated:AutoAlphaPlugin, TintPlugin, BlurFilterPlugin, MotionBlurPlugin, GlowFilterPlugin, EndArrayPlugin");
			//	Cc.debug("TweenPlugin activated:TransformAroundCenterPlugin, ShortRotationPlugin, TransformAroundPointPlugin");
		}
		
		/**
		 * 激活文字动画效果
		 */
		public static function initTextAnimation():void
		{
			TextAnimation.init()
		}
	}
}