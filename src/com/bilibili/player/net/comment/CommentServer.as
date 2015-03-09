package com.bilibili.player.net.comment
{
    
    import com.bilibili.player.events.MukioEvent;
    import com.bilibili.player.manager.AccessConsumerManager;
    import com.bilibili.player.manager.ValueObjectManager;
    import com.bilibili.player.valueobjects.config.AccessConfig;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.NetConnection;
    import flash.net.ObjectEncoding;
    import flash.net.Responder;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    
    
    
//    import tv.bilibili.net.AccessConfig;
//    import tv.bilibili.net.AccessConsumerManager;
//    import tv.bilibili.net.IAccessConfigConsumer;
    
    /** 
    * 处理向服务器发送弹幕消息
    * 从服务器的Amf加载弹幕
    * 普通的弹幕文件加载在provider中,因为实现得比较早
    * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141203 更改AccessConfigManager为新模式.使用全局触发.
    **/
    public class CommentServer extends EventDispatcher/* implements IAccessConfigConsumer*/
    {
		/**
		 * 随机id,由AccessConfig赋值,暂存于本类
		 **/
		private var _accessConfig:AccessConfig;
        private var _gateway:String;
        private var _postServer:String;
        private var _postLoader:URLLoader;
        private var _dataServer:NetConnection;
        private var _responderPut:flash.net.Responder;
        private var _responderGet:flash.net.Responder;
        private var _dispathHandle:Function;

        public function CommentServer()
        {
			ValueObjectManager.getEventBus.addEventListener(MukioEvent.SEND,sendHandler);
            
            _postLoader = new URLLoader();
            _postLoader.addEventListener(Event.COMPLETE,postLoader_CompleteHandler);
            _postLoader.addEventListener(IOErrorEvent.IO_ERROR,postLoader_ErrorHandler);
            _postLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,postLoader_ErrorHandler);
			
            AccessConsumerManager.addAccessConfigChangeFunction(onAccessConfigUpdate)
//			AccessConsumerManager.regist(this);
            super(null);
        }
        
        /** 当接收到SEND消息后 **/
        private function sendHandler(event:MukioEvent):void
        {
            /**
            * item的格式在EventBus中以及弹幕输入类Input中可查
            **/
            var item:Object = event.data;
            var data:Object;
            if(_dataServer)
            {
                log("使用AMF发送");
                data = CommentDataParser.data_format(item);
                _dataServer.call('CmtAmfService.putCmt',_responderPut,data, _accessConfig.chatId);
            }
            else if(_postServer)
            {
                log("使用POST发送");
                data = CommentDataParser.data_format(item);
                var postVariables:URLVariables = new URLVariables();
                for(var k:String in data)
                {
                    postVariables[k] = data[k];
                }
                postVariables["rnd"] = _accessConfig.randId;
                postVariables["cid"] = _accessConfig.chatId;
                var request:URLRequest = new URLRequest(_postServer);
                request.method = 'POST';
                request.data = postVariables;
                _postLoader.load(request);
            }
            else
            {
                log("无法发送弹幕,服务器配置不正确.");
				ValueObjectManager.getEventBus.removeEventListener(MukioEvent.SEND,sendHandler);
            }
        }
		/** 弹幕发送完毕,通信完成 **/
        private function postLoader_CompleteHandler(event:Event):void
        {
			var ret:Number = Number(event.target.data);
			if(ret < 0)
			{
				log('弹幕发送失败! code:' + ret);
				ValueObjectManager.getEventBus.sendMukioEvent('commentPOSTResult', {success:false, reason:"发送失败,错误代码:" + ret});
			}
			else
			{
				/** ret 是弹幕Id **/
	            log('弹幕发送成功! code:' + ret);   
				ValueObjectManager.getEventBus.sendMukioEvent('commentPOSTResult', {success:true, reason:'发送成功!', id:ret});
			}
        }
		/** 通信出错 **/
        private function postLoader_ErrorHandler(event:Event):void
        {
			ValueObjectManager.getEventBus.sendMukioEvent('commentPOSTResult', {success:false, reason:"发送失败,无法连接服务器."});
			log('弹幕发送失败!连接失败.');
        }
        private function remotePutHandler(result:*):void
        {
            log('remotePutHandler:'+JSON.stringify(result));
        }
        private function remoteGetHandler(result:*):void
        {
            var items:Array = result as Array;
            CommentDataParser.data_parse(items,_dispathHandle);
        }
        private function remoteError(e:*):void
        {
            log('remoteError:'+ JSON.stringify (e));
        }

        private function log(message:String):void
        {
			ValueObjectManager.getEventBus.log(message);
        }

        private function get gateway():String
        {
            return _gateway;
        }
		
        public function getCmts(foo:Function):void
        {
            if(!_dataServer)
            {
                log('服务器未连接,无法取得弹幕块.');
                return;
            }
            _dispathHandle = foo;
            _dataServer.call('CmtAmfService.getCmts',_responderGet, _accessConfig.chatId);
        }
        private function set gateway(value:String):void
        {
            _gateway = value;
            if(_gateway == '')
            {
                log('服务器网关为空,取消连接操作.');
                return;
            }
            try
            {
                _dataServer = new NetConnection();
                _dataServer.objectEncoding = ObjectEncoding.AMF3;
                _dataServer.connect(_gateway);
                _responderPut = new flash.net.Responder(remotePutHandler,remoteError);
                _responderGet = new flash.net.Responder(remoteGetHandler,remoteError);
                log('与服务器连接完毕');
            }
            catch(error:Error)
            {
                log('与服务器连接遇到问题:\n' +
                    '_gateway:' + _gateway + '\n'
                    +error);
            }
        }
        /**
        * post提交的url
        * 收到需要发送的数据时,先检测_dataServer是否赋值,如果是,则用_gateway进行postamf提交
        * 如果没有赋值,则检测_postServer是否赋值,如果是,则用post表单提交
        **/
        private function get postServer():String
        {
            return _postServer;
        }

        private function set postServer(value:String):void
        {
            _postServer = value;
        }
		
		public function onAccessConfigUpdate(/*accessConfig:AccessConfig*/):void
		{
			_accessConfig = AccessConsumerManager.getAccessConfig;
			_postServer = AccessConsumerManager.getAccessConfig.commentPostUrl;
			gateway = "";
		}
    }
}