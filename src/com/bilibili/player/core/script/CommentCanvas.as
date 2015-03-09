package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.ICommentCanvas;
	import com.bilibili.player.core.script.interfaces.IMotionManager;
	import flash.display.Sprite;
	
	//import tv.bilibili.script.interfaces.ICommentCanvas;
	//import tv.bilibili.script.interfaces.IMotionManager;
	
	public class CommentCanvas extends Sprite implements ICommentCanvas
	{
		protected var _motionManager:IMotionManager;
		
		public function CommentCanvas()
		{
			super();
			_motionManager = new MotionManager(this);
		}
		
		public function get motionManager():IMotionManager
		{
			return _motionManager;
		}
		
		public function initStyle(config:Object):void
		{
			this.x = config.x;
			this.y = config.y;
			this.z = config.z;
			this.alpha = config.alpha;
			this.scaleX = this.scaleY = config.scale;
			
			this.mouseEnabled = false;
		}
		
		public function remove():void
		{
			try
			{
				_motionManager.stop();
				this.parent.removeChild(this);
			}
			catch(error:Error)
			{
			}
		}
	}
}