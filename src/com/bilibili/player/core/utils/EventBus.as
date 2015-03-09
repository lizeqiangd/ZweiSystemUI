package com.bilibili.player.core.utils
{	
	import com.bilibili.player.system.namespaces.bilibili;
	
	import com.bilibili.player.components.encode.DateTimeUtils;
	import com.bilibili.player.core.comments.CommentData;
	import com.bilibili.player.core.comments.CommentDataMode9;
	import com.bilibili.player.core.comments.CommentDataType;
	import com.bilibili.player.core.filter.CommentFilter;
	import com.bilibili.player.core.filter.RemoteLoaderState;
	import com.bilibili.player.events.MukioEvent;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.net.comment.CommentDataParser;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
//    import org.lala.comments.CommentData;
//    import org.lala.comments.CommentDataMode9;
//    import org.lala.comments.CommentDataType;
//    import org.lala.comments.CommentPlayer;
//    import org.lala.filter.CommentFilter;
//    import org.lala.filter.RemoteLoaderState;
//    import org.lala.utils.CommentDataParser;	
//	import com.longtailvideo.jwplayer.utils.Strings;
//    import tv.bilibili.script.bilibili;
	
	/**
	 * 发送弹幕
	 **/
	//[Event(name="send",type="org.lala.event.MukioEvent")]
	/**
	 * display事件有两重含义:呈现事件(发送到内部处理队列)与发送前预处理
	 * 弹幕的模式数据转换为数值表示
	 * 并且可以处理弹幕命令
	 * send事件主要是从display事件派生
	 * 如果数据中有preview设置为true,则不产生发送事件
	 **/
	[Event(name="display",type="org.lala.event.MukioEvent")]
	/**
	 * 弹幕发送结果:
	 * success:true|成功,false|失败
	 * id:刚刚发送的弹幕的id(success == true)
	 * reason:失败原因(success == false),成功提示(success == true)
	 **/
	[Event(name="commentPOSTResult",type="org.lala.event.MukioEvent")]
	/**
	 * 显示日志
	 **/
	[Event(name="log",type="org.lala.event.MukioEvent")]
	/**
	 * 清除日志输出窗口
	 **/
	[Event(name="clearLog",type="org.lala.event.MukioEvent")]
	/**
	 * 更新最近发送的弹幕的用户id(自己),弹幕id
	 * data:{
	 * userId:用户id
	 * danmuId:弹幕id
	 * }
	 **/
	[Event(name="updateRecentCommentInfo",type="org.lala.event.MukioEvent")]
	/**
	 * 接收到新的弹幕
	 * data:<d>格式同弹幕文件
	 **/
	[Event(name="newCommentReceived",type="org.lala.event.MukioEvent")]
	/**
	 * 接收到播放器命令
	 * data: [rpc_name, ...params]
	 */
	[Event(name="playerCommandReceived",type="org.lala.event.MukioEvent")]
	/**
	 * 滚动弹幕列表,如果滚动条是在最后的话
	 **/
	[Event(name="scrollCommentTable",type="org.lala.event.MukioEvent")]
	/**
	 * 重新加载用户配置文件
	 **/
	[Event(name="reloadAccessConfig",type="org.lala.event.MukioEvent")]
	/**
	 * 重新载入弹幕
	 * data:{timestamp:时间戳(0表示当前弹幕,其余表示历史弹幕)}
	 **/
	[Event(name="reloadCommentFile",type="org.lala.event.MukioEvent")]
	/**
	 * 过滤器更新
	 * data:CommentFilter
	 **/
	[Event(name="commentFilterChange",type="org.lala.event.MukioEvent")]
	/**
	 * 举报弹幕
	 * data:{info:举报信息,em:是否严重违法}
	 **/
	[Event(name="reportAbuse",type="org.lala.event.MukioEvent")]
	/**
	 * 滚动消息事件
	 * data{msg:Notification, show:Boolean,是否立即显示}
	 **/
	[Event(name="appendNotification",type="org.lala.event.MukioEvent")]
	/**
	 * 更改"观众"名称
	 **/
	[Event(name="changeWatcherName",type="org.lala.event.MukioEvent")]
	/**
	 * 显示分享图片对话框
	 **/
	[Event(name="showShareImageDialog",type="org.lala.event.MukioEvent")]
	/**
	 * 暂停视频
	 */
	[Event(name="pauseVideo",type="org.lala.event.MukioEvent")]
	/**
	 * 乐视回溯:如果视频无法使用乐视播放,则回滚到新浪模式
	 * data: videoInfo
	 */
	[Event(name="letv-rollback",type="org.lala.event.MukioEvent")]
	/**
	 * 播放下一P,通过JWPlayer的播放下一P系统进行播放过于复杂,于是先直接调用model
	 * 本reload事件是PlayerTool到Model的传递消息方法, 而不是重新播放的发起事件. 要发起请使用 PlayerTool#loadCidVideo(cid, true)
	 * data: videoInfo
	 */
	[Event(name="reload",type="org.lala.event.MukioEvent")]
	/**
	 * 设置播放器的清晰度选择选项:发送此消息将在播放画面左下角显示一排清晰度选择按钮(比例切换上方)
	 * data {
	 * 	current: itemId: 当前的清晰度id
	 *  list: [item: {id: itemId, name: 高清|流畅|原画, type: letv|qq}]
	 * }
	 */
	[Event(name="setLetvDefinitionConfig",type="org.lala.event.MukioEvent")]
	/**
	 * 清晰度切换事件:清晰度切换按钮按下后发送该事件
	 * data: item: {id: itemId, name: type:}
	 */
	[Event(name="setLetvDefinition",type="org.lala.event.MukioEvent")]
	/**
	 * 重新加载当前视频:清晰度切换后的事件
	 */
	[Event(name="reloadVideo",type="org.lala.event.MukioEvent")]
	/**
	 * 全局禁言时间更新
	 * data: 禁言时间/s
	 */
	[Event(name="blockTimeUpdate",type="org.lala.event.MukioEvent")]
	/**
	 * 播放器退出(网页)全屏
	 */
	[Event(name="playerExitFullWin",type="org.lala.event.MukioEvent")]
	/**
	 * 切换推荐弹幕与实时弹幕
	 * data: {recommend: Boolean 是否是推荐弹幕}
	 */
	[Event(name="switchRecommendComment",type="org.lala.event.MukioEvent")]
	/**
	 * 观众人数变化(由广播客户端发出)
	 * data: {count:uint 观众人数}
	 */
	[Event(name="num_guanzhong_changed",type="org.lala.event.MukioEvent")]
	/**
	 * 连接信息变化(由广播客户端发出)
	 * data: {info:String 状态信息}
	 */
	[Event(name="state_info_changed",type="org.lala.event.MukioEvent")]
	
	/**
	 * 弹幕播放器弹幕相关事件管道
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141204 已经没有什么好怕的了.
	 * 20141209 不 我还是怕了.
	 **/
	public class EventBus extends EventDispatcher
	{
		private static var instance:EventBus;
		
		private var hasLogListener:Boolean = false;
		private var logsBeforeListener:Array = [];
		
		/** 一些与弹幕数据相关的全局数据 **/ /** 弹幕池 **/
		public var commentPool:uint = 0;
		/** 最近发送的弹幕:队列 **/
		private var recentStack:Vector.<CommentData> = new Vector.<CommentData>();
		/** 历史普通滚动单字弹幕:用于屏蔽判定(单字叠加的竖向弹幕,重复的弹幕) **/
		private var normalScrollCommentHistory:Vector.<CommentData> = new Vector.<CommentData>();
		
		public function EventBus(target:IEventDispatcher = null)
		{
			//if (instance != null)
			//{
				//throw new Error("please use getInstance() method.");
			//}
			this.addEventListener("commentPOSTResult", updateRecentSendCommentIdHandler);
		}
		
		//public static function getInstance():EventBus
		//{
			//if (instance == null)
			//{
				//instance = new EventBus();
			//}
			//return instance;
		//}
		
		public function sendMukioEvent(type:String, data:Object = null):void
		{
			//************************************
			try
			{
				trace("EventBus:", type, data.info)
			}
			catch (e:*)
			{
			}
			//************************************
			
			if (type == MukioEvent.DISPLAY)
			{
				data = displayHook(data as CommentData);
				
				/** displayHook可以拦截display事件 **/
				if (data)
					dispatchEvent(new MukioEvent(type, data));
			}
			else if (type == MukioEvent.LOG && !hasLogListener)
			{
				pushLog(new MukioEvent(type, data));
				return;
			}
			else
			{
				dispatchEvent(new MukioEvent(type, data));
			}
		}
		
		/**
		 * 显示弹幕数据预处理
		 * 将弹幕数据表示为数字形式
		 * 添加非界面产生的数据：弹幕时间，弹幕池（弹幕内部id是在添加到弹幕库中产生的）
		 * -->>msg与mode：msg是内部派发的类型，mode是发送到外部的弹幕模式（一般情况下msg==String(mode)）
		 * 拦截弹幕，如果必要的话
		 * 解释弹幕命令
		 **/
		private function displayHook(data:CommentData):CommentData
		{
			var a:Array = String(data.text).match(/^script:(.*)/ism);
			if (false)
			{
				//可以在其他弹幕输入面板中输入脚本弹幕
				//只要在内容前加上script:前缀
				//没有预览功能的面板则直接将弹幕放入弹幕库中
				data.type = CommentDataType.SCRIPT;
				data.bilibili::text = a[1];
				data.mode = 8;
			}
			if (data.type != CommentDataType.SCRIPT)
			{
				data.bilibili::text = CommentDataParser.text_string(data.text);
			}
			if (data.type == CommentDataType.NORMAL)
			{
				/** 普通弹幕框可以输入命令 **/
				var parseResult:Object = parse(data.text);
				/** 命令已经被解析 **/
				if (!parseResult.ret)
				{
//                    data.text = parseResult.text;
					/** 命令已经被解析，不再发送数据，事件终止 **/
					return null;
				}
			}
			else if (data.type == CommentDataType.ZOOME)
			{
				data.msg = (data as CommentDataMode9).style + (data as CommentDataMode9).position;
			}
			else if (data.type == CommentDataType.BILI)
			{
				data.msg = data.mode.toString();
			}
			else if (data.type == CommentDataType.SCRIPT)
			{
				data.msg = data.mode.toString();
			}
			else
			{
				return data;
			}
			data.border = true;
			/**
			 * 高级弹幕可以设定时间,非预览时
			 * 不设定弹幕时间为当前时间
			 **/
			if (isNaN(data.stime) || data.preview)
			{
				data.bilibili::stime = ValueObjectManager.getCommentDisplayer.stime;
			}
			
			data.date = DateTimeUtils.getDateTime()
			/** 弹幕池由mode模板更改,但是也被高级弹幕使用,所以绑定在EventBus上 **/
			data.pool = data.pool || commentPool;
			
			var filter:CommentFilter = ValueObjectManager.getCommentFilter
			if (data.pool == 0 && data.type == CommentDataType.NORMAL)
			{
				/** UP屏蔽检测 **/
				if (filter.bUpperEnable || filter.bUpperDefault)
				{
					if (filter.upperFiler && filter.upperFiler.state == RemoteLoaderState.LOADED)
					{
						if (!filter.upperFiler.validate(data))
						{
							sendMukioEvent('commentPOSTResult', {success: false, id: 0, reason: "UP主屏蔽(已开启)"});
							return null;
						}
					}
				}
				/** 竖向弹幕检测 **/
				if (data.mode === 1)
				{
					var trimed_text:String = DateTimeUtils.trim(data.text);
					
					if (trimed_text.length === 1)
					{
						for each (var cmtData1:CommentData in normalScrollCommentHistory)
						{
							if (data.stime == cmtData1.stime)
							{
								/** 检测命中的弹幕不再发送 **/
								return data;
							}
						}
						normalScrollCommentHistory.push(data);
					}
				}
			}
			//填充好后准备发送,不发送预览弹幕
			if (!data.preview)
			{
				/** 登记最近被发送的弹幕:同一性不能保证 **/
				recentStack.push(data);
				ValueObjectManager.getEventBus.sendMukioEvent(MukioEvent.SEND, data);
			}
			return data;
		}
		
		/**
		 * 更新最近发送弹幕的id
		 **/
		protected function updateRecentSendCommentIdHandler(event:MukioEvent):void
		{
			var data:CommentData = recentStack.shift();
			if (data && event.data.success)
			{
				data.bilibili::danmuId = event.data.id;
			}
		}
		
		/**
		 * 文本命令解析
		 * @return ret true表示没有特殊处理
		 **/
		private function parse(text:String):Object
		{
			var p:RegExp = /\d+\u4e2a(.+?)\u4e0d\u8bf4\u8bdd/i;
			var ret:Boolean = true;
			var res:Object= p.exec(text);
			if (res)
			{
				trace(res[1]);
				if (res[1].length === 2)
					sendMukioEvent("changeWatcherName", res[1]);
				ret = false;
			}
			else if (text.match(/\{\[:\/a43125796043\/a\/b96347\/b:\]}/))
			{
				sendMukioEvent("changeUserImage", {});
				ret = false;
			}
			var result:Object = {ret: ret, text: text};
			return result;
		}
		
		/**
		 * 日志显示
		 */
		public function log(message:String, isLoadingLog:Boolean = false):void
		{trace("EventBus.log:",message)
			sendMukioEvent(MukioEvent.LOG, message);
			if (isLoadingLog)
			{
				loadingLog(message);
			}
		}
		
		/**
		 * 加载进度
		 */
		public function loadingLog(message:String):void
		{
			sendMukioEvent("loadingLog", message);
		}
		
		/**
		 * 清除日志输出
		 **/
		public function clear():void
		{
			sendMukioEvent('clearLog');
		}
		
		/**
		 * 重载,在有log监听器之保存所有log,第一个监听器连接上时dump所有log事件
		 * 因Flex界面创建机制,在输出器创建之前的log无法监听到
		 * 只为第一个监听器保存,当然本应用程序中只有一个log事件监听者
		 **/
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			if (hasLogListener == false && type == MukioEvent.LOG)
			{
				hasLogListener = true;
				dumpLogs();
			}
		}
		
		private function pushLog(logEvent:MukioEvent):void
		{
			logsBeforeListener.push(logEvent);
		}
		
		private function dumpLogs():void
		{
			while (logsBeforeListener.length)
			{
				dispatchEvent(logsBeforeListener.shift());
			}
		}
	}
}