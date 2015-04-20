package com.lizeqiangd.zweisystem.interfaces.baseunit
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	/**
	 * 用于外部assest的基类
	 * @author Lizeqiangd
	 */
	public class BaseAssestButton extends BaseButton
	{
		private var mouse_button_config_arr:Array
		private var tx_textfield:TextField
		public static const assest_movieclip_name:String = 'mc_button'
		public static const assest_textfield_name:String = 'tx_title'
		
		public static function get DefaultMouseButtonColorConfig():Array
		{
			return [[0.5, -1], [0.4, -1], [0.2, -1], [0.2, -1]]
		}
		
		public function BaseAssestButton(isContentText:Boolean = false)
		{
			super(true)
			if (isContentText)
			{
				tx_textfield = this.getChildByName(BaseAssestButton.assest_textfield_name) as TextField
				tx_textfield.mouseEnabled = false
			}
			
			mouse_button_config_arr = BaseAssestButton.DefaultMouseButtonColorConfig
			sp_click = getChildByName(BaseAssestButton.assest_movieclip_name)
			for (var i:int = 0; i < this.numChildren; i++)
			{
				try
				{
					trace(getChildAt[i])
					getChildAt[i].mouseEnabled = false
					if (getChildAt[i].name == BaseAssestButton.assest_movieclip_name)
					{
						getChildAt[i].mouseEnabled = true
					}
				}
				catch (e:*)
				{
				}
			}
			addUiListener()			
			onMouseOut(null)
		}
		
		/**
		 * 设置鼠标经过按钮的颜色
		 * [[0,0xffffff],[0.5,0x222222],[0.6,0xffffff][0.3,0xffffff]]
		 * down out over up
		 * @param	obj
		 */
		public function configMouseButtonColor(arr:Array):void
		{
			mouse_button_config_arr = arr;
		}
		
		public function set title(s:String):void
		{
			if (tx_textfield)
			{
				tips_title = s
				tx_textfield.text = s;
			}
		}
		public function get title():String
		{
			if (tx_textfield)
			{
				return tx_textfield.text;
			}
			return '';
		}
		
		override public function onMouseDown(e:MouseEvent):void
		{
			
			if (mouse_button_config_arr[0][0] >= 0)
			{
				sp_click.alpha = mouse_button_config_arr[0][0]
			}
			if (mouse_button_config_arr[0][1] >= 0)
			{
				var ct:ColorTransform = new ColorTransform()
				ct.color = mouse_button_config_arr[0][1]
				sp_click.transform.colorTransform = ct
			}
		}
		
		override public function onMouseOver(e:MouseEvent):void
		{
			if (mouse_button_config_arr[1][0] >= 0)
			{
				sp_click.alpha = mouse_button_config_arr[1][0]
			}
			if (mouse_button_config_arr[1][1] >= 0)
			{
				var ct:ColorTransform = new ColorTransform()
				ct.color = mouse_button_config_arr[0][1]
				sp_click.transform.colorTransform = ct
			}
		}
		
		override public function onMouseOut(e:MouseEvent):void
		{
			if (mouse_button_config_arr[2][0] >= 0)
			{
				sp_click.alpha = mouse_button_config_arr[2][0]
			}
			if (mouse_button_config_arr[2][1] >= 0)
			{
				var ct:ColorTransform = new ColorTransform()
				ct.color = mouse_button_config_arr[0][1]
				sp_click.transform.colorTransform = ct
			}
		}
		
		override public function onMouseUp(e:MouseEvent):void
		{
			if (mouse_button_config_arr[3][0] >= 0)
			{
				sp_click.alpha = mouse_button_config_arr[3][0]
			}
			if (mouse_button_config_arr[3][1] >= 0)
			{
				var ct:ColorTransform = new ColorTransform()
				ct.color = mouse_button_config_arr[0][1]
				sp_click.transform.colorTransform = ct
			}
		}
	
	}

}