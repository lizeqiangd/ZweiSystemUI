package com.bilibili.player.core.comments
{
	public class CommentDataMode7 extends CommentData
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var rZ:Number = 0;
		public var rY:Number = 0;

		public var adv:Boolean = false;
		public var toX:Number = 0;
		public var toY:Number = 0;
		public var mDuration:Number = 0;
		public var delay:Number = 0;
		public var borderStyle:Boolean = true;
		public var fontFamily:String = "黑体";
		public var isAccelerated:Boolean = false;
		
		public var duration:Number = 2.5;
		public var inAlpha:Number = 1;
		public var outAlpha:Number = 1;
		
		/**
		 * 路径数据: 格式为 Mx1,y1Lx2,y2Lx3,y3 ML语法借鉴flex的path,目前只支持解析直线，格式可能在之后的版本扩展
		 */
		public var motionPath:String = null;
		
		public function CommentDataMode7(obj:Object=null)
		{
			super(obj);
		}
	}
}