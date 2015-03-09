package com.bilibili.player.components.texteffect
{
	import com.bilibili.player.events.AnimationEvent;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.proxy.StageProxy;
	import com.greensock.TweenLite;
	import flash.text.TextField;
	
	/**
	 * EinStation所有文字转换特效类.用法非常简单方便.
	 *
	 * @author Lizeqiangd
	 * @update 2014.03.30 重新检查.
	 *
	 */
	public class TextAnimation
	{
		public static const ALPHABET:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		public static const NUMBER:String = "0123456789";
		public static const KIGOU:String = "△×￥○＠％＆＄＃☆□！";
		public static const CHINESE:String = "中华绝艺世界奇珍法天象地抱阳负阴用智骋材悦性养心渊澄流远叶茂根深滥觞既夐历久弥新尧诫丹朱舜教商均弈秋誉满伯符谱存马融作赋韦曜撰论王粲覆局谢安却秦樵夫烂柯梁帝定品积薪待诏仲甫通神百龄早达龙士最尊范捷似仙施缓实稳乾嘉以降国衰祚陨北浸朝韩东渐日本御城擂争棋所名人江户四家首推坊门算砂秀策千年才俊幻庵耳赤荣元再任因彻呕血缝次亡身十番鏖战悬崖白刃遍擒诸侯惟清源君木谷坂田海峰治勋武宫大竹加藤小林众星璀璨罗绮缤纷高丽崛起鼎足三分朴球拓荒南哲发轫曹徐刘李鱼贯领军杯衔横扫巨奖鲸吞问我九州岂甘沉沦祖德破冰强敌逡巡封圣卫平双冠晓春常昊古力洗河俞斌檄赫垚杰熹啸喆峻出蓝传炬专赖后昆谚曰占角银边草肚俗招偏低能者在腹俱活匪接生由乱处遇劫该提开拔添目弃子逢危取和势孤动则相应慎勿轻速侵消滚包扳粘倒扑腾挪收官肩冲打入夹拐吊征罩刺拆渡飞跳碰尖靠并挖补点扭挤盖托跨搭虎独立金鸡偷油老鼠妖刀雪崩脱靴胀牯道兮至简术也繁缛太极吴图野狐洛书围猎坐隐手谈玄素鬼阵方圆纹楸乌鹭恁广别号斯多典故著选严晏诗咏泌游启伤濞储璋建拘楼彰薨丕陷墅去羯忧戚姬祸惹妙观福修娄逞沈姑技压侪辈越洋丰云夺魁容慧惊艳梅泽伏枥杉内万波矢代依旻泉美志恩惠连玟真乃伟明晖璇锦茜倩菊菲莹莉衡尹奕岩菁桂巾帼裙钗讵让须眉阿基鲁尔迈克雷蒙捐躯汉司昔曾爆冷碧瞳隆准亦颇豪雄巍钧岱利晚报登顶遮眼盲对鲍氏异禀业余藩镇何怍群英籀篆隶楷抹挑勾剔字画同俦瑶琴结侣聃孔左孟史迁秉笔饱食之外犹贤乎已妻孥描纸翁叟橘戏洪漫火燎猱进鸷击疗毒刮骨逾限坏屐揭秘洞奥牛渚燃犀置彼空钩意非鲂鲤潋滟休诉看汝面皮总关宏旨每合易理醍醐棒喝顿悟禅机桥头赏鹤水畔听蛙有约夜半敲落灯花良朋偶聚辄拟厮杀或凶且险抑正而葩宋襄宣仁楚庄称霸沛公逐鹿项籍卸甲匈奴犯疆嫖姚挞伐鹏举挥戈完颜泪洒焚膏继晷为乐无涯舍餐废寝除此靡他崇文尚礼守时毋愆衣饰务整姿态宜端气韵娴静风度翩然洁布擦拭净几弗染份凭段位序藉猜先蹈循规矩服从裁判章程谨遵亲友避嫌着停按钟赛毕复盘戒骄与馁倡恭及谦凡义当往是赌拒沾榉桧榆柳梨楠檀樟罫自香榧奁必岛桑蛤石瀛屿窑扁永昌胡桃燕冀折扇钱塘虞怀殿里莫愁湖上松柏荫庭芝兰吐芳凤尾萧森池澜微漾檐雨还滴霁月初亮鹊鸦杳寂辰宿列张瑟奏雅音樽倾佳酿重屏绘彩烛影摇光茶闲烟绿窗幽指凉堪怜痴癖胜败断肠斟酌盈益琢磨亏丧陶冶情操疏瀹五藏输赢皆喜宠辱偕忘仆虽驽钝不惭七尺萍踪鸿迹惶于栖止耽惑一枰徒增驹齿省躬反思近勇知耻窃慕振翮终未垂翅集缀成篇拜周兴嗣";
		public static const JAPANESE:String = "あアいイうウえエおオかカきキくクけケこコさサしシすスせセそソたタちチつツてテとトなナにニぬヌねネのノはハひヒふフへヘほホまマみミむムめメもモやヤゆユよヨらラりリるルれレろロわワをヲんン"
		public static const ALL_TEXT:String = ALPHABET + NUMBER + KIGOU + CHINESE + JAPANESE
		public static var _speed:int = -1;
		private static var _typingTextArray:Array;
		private static var _changeTextArray:Array;
		private static var _nowHandle:uint = 0;
		
		public static function init():void
		{
			_typingTextArray = new Array;
			_changeTextArray = new Array;
			StageProxy.addEnterFrameFunction(enterframe);
		}
		
		/**
		 * 自动跳转数字动画特效.
		 * @param	e
		 * @param	targetInt
		 * @param	ToOrFrom
		 */
		public static function NumberCount(e:TextField, targetInt:int, needFix:Boolean = false, ToOrFrom:Boolean = true):void
		{
			var arr:Array = [int(e.text)]
			//	if (ToOrFrom){
			
			TweenLite.to(arr, BPSetting.AnimationManagerDefaultTime, {endArray: [targetInt], onUpdate: function():void
				{
					if (needFix)
					{
						e.text = String(arr[0].toFixed(0))
					}
					else
					{
						e.text = String(arr[0])
					}
				
				}})
		
		/*	}else
		   {
		   arr[0] = int(e.text);
		   TweenLite.from(arr, ESSetting.AnimationManagerTime, {endArray: [targetInt], onUpdate: function()
		   {
		   if (needFix)
		   {
		   e.text = int(arr[0]).toFixed(0)
		   }
		   else
		   {
		   e.text = int(arr[0])
		   }
		   }});
		   }
		 */
		}
		
		/**
		 * 制作出打字机的效果.
		 * @param	t 需要实现动画的TextField
		 */
		public static function Typing(t:TextField):void
		{
			
			var o:Object = new Object;
			o.nowCount = 0;
			o.textLength = t.text.length;
			o.text = t.text;
			o.textField = t;
			//trace("***Typing:"+t.text)
			t.text = "";
			addtoTyping(o);
		}
		
		//内部方法
		private static function addtoTyping(o:Object):void
		{
			for (var i:int = 0; i < _typingTextArray.length; i++)
			{
				if (_typingTextArray[i].textField == o.textField)
				{
					_typingTextArray[i] = o;
					return;
				}
			}
			_typingTextArray.push(o);
		}
		
		/**
		 * 可以制作出各种文字随机变幻的文本框动画
		 * @param	t 需要制作变换动画的文本框
		 * @param	useTextString 使用的变幻字体库
		 * @param	speed 速度默认为1
		 * @param	allview 允许全体变换还是逐个显示
		 * @param	now  直接从多少文字显示
		 * @param	animationColor 是否需要改变字体颜色
		 */
		public static function Changing(t:TextField, useTextString:String = null, speed:Number = 1, allview:Boolean = false, now:int = 0, animationColor:int = -1):void
		{
			var o:Object = new Object;
			o.textField = t;
			if (!useTextString)
			{
				useTextString = (TextAnimation.ALPHABET + TextAnimation.NUMBER);
			}
			o._text = t.text;
			o._charset = useTextString;
			o._length = t.text.length;
			o._speed = speed;
			o._allview = allview;
			o._now = now;
			o._setBaseColor = 0xFF9900;
			o._animationColor = animationColor;
			o._tf = t.defaultTextFormat;
			
			for (var i:int = 0; i < _changeTextArray.length; i++)
			{
				if (_changeTextArray[i].textField == o.textField)
				{
					_changeTextArray[i] = o;
					return;
				}
			}
			_changeTextArray.push(o);
		}
		
		//内部方法
		private static function updateChangingText(o:Object):Boolean
		{
			var nowText:String;
			var nowCount:int;
			if (o._now < o._length)
			{
				nowText = o._text.substr(0, int(o._now));
				if (o._allview)
				{
					nowCount = 0;
					while (nowCount < (o._length - o._now))
					{
						nowText = (nowText + o._charset.charAt((o._charset.length * Math.random())));
						nowCount++;
					}
				}
				else
				{
					nowText = (nowText + o._charset.charAt((o._charset.length * Math.random())));
				}
				o.textField.text = nowText;
				//o.textField.textColor = o._baseColor;
				if (0 <= o._animationColor)
				{
					//o._tf.color = o._animationColor;
					//o.textField.setTextFormat(o._tf, o._now, nowText.length);
				}
			}
			else
			{
				o.textField.text = o._text;
				if (0 <= o._animationColor)
				{
					//o._tf.color = o._baseColor;
					//o.textField.setTextFormat(o._tf);
				}
				return true;
			}
			o._now = (o._now + o._speed);
			return false;
		}
		
		//内部方法 全部字体特效的EnterFrame
		private static function enterframe():void
		{
			if (_nowHandle == _speed)
			{
				_nowHandle = 0;
				return;
			}
			_speed > 0 ? _nowHandle++ : null;
			
			var o:Object;
			for (var i:int = 0; i < _typingTextArray.length; i++)
			{
				o = new Object();
				o = _typingTextArray[i];
				o.textField.appendText(o.text.charAt(o.nowCount));
				o.nowCount++;
				//trace("o.nowCount：",o.nowCount,"o.textLength",o.textLength,"i:",i);
				if (o.nowCount == o.textLength)
				{
					_typingTextArray[i].textField.dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE))
					_typingTextArray.splice(i, 1);
				}
			}
			for (i = 0; i < _changeTextArray.length; i++)
			{
				if (updateChangingText(_changeTextArray[i]))
				{
					_changeTextArray[i].textField.dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE))
					_changeTextArray.splice(i, 1);
					
				}
			}
		}
	}
}