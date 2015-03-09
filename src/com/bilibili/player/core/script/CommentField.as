package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.ICommentField;
	import com.bilibili.player.core.script.interfaces.IMotionManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	//import org.lala.utils.CommentConfig;
	
	//import tv.bilibili.script.interfaces.ICommentField;
	//import tv.bilibili.script.interfaces.IMotionManager;
	
	public class CommentField extends TextField implements ICommentField
	{
		protected var _motionManager:IMotionManager;
		/** 样式 **/
		protected var _format:TextFormat;
		
		public function CommentField()
		{
			super();
			_motionManager = new MotionManager(this);
			
			selectable = false;
			mouseEnabled = false;
		}
		
		public function get motionManager():IMotionManager
		{
			return _motionManager;
		}
		/** 初始化文本格式 **/
		public function initStyle(config:Object):void
		{
			this.x = config.x;
			this.y = config.y;
			this.z = config.z;
			this.alpha = config.alpha;
			this.scaleX = this.scaleY = config.scale;
			
			var tf:TextFormat = new TextFormat(
				config.font
				,config.fontsize
				,config.color
				,ValueObjectManager.getPlayerConfig.bold);
			_format = tf;
			this.defaultTextFormat = tf;
			this.setTextFormat(tf);
			
			this.embedFonts = false;
			this.antiAliasType = AntiAliasType.NORMAL;
			this.autoSize = TextFieldAutoSize.LEFT;
			this.gridFitType = GridFitType.NONE;
			
			this.filters = ValueObjectManager.getPlayerConfig.getFilterByColor(config.color);
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
		
		/** 额外的api **/
		/** 对齐 **/
		public function get align():String
		{
			return _format.align;
		}
		public function set align(value:String):void
		{
			_format.align = value;
			this.setTextFormat(_format);
		}
		/** 粗体 **/
		public function get bold():Boolean
		{
			return _format.bold as Boolean;	
		}
		public function set bold(value:Boolean):void
		{
			_format.bold = value;
			this.setTextFormat(_format);
		}
		/** 字体 **/
		public function get font():String
		{
			return _format.font;			
		}
		public function set font(value:String):void
		{
			_format.font = value;
			this.setTextFormat(_format);
		}
		/** 大小 **/
		public function get fontsize():uint
		{
			return _format.size as uint;			
		}
		public function set fontsize(value:uint):void
		{
			_format.size = value;
			this.setTextFormat(_format);
		}
		/** 颜色 **/
		public function get color():uint
		{
			return _format.color as uint;			
		}
		public function set color(value:uint):void
		{
			_format.color = value;
			this.setTextFormat(_format);
		}
		
		override public function get htmlText():String
		{
			return super.text;
		}
		
		override public function set htmlText(value:String):void
		{
			super.text = value;
		}
		
		
	}
}