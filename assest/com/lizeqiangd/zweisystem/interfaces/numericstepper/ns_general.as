package com.lizeqiangd.zweisystem.interfaces.numericstepper
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import flash.events.Event;
	//import com.lizeqiangd.zweisystem.manager.AnimationManager;
	//import com.lizeqiangd.zweisystem.components.texteffect.TextAnimation;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 固定限制的翻页栏。会调度 UIEvent.CHANGE事件 event.data为当前应该显示的序列
	 * 使用说明:
	 * var ns:ns_general=new ns_general()
	 * ns.setStepAndTotal(5,100)
	 * ns.addEventListener(UIEvent.CHANGE,onNSChange)
	 * function onNSChange(e:UIEvent){
	 * trace(e.data)
	 * //输出now数值,从0开始,但是显示是1.你懂的哇~
	 * }
	 * 2014.03.18 完全重做界面,同时更改逻辑,使得..我..更容易用..啧啧真是可怜..就我在用 笑嘻嘻.
	 * 2015.03.09 删除依赖库
	 * @author Lizeqiangd
	 *
	 */
	public class ns_general extends Sprite
	{
		private var _step:int = 0;
		private var _now:int = 1;
		private var _total:int = 100;
		private var lastText:String = "";
		private var state:String = "init";
		
		public function ns_general()
		{
			text = "未定义";
			addUiListener();
			this.state = "ready";
		}
		
		private function addUiListener()
		{
			this.btn_left.addEventListener(MouseEvent.CLICK, onLeft);
			this.btn_left.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.btn_left.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			this.btn_right.addEventListener(MouseEvent.CLICK, onRight);
			this.btn_right.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.btn_right.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			this.addEventListener(Event.REMOVED_FROM_STAGE, dispose)
		}
		
		private function removeUiListener()
		{
			this.btn_left.removeEventListener(MouseEvent.CLICK, onLeft);
			this.btn_left.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.btn_left.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			this.btn_right.removeEventListener(MouseEvent.CLICK, onRight);
			this.btn_right.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.btn_right.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, dispose)
		}
		
		/**
		 * 鼠标经过左右按钮时候的动画效果.
		 */
		private function onOver(e:MouseEvent)
		{
			if (e.target == btn_right)
			{
				DisplayObject(btn_right).alpha = 0.5
			}
			if (e.target == btn_left)
			{
				DisplayObject(btn_left).alpha = 0.5
			}
		}
		
		private function onOut(e:MouseEvent)
		{
			if (e.target == btn_right)
			{
				DisplayObject(btn_right).alpha = 0.1;
			}
			if (e.target == btn_left)
			{
				DisplayObject(btn_left).alpha = 0.1;
			}
		
		}
		
		private function onLeft(e:MouseEvent)
		{
			if (state == "ready")
			{
				if (_total <= _step)
				{
					return;
				}
				_now -= _step;
				if (_now < 0)
				{
					_now = 0
				}
				this.changer();
			}
		}
		
		private function onRight(e:MouseEvent)
		{
			if (state == "ready")
			{
				
				if (_total <= _step)
				{
					return;
				}
				if (_now + _step >= _total)
				{
					return;
				}
				_now += _step;
				this.changer();
			}
		}
		
		/**
		 * 当初发左右按钮时候的最终方法,最终抛出事件带有当前数值的参数.
		 */
		private function changer()
		{
			if (_total <= _step)
			{
				text = "(all)";
				return;
			}
			if (_total <= (_now + _step))
			{
				//text = "(" + int(_now + 1) + "-" + _total + ")/" + _total;
				text = int(_now + 1) + "/" + _total;
			}
			if (_now + _step < _total)
			{
				//text = "(" + int(_now + 1) + "-" + int(_now + _step) + ")/" + _total;
				text = int(_now + 1) + "/" + _total;
			}
			this.dispatchEvent(new UIEvent(UIEvent.CHANGE, _now));
		}
		
		/**
		 * 模拟按下右边按钮
		 */
		public function Next()
		{
			onRight(null)
		}
		
		/**
		 * 模拟按下左边按钮
		 */
		public function Prev()
		{
			onLeft(null)
		}
		
		/**
		 * 使该模块是否可用.
		 */
		public function set enable(value:Boolean)
		{
			if (value)
			{
				this.text = lastText;
				addUiListener();
				//AnimationManager.fade_in(this);
				this.alpha = 1
			}
			else
			{
				lastText = text;
				removeUiListener();
				//AnimationManager.fade(this, 0.5);
				this.alpha = 0.5
				this.text = "不可用";
			}
		}
		
		/**
		 * 强行设定当前数字
		 */
		public function set setNow(e:int)
		{
			_now = e
			changer()
		}
		
		/**
		 * 获取当前读数
		 */
		public function get getNow():uint
		{
			return _now;
		}
		
		/**
		 * 获取步进间隔数
		 */
		public function get getStep():uint
		{
			return _step;
		}
		
		/**
		 * 设置步进间隔
		 */
		public function set setStep(e:uint)
		{
			this._step = e
			changer();
		}
		
		/**
		 * 写入文字部分.
		 */
		public function set text(e:String)
		{
			this.tx_title.text = e;
			//TextAnimation.Changing(tx_title, TextAnimation.NUMBER, 1, true)
		}
		
		/**
		 * 获取显示文字
		 */
		public function get text():String
		{
			return this.tx_title.text;
		}
		
		/**
		 * 设置步进总数
		 */
		public function set setMax(e:uint)
		{
			this._total = e
			changer();
		}
		
		///**
		//* 做这个我一定是疯了.可用性为0 看我过两天就删了他.!
		//*/
		//public function set textWidth(e:Number)
		//{
		//btn_right.x = e - btn_right.width
		//tx_title.width = e
		//}
		//
		///**
		//* 主要启动方法.
		//* 初始化模块,需要步进数和总数.重新设置步进数和总数.
		//*/
		//public function init(step:int, total:int)
		//{
		//setStepAndTotal(step, total)
		//}
		//
		///**
		//* 主要启动方法.
		//* 初始化模块,需要步进数和总数.重新设置步进数和总数.
		//*/
		//public function setStepAndTotal(step:int, total:int)
		//{
		//this._now = 0;
		//this.setMax = total
		//this.setStep = step
		//changer();
		//}
		//
		/**
		 * 销毁
		 */
		public function dispose(e:Event = null):void
		{
			removeUiListener()
		}
	}
}