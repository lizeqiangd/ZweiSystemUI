package com.bilibili.player.applications.CommentSytlePanel.Standard
{
	import adobe.utils.CustomActions;
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.button.btn_commentStyleSelection;
	import com.lizeqiangd.zweisystem.interfaces.colorpicker.cp_general;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	import com.bilibili.player.system.config.BPFilter;
	import com.bilibili.player.system.config.BPSetting;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.bilibili.player.valueobjects.comment.CommentStyleConfig;
	import com.bilibili.player.valueobjects.comment.CommentStyleData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * 标准型 弹幕样式选择版面.   也就是点击弹幕样式按钮后 显示的那个方框.
	 * update:20140930
	 * @author Lizeqiangd
	 */
	public class StandardCommentStylePanel extends BaseUI
	{
		private var mc_frame:Sprite
		private var mc_bg:Sprite
		private var mc_button:Sprite
		private var tx_title:TextField
		private var cp_generals:cp_general
		private var btn_size_big:btn_commentStyleSelection
		private var btn_size_middle:btn_commentStyleSelection
		private var btn_size_small:btn_commentStyleSelection
		private var btn_comment_left:btn_commentStyleSelection
		private var btn_comment_right:btn_commentStyleSelection
		private var btn_comment_up:btn_commentStyleSelection
		private var btn_comment_down:btn_commentStyleSelection
		
		public function StandardCommentStylePanel()
		{
			configBaseUi(230, 260)
			//createPanelFrame(getUiWidth, getUiHeight)
			//createTitleText()
			createColorPicker()
			createBackGround()
			createDecorationFrame()
			createCommentStyleButtons()
			addUiListener()
		}
		
		///默认样式初始化
		public function config():void
		{
			btn_size_middle.selected = true
			btn_comment_left.selected = true
			
			//上方显示颜色的样子
			cp_generals.configDisplay(0, 0, 40, 20)
			
			//色块的样子
			cp_generals.configCore(15, 15, 5, 10, true)
		
		}
		
		///设置默认显示的颜色
		public function configDefaultColor(e:uint):void
		{
			cp_generals.setDefaultShowColor(e)
		}
		
		///设置显示颜色的数组.
		public function configColorVector(e:Array):void
		{
			cp_generals.configColorVector(e)
		}
		
		///设置弹幕格式按钮的设定.
		public function configStyleButton(e:CommentStyleConfig):void
		{
			mc_button.removeChildren() 
			
			e.big ? mc_button.addChild(btn_size_big) : null
			e.middle ? mc_button.addChild(btn_size_middle) : null
			e.small ? mc_button.addChild(btn_size_small) : null
			e.right ? mc_button.addChild(btn_comment_right) : null
			e.left ? mc_button.addChild(btn_comment_left) : null
			e.up ? mc_button.addChild(btn_comment_up) : null
			e.down ? mc_button.addChild(btn_comment_down) : null
			
			resetAllStyleButtonFlag()
			
			btn_size_middle.selected = true
			btn_comment_left.selected = true
		}
		
		///中间的横线
		private function createDecorationFrame():void
		{
			mc_bg.graphics.lineStyle(1.5, 0xa2a2a2, 0.8)
			mc_bg.graphics.moveTo(10, 85)
			mc_bg.graphics.lineTo(215, 85)
			mc_bg.graphics.moveTo(10, 85 + 80)
			mc_bg.graphics.lineTo(215, 85 + 80)
		}
		
		///对内部按钮模块添加侦听器
		private function addUiListener():void
		{
			//	mc_bg.addEventListener(MouseEvent.MOUSE_UP, onPanelMouseUp)
			//mc_bg.addEventListener(MouseEvent.MOUSE_DOWN, onPanelMouseDown)
			cp_generals.addEventListener(UIEvent.CHANGE, onPanelColorChanged)
		}
		
		private function onPanelColorChanged(e:UIEvent):void
		{
			//DataManager.getCommentStyleData.color = e.data
			dispatchEvent(new UIEvent(UIEvent.CHANGE))
		}
		
		///创建背景
		private function createBackGround():void
		{
			mc_bg = new Sprite
			mc_bg.graphics.beginFill(0xffffff, BPSetting.StandardCommentStylePanelBackGroundAlpha)
			mc_bg.graphics.drawRoundRect(0, 0, getUiWidth, getUiHeight, 10)
			//mc_bg.filters=[BPFilter.DefaultBlurFilter]
			addChildAt(mc_bg, 0)
		}
		
		private function onPanelMouseUp(e:MouseEvent):void
		{
			this.stopDrag()
		}
		
		private function onPanelMouseDown(e:MouseEvent):void
		{
			this.startDrag()
		}
		
		///创建颜色选取框
		private function createColorPicker():void
		{
			cp_generals = new cp_general
			cp_generals.x = 20
			cp_generals.y = 180
			addChild(cp_generals)
		}
		
		///创建弹幕样式按钮
		private function createCommentStyleButtons():void
		{
			mc_button = new Sprite
			
			btn_size_big = new btn_commentStyleSelection
			btn_size_middle = new btn_commentStyleSelection
			btn_size_small = new btn_commentStyleSelection
			btn_comment_down = new btn_commentStyleSelection
			btn_comment_left = new btn_commentStyleSelection
			btn_comment_up = new btn_commentStyleSelection
			btn_comment_right = new btn_commentStyleSelection
			
			btn_comment_right.addEventListener(UIEvent.CLICK, onCommentStyleButtonClick)
			btn_comment_up.addEventListener(UIEvent.CLICK, onCommentStyleButtonClick)
			btn_comment_left.addEventListener(UIEvent.CLICK, onCommentStyleButtonClick)
			btn_comment_down.addEventListener(UIEvent.CLICK, onCommentStyleButtonClick)
			btn_size_small.addEventListener(UIEvent.CLICK, onCommentStyleButtonClick)
			btn_size_middle.addEventListener(UIEvent.CLICK, onCommentStyleButtonClick)
			btn_size_big.addEventListener(UIEvent.CLICK, onCommentStyleButtonClick)
			
			btn_size_small.config(45, 60)
			btn_size_small.y = 20
			btn_size_small.x = 20
			btn_size_small.setIcon(SkinManager.getObject("comment_style_small"))
			
			btn_size_middle.config(45, 60)
			btn_size_middle.y = 20
			btn_size_middle.x = 90
			btn_size_middle.setIcon(SkinManager.getObject("comment_style_middle"))
			
			btn_size_big.config(45, 60)
			btn_size_big.y = 20
			btn_size_big.x = 160
			btn_size_big.setIcon(SkinManager.getObject("comment_style_big"))
			
			btn_comment_left.config(45, 60)
			btn_comment_left.x = 90
			btn_comment_left.y = 100
			btn_comment_left.setIcon(SkinManager.getObject("comment_style_left"))
			
			btn_comment_up.config(45, 60)
			btn_comment_up.x = 20
			btn_comment_up.y = 100
			btn_comment_up.setIcon(SkinManager.getObject("comment_style_up"))
			
			btn_comment_down.config(45, 60)
			btn_comment_down.x = 160
			btn_comment_down.y = 100
			btn_comment_down.setIcon(SkinManager.getObject("comment_style_down"))
			
			btn_comment_right.config(45, 60)
			btn_comment_right.x = 230
			btn_comment_right.y = 100
			btn_comment_right.setIcon(SkinManager.getObject("comment_style_right"))
			
			addChild(mc_button)
		}
		
		private function resetAllStyleButtonFlag():void
		{
			resetFontSizeButtonFlag()
			resetCommentDirectionFlag()
		}
		
		private function resetFontSizeButtonFlag():void
		{
			btn_size_big.selected = false
			btn_size_middle.selected = false
			btn_size_small.selected = false
		}
		
		private function resetCommentDirectionFlag():void
		{
			btn_comment_down.selected = false
			btn_comment_left.selected = false
			btn_comment_up.selected = false
			btn_comment_right.selected = false
		}
		
		private function onCommentStyleButtonClick(e:UIEvent):void
		{
			switch (e.target)
			{
				case btn_size_middle: 
					resetFontSizeButtonFlag()
					btn_size_middle.selected = true
					ValueObjectManager.getCommentStyleData.font_size = 25
					dispatchEvent(new UIEvent(UIEvent.CHANGE))
					break;
				case btn_size_big: 
					resetFontSizeButtonFlag()
					btn_size_big.selected = true
					ValueObjectManager.getCommentStyleData.font_size = 37
					dispatchEvent(new UIEvent(UIEvent.CHANGE))
					break;
				case btn_size_small: 
					resetFontSizeButtonFlag()
					btn_size_small.selected = true
					ValueObjectManager.getCommentStyleData.font_size = 13
					dispatchEvent(new UIEvent(UIEvent.CHANGE))
					break;
				case btn_comment_right: 
					resetCommentDirectionFlag()
					btn_comment_right.selected = true
					ValueObjectManager.getCommentStyleData.comment_derection = "right"
					dispatchEvent(new UIEvent(UIEvent.CHANGE))
					break;
				case btn_comment_left: 
					resetCommentDirectionFlag()
					btn_comment_left.selected = true
					ValueObjectManager.getCommentStyleData.comment_derection = "left"
					dispatchEvent(new UIEvent(UIEvent.CHANGE))
					break;
				case btn_comment_up: 
					resetCommentDirectionFlag()
					btn_comment_up.selected = true
					ValueObjectManager.getCommentStyleData.comment_derection = "up"
					dispatchEvent(new UIEvent(UIEvent.CHANGE))
					break;
				case btn_comment_down: 
					resetCommentDirectionFlag()
					btn_comment_down.selected = true
					ValueObjectManager.getCommentStyleData.comment_derection = "down"
					dispatchEvent(new UIEvent(UIEvent.CHANGE))
					break;
			}
		}
		
		private function createTitleText():void
		{
			tx_title = new TextField
			tx_title.defaultTextFormat = BPTextFormat.LightBlueTitleTextFormat
			tx_title.width = 200
			tx_title.height = 20
			tx_title.autoSize = TextFieldAutoSize.CENTER
			tx_title.text = "弹幕样式"
			tx_title.mouseEnabled = false
			//tx_title.filters=[ESFilter.DefaultLightblueGlowFilter]
			addChild(tx_title)
		}
		
		private function createPanelFrame(w:Number, h:Number):void
		{
			mc_frame = new Sprite
			mc_frame.graphics.lineStyle(1, 0x3399ff)
			mc_frame.graphics.moveTo(0, 0)
			mc_frame.graphics.lineTo(w, 0)
			mc_frame.graphics.lineTo(w, h)
			mc_frame.graphics.lineTo(0, h)
			mc_frame.graphics.lineTo(0, 0)
			mc_frame.graphics.moveTo(0, 20)
			mc_frame.graphics.lineTo(w, 20)
			mc_frame.filters = [BPFilter.DefaultLightblueGlowFilter]
			addChild(mc_frame)
		}
	
	}

}