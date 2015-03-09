package com.bilibili.player.core.comments
{
	import com.bilibili.player.core.filter.DensityFilter;
	import com.bilibili.player.core.utils.GeneralFactory;
	import com.bilibili.player.events.CommentDataEvent;
    import flash.display.Sprite;
    
    //import org.lala.event.CommentDataEvent;
    //import org.lala.filter.DensityFilter;
    //import org.lala.utils.GeneralFactory;
    
    /** 滚动字幕管理 **/
    public class ScrollCommentManager extends CommentManager
    {
        public function ScrollCommentManager(clip:Sprite)
        {
            super(clip);
        }
        /**
         * 设置空间管理者
         **/
        override protected function setSpaceManager():void
        {
            this.space_manager = CommentSpaceManager(new ScrollCommentSpaceManager());
			this.commentFactory = new GeneralFactory(ScrollComment, 40, 20);
        }
        /**
         * 设置要监听的模式
         **/
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.FLOW_RIGHT_TO_LEFT);
        }
        /**
         * 获取弹幕对象
         * @param	data 弹幕数据
         * @return 弹幕呈现方法对象
         */
        override protected function getComment(data:Object):IComment
        {
			var cmt:ScrollComment = commentFactory.getObject() as ScrollComment;
			cmt.initialize(data as CommentData);
			return cmt;
        }
		/**
		 * 空间回收
		 **/
		override protected function removeFromSpace(cmt:IComment):void
		{
			this.space_manager.remove(Comment(cmt));
			commentFactory.putObject(cmt);
		}
		/**
		 * 只有滚动弹幕才有密度限制
		 **/
		override protected function validate(data:Object):Boolean
		{
			// TODO Auto Generated method stub
			if(super.validate(data) === false)
			{
				return false;
			}
			/** 附加判定 **/
			/** 最大数量控制(包括逆向滚动弹幕,但计数是独立的) **/
			if(!config.densityControl && config.density != 0 && this.liveTotal >= config.density)
			{
				return false;
			}
			else if(config.densityControl)
			{
				return DensityFilter.getInstance().validateLive(data as CommentData);
			}
			return true;
		}
		
	}
}