package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.ICommentShape;
	import com.bilibili.player.core.script.interfaces.IMotionManager;
	import flash.display.Shape;
	
	//import tv.bilibili.script.interfaces.ICommentShape;
	//import tv.bilibili.script.interfaces.IMotionManager;
	
	public class CommentShape extends Shape implements ICommentShape
	{
		protected var _motionManager:IMotionManager;
		
		public function CommentShape()
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