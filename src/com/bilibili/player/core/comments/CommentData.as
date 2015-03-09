package com.bilibili.player.core.comments
{
	//import tv.bilibili.script.bilibili;
	import com.bilibili.player.system.namespaces.bilibili
	/**
	 * @author Aristotle9
	 * @editor Lizeqiangd
	 * 20150107 为datagird增加一个属性.为其能识别出选择功能
	 */
	public  class CommentData
	{
		/** 基础属性 **/
		public var mode:uint = 1;
		private var _text:String = "";

		public function get text():String
		{
			return _text;
		}

		bilibili function set text(value:String):void
		{
			_text = value;
		}
		/** 弹幕时间 /秒 **/
		private var _stime:Number = NaN;

		public function get stime():Number
		{
			return _stime;
		}

		bilibili function set stime(value:Number):void
		{
			_stime = value;
		}

		public var size:int = 25;
		public var date:String = "";
		public var color:uint = 0xffffff;
		private var _danmuId:uint = 0;
		/** 弹幕Id **/
		public function get danmuId():uint
		{
			return _danmuId;
		}

		bilibili function set danmuId(value:uint):void
		{
			_danmuId = value;
		}
		/** 发送者Id **/
		private var _userId:String = "";

		public function get userId():String
		{
			return _userId;
		}

		bilibili function set userId(value:String):void
		{
			_userId = value;
		}

		/** 该弹幕是否正在显示列表上,不能对脚本弹幕作判断 **/
		public function get on():Boolean
		{
			return _on || deleted;
		}

		/**
		 * @private
		 */
		public function set on(value:Boolean):void
		{
			_on = value;
		}


		public var pool:int = 0;

		/** 运行状态:用于管理弹幕 **/
		private var _on:Boolean = false;
		/** 是否已经被屏蔽,用于记录屏蔽结果 **/
		public var blocked:Boolean = false;
		/** 被屏蔽的原因:用于弹幕列表中的分类显示,原因只记录需要区分开的信息 **/
		public var blockType:uint = 0;
		/** 内部弹幕id,不同的弹幕具有不同的id **/
		public var id:uint = 0;
		/** 用于保存发送时的字符串表示的模式,也用于保存发送弹幕的派发事件类型 **/
		public var msg:String = "";
		/**
		 * 直播弹幕的额外信息
		 */
		public var live_extra:CommentDataLiveExtra = null;

		/** 辅助属性:发送的弹幕才具有的属性 **/
		/** 刚刚发送的弹幕,具有蓝色边框,并且要立即显示 **/
		public var border:Boolean = false;
		/** 预览弹幕,只显示,不插入时间队列 **/
		public var preview:Boolean = false;
		/** 刚刚发送的弹幕的大体分类,为CommentDataType成员 **/
		public var type:String = "";
		/** 是否是live弹幕 **/
		public var live:Boolean = false;
		
		/** 管理属性 **/
		/** 远程操作锁定 **/
		public var locked:Boolean = false;
		/** 远程删除标记 **/
		public var deleted:Boolean = false;
		/** 远程举报标记 **/
		public var reported:Boolean = false;
		/** 远程保护标记 **/
		public var credit:Boolean = false;
		
		/**
		 * @param obj 具有CommentData属性的Object,可以用于初始化CommentData各参数
		 **/
		public function CommentData(obj:Object=null)
		{
			if(obj !== null)
			{
				for(var k:String in obj)
				{
					try
					{
						this[k] = obj[k];
					}
					catch(e:Error)
					{
						this.bilibili::[k] = obj[k];
					}
				}
			}
		}
		
		/**  datagird 所用 **/
		public var dgr_comment_selected:Boolean 
	}
}