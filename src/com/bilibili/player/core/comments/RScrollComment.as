package com.bilibili.player.core.comments
{
	import com.bilibili.player.core.utils.Tween;
	import flash.events.Event;
	
	//import org.lala.utils.Tween;

    /** 反向滚动弹幕 **/
    public class RScrollComment extends ScrollComment
    {
        public function RScrollComment()
        {
			return;
        }
        /**
         * 开始播放
         * 从当前位置(已经在滚动空间管理类中设置)滚动到-this.width
         */
        override public function start():void
        {
			_tw.initialize(this, 'x', -width, x, _dur);
			_tw.addEventListener(Event.COMPLETE, completeHandler);
			_tw.start();
        }
    }
}