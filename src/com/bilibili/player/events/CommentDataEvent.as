package com.bilibili.player.events
{
    import flash.events.Event;
    
    public class CommentDataEvent extends Event
    {
        /** 从右往左的滚动弹幕,值为模式号的字符串 **/
        public static var FLOW_RIGHT_TO_LEFT:String = '1';
        /** 从左往右的滚动弹幕 **/
        public static var FLOW_LEFT_TO_RIGHT:String = '6';
        /** 顶部字幕 **/
        public static var TOP:String = '5';
        /** 底部字幕 **/
        public static var BOTTOM:String = '4';
        /** bilibili新字幕 **/
        public static var FIXED_POSITION_AND_FADE:String = '7';
		/** bilibili的脚本弹幕 **/
		public static var BILIBILI_SCRIPT:String = '8';
        /** 脚本弹幕 **/
        public static var ECMA3_SCRIPT:String = '10';
        
        public static var ZOOME_NORMAL:String = 'normal';//zoome style
        public static var ZOOME_THINK:String = 'think';//zoome style
        public static var ZOOME_LOUD:String = 'loud';//zoome style
        public static var ZOOME_BOTTOM_SUBTITLE:String = 'subtitlebottom';//zoome style
        public static var ZOOME_TOP_SUBTITLE:String = 'subtitletop';//zoome style
        
        /** 清空管理者中的数据 **/
        public static var CLEAR:String = 'clear';
        		/** 弹幕数据列表变化:包括增删弹幕,某个弹幕属性变化 **/
		public static const COMMENT_DATA_CHANGE:String = 'commentDataChange';
		
		/** 弹幕列表变化细分事件与原有的事件独立,支持ArrayCollection的所有用到的操作 **/
		
		/** 弹幕列表变化细分: 末尾添加, data:所增加的项 对应于ArrayCollection#addItem**/
		public static const COMMENT_DATA_APPEND:String = 'commentDataAppend';
		/** 弹幕列表变化细分: 属性变化 data: null,对应于ArrayCollection#refresh**/
		public static const COMMENT_DATA_UPDATE:String = 'commentDataUpdate';
		/** 弹幕列表变化细分: 删除所有 data: null,对应于ArrayCollection#removeAll**/
		public static const COMMENT_DATA_EMPTY:String = 'commentDataEmpty';
        private var _data:Object;
        public function CommentDataEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this._data = data;
        }
        
        public function get data():Object
        {
            return this._data;
        }
    }
    
}