package com.bilibili.player.core.comments
{
	import com.bilibili.player.core.utils.Tween;
	import flash.events.Event;
	
	//import org.lala.utils.Tween;

    /** 滚动字幕类 **/
    public class ScrollComment extends Comment
    {
        /** 动画对象 **/
        protected var _tw:Tween;
        /** 滚动时间 **/
        protected var _dur:Number;
        /** 构造函数 **/
        public function ScrollComment()
        {
			this._tw = new Tween();
			return;
        }
		/**
		 * 数据填充
		 **/
		override public function initialize(data:CommentData):void
		{
			item = data;
			init();
		}
        /** 设置持续时间,在滚动空间管理类中设置 **/
        public function set duration(dur:Number):void
        {
            this._dur = dur;
        }
        /**
         * 开始播放
         * 从当前位置(已经在滚动空间管理类中设置)滚动到-this.width
         */
        override public function start():void
        {
            _tw.initialize(this, 'x', x, -width, _dur);
            _tw.addEventListener(Event.COMPLETE, completeHandler);
            _tw.start();
        }
        /**
         * 结束事件监听
         */
        protected function completeHandler(event:Event):void
        {
			_tw.removeEventListener(Event.COMPLETE, completeHandler);
            _complete();
        }
        /**
         * 恢复播放
         */
        override public function resume():void
        {
            _tw.resume();
        }
        /**
         * 暂停
         */
        override public function pause():void
        {
			_tw.pause();
        }
		
		/**
		 * 提前结束
		 **/
		override public function stop():void
		{
			_tw.stop();
			completeHandler(null);
		}

    }
}