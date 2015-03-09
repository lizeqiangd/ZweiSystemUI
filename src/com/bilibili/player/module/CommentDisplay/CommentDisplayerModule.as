package com.bilibili.player.module.CommentDisplay
{
	import com.bilibili.player.abstract.module.BaseModule;
	import com.bilibili.player.abstract.module.iModule;
	import com.bilibili.player.core.comments.CommentDisplayer;
	import com.bilibili.player.core.comments.CommentPlayer;
	import com.bilibili.player.core.script.NoParentSprite;
	import com.bilibili.player.manager.ModuleManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.proxy.StageProxy;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * 本类需要MediaProvider依赖.因此他需要先初始化MediaProvider
	 * 换句话说本Module需要在VideoModule后初始化.
	 * @author Lizeqiangd
	 * 20141204 增加接入
	 * 20141209 放弃本类...似乎毫无疑义 接入视频播放里面吧.
	 */
	public class CommentDisplayerModule extends BaseModule implements iModule
	{
		/**
		 * 弹幕层
		 */
		private var cl:Sprite
		private var scl:NoParentSprite
		/**
		 * 应用:弹幕显示
		 */
		private var cd:CommentDisplayer
		/**
		 * 弹幕引擎
		 */
		private var cp:CommentPlayer
		
		public function CommentDisplayerModule()
		{
			this.setModuleName = "CommentDisplayer"
		}
		
		public function init():void
		{
			scl = new NoParentSprite
			cl = new Sprite
			
			cd = ValueObjectManager.getCommentDisplayer
			cd.init(cl, scl)
			scl.x = 0
			cl.x = 0
			ModuleManager.addToLayer(cl, "background")
			ModuleManager.addToLayer(scl, "background")
			
			StageProxy.addResizeFunction(onStageResize)
		}
		
		private function onStageResize():void
		{
			var dz:Rectangle = ModuleManager.getModule("VideoDisplay").getDisplayZone
			cl.x = dz.x
			cl.y = dz.y
			cl.width = dz.width
			cl.height = dz.height
			
			scl.x = dz.x
			scl.y = dz.y
			scl.width = dz.width
			scl.height = dz.height
		}
	
	}

}