package com.bilibili.player.core.comments
{
	import com.bilibili.player.core.utils.GeneralFactory;
	import com.bilibili.player.events.CommentDataEvent;
    import flash.display.Sprite;
    //
    //import org.lala.event.CommentDataEvent;
    //import org.lala.utils.GeneralFactory;

    /** bili的新类型弹幕管理者,比较简单 **/
    public class FixedPosCommentManager extends CommentManager
    {
		protected var Width:Number = 0;
		protected var Height:Number = 0;
        public function FixedPosCommentManager(clip:Sprite)
        {
            super(clip);
        }
        override protected function setSpaceManager():void
        {
            commentFactory = new GeneralFactory(FixedPosComment, 0, 20);
        }
		/**
		 * 记录总体大小,用于计算百分比
		 **/
        override public function resize(width:Number, height:Number):void
        {
            this.Width = width;
			this.Height = height;
        }
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.FIXED_POSITION_AND_FADE);
        }
        override protected function add2Space(cmt:IComment):void
        {
            /** 置空 **/
        }
        override protected function removeFromSpace(cmt:IComment):void
        {
            commentFactory.putObject(cmt);
        }
        override protected function getComment(data:Object):IComment
        {
			var cmt:FixedPosComment = commentFactory.getObject() as FixedPosComment;
            cmt.initialize2(data as CommentDataMode7, Width, Height);
			return cmt;
        }
    }
}