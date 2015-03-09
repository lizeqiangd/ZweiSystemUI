package com.bilibili.player.core.comments
{
	import com.bilibili.player.core.utils.GeneralFactory;
	import com.bilibili.player.events.CommentDataEvent;
    import flash.display.Sprite;
    
    //import org.lala.event.*;
    //import org.lala.net.*;
    //import org.lala.utils.*;
	
    /** 反向滚动弹幕 **/
    public class RScrollCommentManager extends ScrollCommentManager
    {
        public function RScrollCommentManager(clip:Sprite)
        {
            super(clip);
        }
		/**
		 * 设置空间管理者
		 **/
		override protected function setSpaceManager():void
		{
			this.space_manager = CommentSpaceManager(new ScrollCommentSpaceManager());
			this.commentFactory = new GeneralFactory(RScrollComment, 0, 20);
		}
        /**
         * 设置要监听的模式
         **/
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.FLOW_LEFT_TO_RIGHT);
        }
        /**
         * 获取弹幕对象
         * @param	data 弹幕数据
         * @return 弹幕呈现方法对象
         */
        override protected function getComment(data:Object):IComment
        {
			var cmt:RScrollComment = commentFactory.getObject() as RScrollComment;
			cmt.initialize(data as CommentData);
            return cmt;
        }
    }
}