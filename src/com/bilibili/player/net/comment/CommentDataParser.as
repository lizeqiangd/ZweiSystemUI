package com.bilibili.player.net.comment
{
	import com.bilibili.player.components.encode.DateTimeUtils;
	import com.bilibili.player.core.comments.CommentData;
	import com.bilibili.player.core.comments.CommentDataLiveExtra;
	import com.bilibili.player.core.comments.CommentDataMode7;
	import com.bilibili.player.system.namespaces.bilibili;
	
	/**
	 * 弹幕文件解析,编码类
	 * 因兼容原来的弹幕格式缘故,解析代码有相似性..
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * ps:不对外发布任何事件,因此属于一个普通的解析类
	 * 20141107 服用代码,重新更改路径.分类
	 * 20141128 弹幕似乎没有任何加密,但是要注意服务器会gzip一下.而且弹幕类型基本上就是bili弹幕了 其他模式的识别可以考虑注释或者删掉.
	 * 20141204 修正commentdata的bug后,将datetimeunit替换本类的date方法.
	 **/
	public class CommentDataParser
	{
		/** 弹幕计数 **/
		public static var length:Number = 0;
		
		/**
		 * 解析旧的acfun弹幕文件
		 * @param xml 弹幕文件的xml
		 * @param foo 对单个弹幕数据的处理函数:第一个参数为消息名,用来分类弹幕,第二个参数为data:Object
		 **/
		public static function acfun_parse(xml:XML, foo:Function):void
		{
			var list:XMLList = xml.data;
			for each (var item:XML in list)
			{
				var obj:Object = {};
				obj.color = uint(item.message.@color);
				obj.size = uint(item.message.@fontsize);
				obj.mode = uint(item.message.@mode);
				obj.stime = parseFloat(item.playTime);
				obj.date = item.times;
				obj.text = text_string(item.message);
				obj.border = false;
				obj.user = null;
				obj.id = length++;
				foo(String(obj.mode), obj);
			}
		}
		
		/**
		 * 解析新的acfun弹幕文件
		 * @param xml 弹幕文件的xml
		 * @param foo 对单个弹幕数据的处理函数:第一个参数为消息名,用来分类弹幕,第二个参数为data:Object
		 **/
		public static function acfun_new_parse(xml:XML, foo:Function):void
		{
			var list:XMLList = xml.l;
			for each (var item:XML in list)
			{
				try
				{
					var obj:Object = {};
					var attrs:Array = String(item.@i).split(',');
					obj.stime = parseFloat(attrs[0]);
					obj.size = uint(attrs[1]);
					obj.color = uint(attrs[2]);
					obj.mode = uint(attrs[3]);
					obj.date = DateTimeUtils.getDateTime(new Date(parseInt(attrs[5])))					
					obj.author = attrs[4];
					obj.text = text_string(item);
					obj.border = false;
					obj.id = length++;
					foo(String(obj.mode), obj);
				}
				catch (e:Error)
				{
				}
			}
		}
		
		/**
		 * 解析bili的常用数据
		 * @param xml 弹幕数据文件
		 * @param foo 分发函数
		 * @param hasRecommend 是否有推荐弹幕
		 * @param max 弹幕上限, 如果没有的话在弹幕中查找, 最终找不到的话 hasRecommend 无效
		 * @param isRecommend 是否开启了推荐弹幕
		 **/
		public static function bili_parse(xml:XML, foo:Function, hasRecommend:Boolean = false, max:Number = NaN, isRecommend:Boolean = false):void
		{
			var list:XMLList = xml.d;
			var item_list:* = list;
			var obj:CommentData;
			var objExt:CommentDataMode7;
			var item:XML;
			var attrs:Array;
			var pool:int;
			//推荐弹幕块处理点.
			(function():void
				{ /** recommend fix,使用闭包修正在低版本的flash player上运行顺序出错 **/
					/** 会改变 hasRecommend 值 **/
					if (!hasRecommend)
					{
						/**
						 * 进入自检测状态,对于没有在accessConfig中获得推荐弹属性的,
						 * 但是又有推荐弹幕的播放器,默认为推荐弹幕开启状态
						 * 以第一条弹幕是否是pool=3为判定点
						 **/
						item = list[0] as XML;
						attrs = String(item.@p).split(',');
						pool = int(attrs[5]);
						if (pool == 3)
						{
							hasRecommend = true;
							isRecommend = true; //开启推荐弹幕
						}
					}
					
					if (hasRecommend)
					{
						if (!(max > 0))
						{
							max = Number(xml.maxlimit);
							if (!(max > 0))
							{
								hasRecommend = false;
							}
						}
					}
					
					if (hasRecommend) /** 如果有推荐弹幕, 根据弹幕上限以及是否开启推荐弹幕计算好当前显示的弹幕 **/
					{
						var list_r:Array = []; /** recommend **/
						var list_c:Array = [];
						for each (item in list)
						{
							attrs = String(item.@p).split(',');
							pool = int(attrs[5]);
							if (pool == 3)
								list_r.push(item);
							else
								list_c.push(item);
						}
						item_list = [];
						var cnt:Number = max;
						if (isRecommend)
						{
							for each (item in list_r)
							{
								item_list.push(item);
								cnt--;
								if (cnt <= 0)
									break;
							}
							/** 要填充补完实时弹幕在这里添加代码 **/
						}
						else
						{
							var r_cnt:Number = cnt - list_c.length;
							/** 用推荐弹幕补完如果没有到达上限 **/
							for each (item in list_r)
							{
								if (r_cnt <= 0)
									break;
								r_cnt--;
								item_list.push(item);
							}
							
							for each (item in list_c)
							{
								item_list.push(item);
								cnt--;
								if (cnt <= 0)
									break;
							}
						}
					}
				})();
			
			for each (item in item_list)
			{
				attrs = String(item.@p).split(',');
				var mode:uint = uint(attrs[1]);
				if (mode !== 7)
				{
					obj = new CommentData();
				}
				else
				{
					obj = new CommentDataMode7();
				}
				obj.mode = uint(attrs[1]);
				obj.bilibili::stime = Math.max(0, parseFloat(attrs[0]));
				obj.size = uint(attrs[2]);
				obj.color = uint(attrs[3]);
				obj.date = DateTimeUtils.getDateTime(new Date(attrs[4] * 1000));
				obj.pool = int(attrs[5]);
				obj.bilibili::userId = attrs[6];
				obj.bilibili::danmuId = uint(attrs[7]);
				obj.border = false;
				obj.id = length++;
				
				if (obj.mode < 7)
				{
					obj.bilibili::text = text_string(item);
				}
				else if (obj.mode == 7)
				{
					try
					{
						objExt = obj as CommentDataMode7;
						var json:Object = JSON.parse(item)
						objExt.x = Number(json[0]);
						objExt.y = Number(json[1]);
						objExt.bilibili::text = text_string(json[4]);
						objExt.rZ = objExt.rY = 0;
						if (json.length >= 7)
						{
							objExt.rZ = Number(json[5]);
							objExt.rY = Number(json[6]);
						}
						objExt.adv = false; //表示是无运动的弹幕
						if (json.length >= 11)
						{
							objExt.adv = true; //表示是有运动的弹幕
							objExt.toX = Number(json[7]);
							objExt.toY = Number(json[8]);
							objExt.mDuration = 0.5; //默认移动时间,单位秒
							objExt.delay = 0; //默认移动前的暂停时间
							if (json[9] != '')
							{
								objExt.mDuration = Number(json[9]) / 1000;
							}
							if (json[10] != '')
							{
								objExt.delay = Number(json[10]) / 1000;
							}
						}
						if (json.length >= 12)
						{
							//是否有描边
							objExt.borderStyle = String(json[11]) == 'true';
						}
						if (json.length >= 13)
						{
							//字体
							objExt.fontFamily = String(json[12]);
						}
						if (json.length >= 14)
						{
							//是否有加速度
							objExt.isAccelerated = String(json[13]) == '0';
						}
						if (json.length >= 15)
						{
							//路径数据
							objExt.motionPath = String(json[14]);
						}
						objExt.duration = 2.5;
						if (json[3] < 12 && json[3] != 1)
						{
							objExt.duration = Number(json[3]);
						}
						objExt.inAlpha = objExt.outAlpha = 1;
						var aa:Array = String(json[2]).split('-');
						if (aa.length >= 2)
						{
							objExt.inAlpha = Number(aa[0]);
							objExt.outAlpha = Number(aa[1]);
						}
					}
					catch (e:Error)
					{
						trace('不是良好的JSON格式:' + item);
						continue;
					}
				}
				else if (obj.mode == 8)
				{
					//脚本弹幕,假设服务器使用bili的格式来产生弹幕
					obj.bilibili::text = String(item);
				}
				else
				{
					continue;
				}
				if (item.@live_extra.length())
				{
					try
					{
						var extra_str:String = String(item.@live_extra);
						var extra:Array = JSON.parse(extra_str) as Array;
						var live_extra:CommentDataLiveExtra = new CommentDataLiveExtra();
						live_extra.uid = String(extra[0]);
						live_extra.nickname = extra[1];
						live_extra.member_type = Number(extra[2]);
						obj.live_extra = live_extra;
					}
					catch (e:Error)
					{
						trace('Live_extra parsing error, skip');
					}
				}
				foo(String(obj.mode), obj);
			}
		}
		
		/** 弹幕数据简单序列化
		 *   输入:消息队列中的弹幕实体
		 *   输出:与基本弹幕类似的结构,方便使用旧的数据存储服务器
		 **/
		public static function data_format(item:Object):Object
		{
			var data:Object = {};
			var textData:Array = [];
			if (item.type == 'normal')
			{
				data.mode = item.mode;
				data.pool = item.pool;
				data.color = item.color;
				data.fontsize = item.size;
				data.playTime = item.stime;
				data.message = serialize_text(item.text);
			}
			else if (item.type == 'zoome')
			{
				textData = [serialize_text(item.text), item.x, item.y, item.alpha, item.style, item.duration, item.inStyle, item.outStyle, item.position, item.tStyle, item.tEffect,];
				data.mode = item.mode;
				data.pool = item.pool;
				data.color = item.color;
				data.fontsize = item.size;
				data.playTime = item.stime;
				data.message = JSON.stringify(textData);
			}
			else if (item.type == 'bili')
			{
				//0~6
				textData = [item.x, item.y, item.inAlpha + '-' + item.outAlpha, item.duration, serialize_text(item.text)];
				if (item.adv)
				{
					//7~11
					//0~4
					var extra:Array = [item.rZ, item.rY, item.toX, item.toY, item.mDuration * 1000, item.delay * 1000, item.borderStyle, item.fontFamily, item.isAccelerated ? 0 : 1 //0表示有加速度!!
						];
					if (item.motionPath != null)
					{
						extra.push(item.motionPath);
					}
					textData = textData.concat(extra);
				}
				data.mode = item.mode;
				data.pool = item.pool;
				data.color = item.color;
				data.fontsize = item.size;
				data.playTime = item.stime;
				data.message = JSON.stringify(textData);
			}
			else if (item.type == 'script')
			{
				data.mode = 8;
				data.pool = 2;
				data.color = 0xffffff;
				data.fontsize = 25;
				data.playTime = item.stime;
				data.message = item.text;
			}
			else
			{
				return null;
			}
			data.date =DateTimeUtils.getDateTime()
			return data;
		}
		
		/** 弹幕的解析
		 * 输入:服务器返回的弹幕组
		 * 作用:解析每条弹幕并将数据广播
		 **/
		public static function data_parse(items:Array, foo:Function):void
		{
			for (var i:int = 0; i < items.length; i++)
			{
				var item:Object = items[i];
				var obj:Object = {};
				
				obj.text = item.message;
				obj.stime = item.stime;
				obj.mode = item.mode;
				obj.size = item.size;
				obj.color = item.color;
				obj.date =DateTimeUtils.getDateTime(new Date(item.postdate * 1000));
				obj.border = false;
				
				if (Number(obj.mode) == 9)
				{
					try
					{
						var appendattr:Object = JSON.parse(item.message)
						obj.text = CommentDataParser.text_string(appendattr[0]);
						obj.x = appendattr[1];
						obj.y = appendattr[2];
						obj.alpha = appendattr[3];
						obj.style = appendattr[4];
						obj.duration = appendattr[5];
						obj.inStyle = appendattr[6];
						obj.outStyle = appendattr[7];
						obj.position = appendattr[8];
						obj.tStyle = appendattr[9];
						obj.tEffect = appendattr[10];
						foo(obj.style + obj.position, obj);
					}
					catch (error:Error)
					{
						trace('JSON decode failed:' + item.message);
					}
					continue;
				}
				else if (Number(obj.mode) == 7)
				{
					try
					{
						var json:Object = JSON.parse(item.message);
						obj.x = Number(json[0]);
						obj.y = Number(json[1]);
						obj.text = CommentDataParser.text_string(json[4]);
						obj.rZ = obj.rY = 0;
						if (json.length >= 7)
						{
							obj.rZ = Number(json[5]);
							obj.rY = Number(json[6]);
						}
						obj.adv = false; //表示是无运动的弹幕
						if (json.length >= 11)
						{
							obj.adv = true; //表示是有运动的弹幕
							obj.toX = Number(json[7]);
							obj.toY = Number(json[8]);
							obj.mDuration = 0.5; //默认移动时间,单位秒
							obj.delay = 0; //默认移动前的暂停时间
							if (json[9] != '')
							{
								obj.mDuration = Number(json[9]) / 1000;
							}
							if (json[10] != '')
							{
								obj.delay = Number(json[10]) / 1000;
							}
						}
						obj.duration = 2.5;
						if (json[3] < 12 && json[3] != 1)
						{
							obj.duration = Number(json[3]);
						}
						obj.inAlpha = obj.outAlpha = 1;
						var aa:Array = String(json[2]).split('-');
						if (aa.length >= 2)
						{
							obj.inAlpha = Number(aa[0]);
							obj.outAlpha = Number(aa[1]);
						}
					}
					catch (e:Error)
					{
						trace('不是良好的JSON格式:' + item.message);
						continue;
					}
				}
				foo(String(obj.mode), obj);
			}
		}
		
		/** 处理文本中的换行符 **/
		public static function text_string(input:String):String
		{
			return input.replace(/(\/n|\\n|\n|\r\n)/g, "\r");
		}
		
		/** 将换行(\r)格式化为 /n **/
		public static function serialize_text(input:String):String
		{
			return input.replace(/\r/g, '/n');
		}
		
		/** 将/n转化为换行(\r) **/
		public static function deserialize_text(input:String):String
		{
			return input.replace(/\/n/g, '\r');
		}		
		
		/** 去除换行,剪切长度 **/
		public static function cut(str:String, n:Number = 17):String
		{
			var tmp:Array = str.split("\n");
			str = tmp.join("");
			tmp = str.split("\r");
			str = tmp.join("");
			if (str.length <= n)
			{
				return str;
			}
			else
			{
				return str.substr(0, n) + '...';
			}
		}
	}
}