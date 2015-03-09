package com.bilibili.player.net.comment
{
    import com.bilibili.player.manager.ValueObjectManager;
    
    import flash.display.DisplayObject;

    /** 应用程序配置,从外部xml文件加载 **/
    public class CommentXMLConfig
    {
        private var _xml:XML;
        /** 加载地址 **/
        private var _load:String;
        private var _send:String;
        private var _onHost:String;
        private var _root:DisplayObject;
        private var _gateway:String;
		
		/** 舞台上最大的弹幕数 **/
		[Deprecated(replacement="CommentConfig.density")]
		private var _maxOnStage:uint = 80;
		
		private var _rggImg:String;
		private var _rggURL:String;
		private var _rggNum:uint;
		
		private var _velocity:Number = 3.5;
		private var _constV:Boolean = true;
		
		
		private var _tipsURL:String = 'http://interface.bilibili.tv/msg.xml';
        
        public function CommentXMLConfig(_r:DisplayObject)
        {
            _root = _r;
        }
        
        public function init(xml:XML):void
        {
            _xml = xml;
			
			ValueObjectManager.getPlayerConfig.density = uint(_xml.performance.maxonstage); 
			if(ValueObjectManager.getPlayerConfig.density == 0)
				ValueObjectManager.getPlayerConfig.density = 80;
			
            _load = _xml.server.load;
            _send = _xml.server.send;
            _gateway = _xml.server.gateway;
            _onHost = _xml.server.onhost;
			
			_rggImg = xml.rgg.@img;
			_rggURL = xml.rgg.@url;
			_rggNum = uint(xml.rgg.@rggnum);
			
			if(xml.tips.length())
				_tipsURL = String(xml.tips.@url);
            // ...
        }
        public function get initialized():Boolean
        {
            if(_xml)
            {
                return true;
            }
            return false;
        }
        public function getCommentFileURL(id:String):String
        {
            var result:String = _load.replace(/\{\$id\}/ig,id);
            var random:String = 'r=' + Math.ceil(Math.random() * 1000);
            if(result.lastIndexOf('?') == -1)
            {
                result += '?' + random;
            }
            else
            {
                result += '&' + random;
            }
            return result;
        }
        public function getCommentPostURL(id:String):String
        {
            return 'http://interface.bilibili.tv/dmpost';
        }
        public function get playerURL():String
        {
            return _root.loaderInfo.url;
        }
        public function getConfURL(fileName:String='conf.xml'):String
        {
            return playerURL.replace(/[^\/]+.swf.*/igm,'') + fileName;
        }

        /** amf网关 **/
        public function get gateway():String
        {
            return _gateway;
        }
        /** 使用mukioplayer规定的参数来路由 **/
        public function get isOnHost():Boolean
        {
            return _onHost.length != 0;
        }
		
		/** 广告图片 **/
		public function get rggImg():String
		{
			return _rggImg;
		}
		/** 广告链接目标 **/
		public function get rggURL():String
		{
			return _rggURL;
		}
		/** 广告数目 **/
		public function get rggNum():uint
		{
			return _rggNum;
		}
		
		/** 舞台上最大的弹幕数量 **/
		public function get maxOnStage():uint
		{
			return ValueObjectManager.getPlayerConfig.density;
		}

		/** 滚动消息地址 **/
		public function get tipsURL():String
		{
			var ret:String = _tipsURL;
			return ret;
		}

		/**
		 * @private
		 */
		public function set tipsURL(value:String):void
		{
			_tipsURL = value;
		}

		/** 滚动弹幕速率 **/
		public function get velocity():Number
		{
			return _velocity;
		}

		/**
		 * @private
		 */
		public function set velocity(value:Number):void
		{
			_velocity = value;
		}

		/** 是否是恒定速度 **/
		public function get constV():Boolean
		{
			return _constV;
		}

		/**
		 * @private
		 */
		public function set constV(value:Boolean):void
		{
			_constV = value;
		}


    }
}