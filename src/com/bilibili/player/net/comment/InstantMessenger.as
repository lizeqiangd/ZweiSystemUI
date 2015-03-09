package com.bilibili.player.net.comment
{
	
	import com.bilibili.player.core.comments.IMDataParser;
	import com.bilibili.player.manager.AccessConsumerManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.net.interfaces.IPackSender;
	import com.bilibili.player.system.notification.Notification;
	import com.bilibili.player.system.notification.NotificationType;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/** 即时弹幕更新 **/
	public class InstantMessenger implements IPackSender
	{
		private var _stateInfo:String = '';
		/**
		 * 主机地址
		 **/
		protected var server:String;
		protected var _chatId:int;
		/**
		 * 用户id
		 **/
		protected var userId:int;
		/**
		 * 用户密码hash
		 **/
		protected var pwd:String;
		/**
		 * 随机数,与自己发送出去的弹幕的随机数相同
		 **/
		protected var randId:uint;
		/**
		 * 连接的socket
		 **/
		protected var _socket:Socket;
		/**
		 * 秒表
		 **/
		protected var _timer:Timer;
		/**
		 * 重试的时间句柄
		 **/
		protected var _retryTimer:uint = 0;
		/**
		 * 数据解析器
		 **/
		protected var _parser:IMDataParser;
		/**
		 * 观众数
		 **/
		protected var _numGuanzhong:uint = 0;
		/**
		 * 是否已经连接
		 **/
		protected var _connected:Boolean = false;
		/**
		 * 缓存向服务器发送的包裹
		 */
		protected var buffer:Array = [];
		
		/**
		 * @param server 访问控制返回的server
		 **/
		public function InstantMessenger()
		{
			_timer = new Timer(30000);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			_parser = new IMDataParser(this);
			
			AccessConsumerManager.addAccessConfigChangeFunction(onAccessConfigUpdate)
			//AccessConsumerManager.regist(this);
		}
		
		/**
		 * 当配置文件更改后,如果cid有变化,那重新连接广播接收器
		 */
		public function onAccessConfigUpdate( /*accessConfig:AccessConfig*/):void
		{
			var oldCid:int = chatId;
			
			this.server = ValueObjectManager.getAccessConfig.server;
			this.randId = ValueObjectManager.getAccessConfig.randId;
			this.chatId = ValueObjectManager.getAccessConfig.chatId;
			this.userId = ValueObjectManager.getAccessConfig.userId;
			this.pwd = ValueObjectManager.getAccessConfig.pwd == null ? '' : ValueObjectManager.getAccessConfig.pwd;
			
			if (oldCid != chatId)
			{
				close();
				connect();
			}
		}
		
		/**
		 * 连接到服务器
		 **/
		public function connect():void
		{
			_connected = false;
			stateInfo = '正在连接弹幕服务器...';
			if (chatId == 0)
			{
				stateInfo = '无弹幕ID，意外错误!';
				return;
			}
			if (server == '')
			{
				stateInfo = '无法找到弹幕服务器，取消连接.';
				return;
			}
			Security.loadPolicyFile("xmlsocket:://" + server + ":88");
			if (_socket)
			{
				closeSocket(_socket);
			}
			_socket = setupSocket();
			_socket.connect(server, 88);
		}
		
		/**
		 * 断开服务器
		 **/
		public function close():void
		{
			if (_socket == null)
			{
				return;
			}
			try
			{
				_socket.close();
				closeSocket(_socket);
			}
			catch (e:Error)
			{
				trace("断开错误: " + e.toString());
			}
			_socket = null;
//			重连取消
			if (_retryTimer != 0)
			{
				clearTimeout(_retryTimer);
				_retryTimer = 0;
			}
//			轮询取消
			_timer.stop();
//			断开连接
			_connected = false;
			stateInfo = '弹幕服务器已断开.';
		}
		
		/**
		 * 重试
		 * @param delay 经过长时间后重试/ms
		 **/
		protected function reConnect(delay:uint):void
		{
			if (_retryTimer != 0)
			{
				clearTimeout(_retryTimer);
				_retryTimer = 0;
			}
			var re:Function = function():void
			{
				_retryTimer = 0;
				connect();
			};
			
			if (_socket != null)
			{
				_socket.close();
				closeSocket(_socket);
				_socket = null;
			}
			_retryTimer = setTimeout(re, delay);
		}
		
		/**
		 * 添加事件
		 **/
		protected function setupSocket():Socket
		{
			var s:Socket = new Socket();
			s.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			s.addEventListener(Event.CONNECT, connectHandler);
			s.addEventListener(Event.CLOSE, closeHandler);
			s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			s.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			return s;s
		}
		
		/**
		 * 移除事件
		 **/
		protected function closeSocket(s:Socket):void
		{
			try
			{
				s.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
				s.removeEventListener(Event.CONNECT, connectHandler);
				s.removeEventListener(Event.CLOSE, closeHandler);
				s.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				s.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			}
			catch (e:*)
			{
				trace('InstantMessenger.closeSocket:Failed')
			}
		}
		
		/**
		 * 连接成功
		 **/
		protected function connectHandler(event:Event):void
		{
			stateInfo = '握手成功，等待回应...';
			_socket.writeShort(257); //index
			var len:int = 4 + 4 + 4; //index len cid uid
			if (pwd.length == 8)
			{
				len += pwd.length; //pass
			}
			_socket.writeShort(len); //len
			
			_socket.writeInt(chatId);
			_socket.writeInt(userId);
			if (pwd.length == 8)
			{
				_socket.writeUTFBytes(pwd);
			}
			_socket.flush();
			_connected = true;
			
			while (buffer.length > 0)
			{
				var a:Array = buffer.shift();
				_writePack.apply(this, a);
			}
			_timer.start();
		}
		
		/**
		 * 定时发送数据
		 **/
		protected function timerHandler(event:TimerEvent):void
		{
			_socket.writeShort(258);
			_socket.writeShort(4);
			_socket.flush();
		}
		
		/**
		 * 数据接收中
		 **/
		protected function socketDataHandler(event:ProgressEvent):void
		{
			//trace("InstantMessenger.socketDataHandler:")
			_parser.readSocketData(_socket);
		}
		
		/**
		 * io错误
		 **/
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			trace(event.toString());
			stateInfo += '　!发生异常.';
			_timer.stop();
			_connected = false;
			//重新连接
			reConnect(3000);
		}
		
		/**
		 * 安全策略错误
		 **/
		protected function securityErrorHandler(event:SecurityErrorEvent):void
		{
			stateInfo = '无法连接到弹幕服务,5秒后重接.';
			_timer.stop();
			_connected = false;
			//重新连接(与ioError会同时发生?没有关系)
			reConnect(5000);
		}
		
		/**
		 * 被服务器关闭
		 **/
		protected function closeHandler(event:Event):void
		{
			var delay:int = 3;
			stateInfo = "弹幕服务器连接被断开," + delay + "秒后重接.";
			
			_timer.stop();
			_connected = false;
			reConnect(delay * 1000);
		}
		
		/**
		 * 提供给parser的接口
		 **/
		public function setStateInfo(info:String):void
		{
			stateInfo = info;
		}
		
		public function externalCall(... args):void
		{
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call.apply(null, args);
				}
				catch (e:Error)
				{
					
				}
			}
		}
		
		/**
		 * 弹幕数据<br />
		 * - 如果随机值与当前用户一致,则更新最近发送的弹幕的用户id与弹幕id<br />
		 * - 添加弹幕,如果滚动条在底部,则滚动弹幕表
		 * @param raw 收到的序列化的弹幕数据
		 **/
		public function newCommentString(raw:String):void
		{
			try
			{
				var js:Object = JSON.parse(raw);
			}
			catch (e:Error)
			{
				trace(e);
				return;
			}
			var arr:Array = js[0].split(',');
			if (arr[5] == '' || parseInt(arr[5]) == randId)
			{
				/** 更新最近发送的弹幕的id工作交给POST结果事件来完成 **/
				//EventBus.getInstance().sendMukioEvent('updateRecentCommentInfo', {userId: arr[7], danmuId: arr[8]});
				return;
			}
			
			arr.splice(5, 1);
			var item:XML =     <d>{js[1]}</d>;
			item['@p'] = arr.join(',');
			if (js[2])
			{
				item['@live_extra'] = JSON.stringify(js[2]);
			}
			ValueObjectManager.getEventBus.sendMukioEvent('newCommentReceived', item);
		}
		
		/**
		 * 接收到一个滚动消息
		 * @param raw 格式为json字符串 <br/>
		 * <code>
		 * {<br/>
		 *   text:String(htmlText)(必须),<br/>
		 *   catalog:String(可选(system|bangumi|default),实时情况下默认是system),<br/>
		 *   highlight:Boolean(可选),<br/>
		 *   bgcolor:int(可选),<br/>
		 *   flash:Boolean(可选)<br/>
		 * }<br/>
		 * </code>
		 **/
		public function newScrollMessage(raw:String):void
		{
			try
			{
				var js:Object = JSON.parse(raw);
			}
			catch (e:Error)
			{
				trace(e);
				return;
			}
			/** 消息默认是高亮并且会闪 **/
			var n:Notification = new Notification(js.text, true, null, true);
			n.catalog = js.catalog || NotificationType.SYSTEM; //消息类别
			if (js.hasOwnProperty('highlight'))
				n.highlight = js.highlight;
			if (js.hasOwnProperty('bgcolor'))
				n.bgColor = js.bgcolor;
			if (js.hasOwnProperty('flash'))
				n.flash = js.flash;
			if (js.hasOwnProperty('tooltip'))
				n.tooltip = js.tooltip;
			/** 派发并立即显示 **/
			ValueObjectManager.getEventBus.sendMukioEvent('appendNotification', {msg: n, show: true});
		}
		
		/**
		 * @param commandStr 播放器命令的调用的JSON编码的数组
		 * 有如下播放器控制调用
		 * ["COMMENT_BLOCK", 剩余时间(timestmap,s)] 全局禁言
		 * ["LIVE"] 进入直播
		 * ["END"] 直播结束
		 * ["BLOCK"] 直接阻止
		 * ["PREPARING"] 准备中
		 */
		public function playerCommand(commandStr:String):void
		{
			try
			{
				var rpc:Array = JSON.parse(commandStr) as Array;
				ValueObjectManager.getEventBus.sendMukioEvent('playerCommandReceived', rpc);
					//externalCall('console.log', rpc);	
			}
			catch (e:Error)
			{
				trace(e);
			}
		}
		
		//CONFIG::flex
		//{
		//[Bindable]
		//}
		
		/**
		 * 观众数
		 **/
		public function get numGuanzhong():uint
		{
			return _numGuanzhong;
		}
		
		/**
		 * @private
		 */
		public function set numGuanzhong(value:uint):void
		{
			if (_numGuanzhong != value)
			{
				_numGuanzhong = value;
				ValueObjectManager.getEventBus.sendMukioEvent('num_guanzhong_changed', {count: value, info: "观众数:" + value});
			}
		}
		
		/**
		 * 是否已经连接
		 **/
		public function get connected():Boolean
		{
			return _connected;
		}
		
		//CONFIG::flex
		//{
		//[Bindable]
		//}
		
		/**
		 * 连接状态:给客户看的信息
		 **/
		public function get stateInfo():String
		{
			return _stateInfo;
		}
		
		/**
		 * @private
		 */
		public function set stateInfo(value:String):void
		{
			if (_stateInfo != value)
			{
				_stateInfo = value;
				ValueObjectManager.getEventBus.sendMukioEvent('state_info_changed', {info: value});
			}
		}
		
		/**
		 * 频道id
		 **/
		public function get chatId():int
		{
			return _chatId;
		}
		
		/**
		 * @private
		 */
		public function set chatId(value:int):void
		{
			_chatId = value;
		}
		
		public function writePack(index:int, payload:String):void
		{
			if (connected)
			{
				_writePack(index, payload);
			}
			else
			{
				buffer.push([index, payload]);
			}
		}
		
		protected function _writePack(index:int, payload:String):void
		{
			try
			{
				_socket.writeShort(index);
				_socket.writeShort(4 + payload.length);
				_socket.writeUTFBytes(payload);
				_socket.flush();
			}
			catch (e:Error)
			{
				trace('write socket error:' + e);
			}
		}
	
	}
}