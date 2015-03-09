package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.ICommentButton;
	import com.bilibili.player.core.script.interfaces.IMotionManager;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	//import tv.bilibili.script.interfaces.ICommentButton;
	//import tv.bilibili.script.interfaces.IMotionManager;
	
	public class CommentButton extends Sprite implements ICommentButton
	{
		protected var _motionManager:IMotionManager;
		protected var _label:TextField;
		
		/** 样式 **/
		protected var _colors:Array = [];
		/** 透明度 **/
		protected var _alphas:Array = [];
		/** 状态 **/
		protected var _over:Boolean = false;
		/** 填充矩阵 **/
		protected var _fillMatrix:Matrix;
		/** 无鼠标经过时的投影 **/
		protected static var _shadow:Array = [new DropShadowFilter(1,45,0,0.3,2,2)];
		/**
		 * 设置的大小
		 **/
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		
		public function CommentButton()
		{
			super();
			_motionManager = new MotionManager(this);
			
			mouseEnabled = true;
			buttonMode = true;
			useHandCursor = true;
			
			_label = new TextField();
			var tf:TextFormat = new TextFormat(null, 12, 0x000000, true);
			_label.defaultTextFormat = tf;
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.selectable = false;
			_label.mouseEnabled = false;
			
			addChild(_label);
			
			_fillMatrix = new Matrix();
			
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
		}
		
		public function get motionManager():IMotionManager
		{
			return _motionManager;
		}
		
		public function initStyle(config:Object):void
		{
			this.x = config.x;
			this.y = config.y;
			this.z = config.z;
			this.width = config.width;
			this.height = config.height;
			this.alpha = config.alpha;
			this.scaleX = this.scaleY = config.scale;
		}
		
		public function get text():String
		{
			return _label.text;
		}
		
		public function set text(value:String):void
		{
			if(_label.text != value)
			{
				_label.text = value;
				updateRect();
			}
		}
		
		/**
		 * 计算标签位置
		 **/
		protected function updateRect():void
		{
			if(_width <= 0)
				_width = _label.width + 12;
			if(_height <= 0)
				_height = _label.height + 5;
			
			
			_label.x = (_width - _label.width) / 2;
			_label.y = (_height - _label.height) / 2;
			
			/** drawing **/
			var colors:Array = [];
			var alphas:Array = [];
			var ratios:Array = [];
			if(this._colors.length == 0)
			{
				colors = [0xffffff, 0xdddddd];
			}
			else
			{
				colors = _colors;
			}
			var i:uint = 0;
			var len:uint = colors.length;
			while(i < len)
			{
				if(i < _alphas.length)
				{
					alphas[i] = _alphas[i];
				}
				else
				{
					alphas[i] = _over ? 0.8 : 0.618;
				}
				ratios[i] = Math.floor(i / len * 255); 
				i ++;
			}
			
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x888888);
			if(colors.length == 1)
			{
				this.graphics.beginFill(colors[0], 0.8);
			}
			else
			{
				_fillMatrix.createGradientBox(_width, _height, Math.PI / 2);
				this.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, _fillMatrix);
			}
			this.graphics.drawRoundRect(0, 0, _width, _height, 4, 4);
			this.graphics.endFill();
			
			this.filters = _over ? [] : _shadow;
		}
		
		public function setStyle(name:String, value:*):void
		{
			switch(name)
			{
				case 'fillColors':
					fillColors = value;
				break;
				
				case 'fillAlphas':
					fillAlphas = value;
				break;
			}
		}
		
		public function get fillColors():Array
		{
			return _colors;
		}
		
		public function set fillColors(value:Array):void
		{
			_colors = value;
			updateRect();
		}
		
		public function get fillAlphas():Array
		{
			return _alphas;
		}
		
		public function set fillAlphas(value:Array):void
		{
			_alphas = value;
			updateRect();
		}
		
		public function remove():void
		{
			try
			{
				_motionManager.stop();
				this.parent.removeChild(this);
			}
			catch(error:Error)
			{
			}
		}
		
		override public function set width(value:Number):void
		{
			if(_width != value)
			{
				_width = value;
				updateRect();
			}
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			if(_height != value)
			{
				_height = value;
				updateRect();
			}
			super.height = value;
		}
		
		/** 内部事件 **/
		protected function overHandler(event:MouseEvent):void
		{
			_over = true;
			updateRect();
		}
		
		/** 内部事件 **/
		protected function outHandler(event:MouseEvent):void
		{
			_over = false;
			updateRect();
		}
	}
}