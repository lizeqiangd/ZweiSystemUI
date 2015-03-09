package com.bilibili.player.applications.VideoControlBar.Standard
{
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseUI;
	import com.bilibili.player.components.encode.DateTimeUtils;
	import com.bilibili.player.events.PlayerControlEvent;
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.bilibili.player.interfaces.button.videocontroller.*;
	import com.bilibili.player.interfaces.slider.sld_general;
	import com.lizeqiangd.zweisystem.interfaces.slider.sld_videoprogressbar;
	import com.bilibili.player.system.config.BPTextFormat;
	import com.bilibili.player.system.proxy.StageProxy;
	import com.lizeqiangd.zweisystem.interfaces.button.videocontroller.btn_fullscreen;
	import com.lizeqiangd.zweisystem.interfaces.button.videocontroller.btn_play;
	import com.lizeqiangd.zweisystem.interfaces.button.videocontroller.btn_repeat;
	import com.lizeqiangd.zweisystem.interfaces.button.videocontroller.btn_volume;
	import com.lizeqiangd.zweisystem.interfaces.button.videocontroller.btn_widescreen;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	/**
	 * 视频控制条本体. 全屏后也是这个控制条在控制全局
	 * 功能列表:播放(暂停)[按钮] 进度条[滑块]  时间显示[文本框] 时间跳转[文本框] 音量[按钮]  音量条[滑块] 弹幕[按钮] 重播[按钮] 宽屏[按钮] 全屏[按钮]
	 * 外部可用方法:
	 * 音量控制
	 * 进度条时间控制
	 * 播放状态控制
	 * (其他设置暂时不需要反馈到显示状态改变因此没做.)
	 * @author Lizeqiangd
	 * 20150106 增加音量控制
	 */
	public class StandardVideoControlBar extends BaseUI
	{
		///全部的按钮 ui
		private var btn_controller_play:btn_play
		private var btn_controller_comment:btn_comment
		private var btn_controller_widescreen:btn_widescreen
		private var btn_controller_repeat:btn_repeat
		private var btn_controller_fullscreen:btn_fullscreen
		private var btn_controller_volume:btn_volume
		private var tx_time:TextField
		private var tx_seektime:TextField
		private var sld_video:sld_videoprogressbar
		private var sld_volume:sld_general
		
		///视频时间文字表示
		private var _videoDurationTime:String = "22:00"
		private var _videoPlayedTime:String = "00:00"
		
		//用于静音控制用的音量保存
		private var _volume:Number = 0
		
		//弹幕样式控制
		private var is_hide_comment:Boolean = false
		
		public function StandardVideoControlBar()
		{
			btn_controller_play = new btn_play
			btn_controller_comment = new btn_comment
			btn_controller_widescreen = new btn_widescreen
			btn_controller_repeat = new btn_repeat
			btn_controller_fullscreen = new btn_fullscreen
			btn_controller_volume = new btn_volume
			tx_seektime = new TextField
			tx_time = new TextField
			sld_video = new sld_videoprogressbar
			sld_volume = new sld_general
			
			//初始化按钮
			btn_controller_play.config(35, 25)
			btn_controller_comment.config(25, 25)
			btn_controller_widescreen.config(25, 25)
			btn_controller_repeat.config(25, 25)
			btn_controller_fullscreen.config(25, 25)
			btn_controller_volume.config(25, 25)
			
			//添加到界面上			
			addChild(btn_controller_play)
			addChild(btn_controller_comment)
			addChild(btn_controller_widescreen)
			addChild(btn_controller_repeat)
			addChild(btn_controller_fullscreen)
			addChild(btn_controller_volume)
			addChild(sld_volume)
			addChild(tx_time)
			addChild(sld_video)
			
			//初始化字体
			var tf:TextFormat = BPTextFormat.DefaultBlackTextFormat
			tf.align = TextFormatAlign.CENTER
			//tf.bold = true
			//SelectionColor.setFieldSelectionColor(tx_time,0xA8C6EE)
			tx_time.y = 2
			tx_time.defaultTextFormat = tf
			tx_time.width = 80
			tx_time.height = 20
			tx_time.text = "12:34/56:78"
			
			tx_seektime.y = 2
			tx_seektime.defaultTextFormat = tf
			tx_seektime.width = 70
			tx_seektime.height = 20
			tx_seektime.restrict = "0-9 :"
			tx_seektime.text = "00:00"
			tx_seektime.type = TextFieldType.INPUT
			tx_seektime.borderColor = 0xE7E7E7
			tx_seektime.border = true
			
			btn_controller_play.selected = true
			sld_volume.configWidth(45)
			sld_volume.setMax = 1
		}
		
		/**
		 * 直接设置宽度.
		 * @param	_w
		 */
		public function configWidth(_w:Number):void
		{
			configBaseUi(_w, 25)
			setFrameColor = 0xa2a2a2
			createFrame(false)
			createBackground(1)
			sp_frame.graphics.moveTo(35, 0)
			sp_frame.graphics.lineTo(35, 25)
			
			btn_controller_play.x = btn_controller_play.y = 0
			btn_controller_comment.x = _w - 100
			btn_controller_widescreen.x = _w - 50
			btn_controller_repeat.x = _w - 75
			btn_controller_fullscreen.x = _w - 25
			btn_controller_volume.x = _w - 170
			
			sld_video.x = 50
			sld_video.configWidth(_w - 210 - 90)
			sld_volume.x = _w - 145
			
			tx_time.x = _w - 245
			tx_seektime.x = _w - 245
		}
		
		/**
		 * 增加对UI的侦听
		 */
		public function addUiListener():void
		{
			tx_time.addEventListener(MouseEvent.CLICK, onMouseClick)
			tx_seektime.addEventListener(MouseEvent.CLICK, onMouseClick)
			tx_seektime.addEventListener(KeyboardEvent.KEY_DOWN, onSeekTextFieldKeyDown)
			
			btn_controller_play.addEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_comment.addEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_widescreen.addEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_repeat.addEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_fullscreen.addEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_volume.addEventListener(UIEvent.CLICK, onMouseClick)
			sld_video.addEventListener(UIEvent.CHANGE, onSeekHandle)
			sld_volume.addEventListener(UIEvent.CHANGE, onVolumeChange)
		}
		
		/**
		 * 移除对UI侦听
		 */
		public function removeUiListener():void
		{
			tx_time.addEventListener(MouseEvent.CLICK, onMouseClick)
			tx_seektime.addEventListener(MouseEvent.CLICK, onMouseClick)
			tx_seektime.addEventListener(KeyboardEvent.KEY_DOWN, onSeekTextFieldKeyDown)
			btn_controller_play.removeEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_comment.removeEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_widescreen.removeEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_repeat.removeEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_fullscreen.removeEventListener(UIEvent.CLICK, onMouseClick)
			btn_controller_volume.removeEventListener(UIEvent.CLICK, onMouseClick)
			sld_video.removeEventListener(UIEvent.CHANGE, onSeekHandle)
			sld_volume.removeEventListener(UIEvent.CHANGE, onVolumeChange)
			
			sld_volume.removeUiListener()
			sld_video.removeUiListener()
			btn_controller_volume.removeUiListener()
			btn_controller_fullscreen.removeUiListener()
			btn_controller_repeat.removeUiListener()
			btn_controller_widescreen.removeUiListener()
			btn_controller_comment.removeUiListener()
			btn_controller_play.removeUiListener()
		}
		
		/**
		 * 设置显示时间
		 */
		public function setVideoPlayTime(played:Number = 0, buffer:Number = 0, max:Number = 0):void
		{
			//trace("SVCB.setVideoPlayTime[played:", played, "buffer:", buffer, "max:", max, "]")
			if (max > 0)
			{
				sld_video.setMax = max
				_videoDurationTime = DateTimeUtils.formatSecond(max)
			}
			if (played > 0)
			{
				sld_video.setPlayed = played
				_videoPlayedTime = DateTimeUtils.formatSecond(played)
			}
			if (buffer > 0)
			{
				sld_video.setBuffer = buffer
			}
			sld_video.update()
			tx_time.text = _videoPlayedTime + "/" + _videoDurationTime
		}
		
		/**
		 * 设置播放按钮是否为播放状态
		 * @param	showPlay
		 */
		public function setPlayButtonState(showPlay:Boolean):void
		{
			btn_controller_play.selected = showPlay
		}
		
		/**
		 * 音量控制 -1为静音
		 * @param	volume 音量大小-1,0-1
		 */
		public function setVolume(volume:Number, outerControl:Boolean = false):void
		{
			if (volume >= 0)
			{
				_volume = volume > 1 ? 1 : volume;
				sld_volume.setNow = _volume
				dispatchEvent(new PlayerControlEvent(PlayerControlEvent.VOLUME, _volume))
			}
			else
			{
				sld_volume.setNow = 0
				btn_controller_volume.selected = false
				dispatchEvent(new PlayerControlEvent(PlayerControlEvent.VOLUME, 0))
			}
		}
		
		/**
		 * 设置vcb音量设置反馈
		 * @param	e
		 */
		private function onVolumeChange(e:UIEvent):void
		{
			_volume = e.data
			btn_controller_volume.selected = true
			dispatchEvent(new PlayerControlEvent(PlayerControlEvent.VOLUME, _volume))
		}
		
		/**
		 * 对seek文字框文字输入进行处理
		 * @param	e
		 */
		private function onSeekTextFieldKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				var str:String = tx_seektime.text
				var arr:Array = str.split(":")
				var num:Number = 0
				for (var i:int = 0; i < arr.length; i++)
				{
					num += arr[i] * Math.pow(60, arr.length - i - 1)
				}
				onSeek(num)
				onSeekTextFieldClose()
			}
		}
		
		/**
		 * 反馈滑块的seek
		 * @param	e
		 */
		private function onSeekHandle(e:UIEvent):void
		{
			onSeek(e.data)
		}
		
		/**
		 * 提交seek时间
		 * @param	e
		 */
		private function onSeek(e:Number):void
		{
			dispatchEvent(new PlayerControlEvent(PlayerControlEvent.SEEK, e))
		}
		
		private function onMouseClick(e:Event):void
		{
			switch (e.target)
			{
				case tx_time: 
					StageProxy.addEventListener(MouseEvent.CLICK, onStageClick)
					tx_seektime.text = tx_time.text.split("/")[0];
					tx_seektime.setSelection(0, tx_seektime.text.length)
					addChild(tx_seektime)
					removeChild(tx_time)
					break;
				case tx_seektime: 
					//tx_seektime.setSelection(0, tx_seektime.text.length)
					break;
				case btn_controller_play: 
					dispatchEvent(new PlayerControlEvent(btn_controller_play.selected ? PlayerControlEvent.PAUSE : PlayerControlEvent.PLAY))
					break;
				case btn_controller_comment: 
					dispatchEvent(new PlayerControlEvent(PlayerControlEvent.HIDE_COMMENT, btn_controller_comment.selected))
					break;
				case btn_controller_widescreen:
					
					break;
				case btn_controller_repeat: 
					dispatchEvent(new PlayerControlEvent(PlayerControlEvent.REPEAT, btn_controller_repeat.selected))
					break;
				case btn_controller_fullscreen: 
					break;
				case btn_controller_volume: 
					//目前采取的措施是直接控制滑块使其进入静音模式
					if (btn_controller_volume.selected)
					{
						setVolume(_volume)
					}
					else
					{
						setVolume(-1)
					}
					break;
				default: 
			}
		}
		
		/**
		 * 舞台点击事件反馈,用于返回到显示时间状态
		 */
		private function onStageClick(e:MouseEvent):void
		{
			tx_time.hitTestPoint(e.stageX, e.stageY) || tx_seektime.hitTestPoint(e.stageX, e.stageY) ? null : onSeekTextFieldClose()
		}
		
		/**
		 * 调度关闭seek时间模式.
		 */
		private function onSeekTextFieldClose():void
		{
			StageProxy.removeEventListener(MouseEvent.CLICK, onStageClick)
			addChild(tx_time)
			removeChild(tx_seektime)
		}
	
	}

}